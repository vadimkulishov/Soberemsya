import Foundation
import Combine

/// Ошибки API
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorizedError
    case serverError(String)
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
        case .invalidResponse:
            return "Невалидный ответ сервера"
        case .decodingError:
            return "Ошибка парсинга данных"
        case .unauthorizedError:
            return "Не авторизован. Требуется повторный вход"
        case .serverError(let message):
            return "Ошибка сервера: \(message)"
        case .networkError:
            return "Ошибка сети. Проверьте подключение"
        case .unknown(let message):
            return "Неизвестная ошибка: \(message)"
        }
    }
}

/// Пустой ответ от сервера
struct EmptyResponse: Codable {}

/// Ответ от сервера при аутентификации
struct AuthResponse: Codable {
    let accessToken: String
    let user: UserResponse
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

/// Ответ с информацией о пользователе
struct UserResponse: Codable {
    let id: Int
    let username: String
    let email: String
    let fullName: String?
    let city: String?
    let phone: String?
    let role: String?
    let qrCodeData: String?
    let profileCompleted: Bool?
    let isActive: Bool?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case fullName = "full_name"
        case city
        case phone
        case role
        case qrCodeData = "qr_code_data"
        case profileCompleted = "profile_completed"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

/// Ответ с QR кодом
struct QRCodeResponse: Codable {
    let userId: Int
    let qrCodeBase64: String
    let qrCodeData: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case qrCodeBase64 = "qr_code_base64"
        case qrCodeData = "qr_code_data"
    }
}

/// Ответ с событиями
struct EventResponse: Codable {
    let id: Int
    let title: String
    let description: String
    let date: String
    let timeStart: String?
    let timeEnd: String?
    let location: String
    let city: String?
    let category: String?
    let capacity: Int?
    let registeredCount: Int?
    let imageName: String?
    let isActive: Bool?
    let isPublished: Bool?
    let organizer: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case timeStart = "time_start"
        case timeEnd = "time_end"
        case location
        case city
        case category
        case capacity
        case registeredCount = "registered_count"
        case imageName = "image_url"
        case isActive = "is_active"
        case isPublished = "is_published"
        case organizer
        case createdAt = "created_at"
    }
}

/// Ответ при загрузке изображения
struct UploadImageResponse: Codable {
    let success: Bool
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case imageUrl = "image_url"
    }
}

/// Ответ со списком событий
struct EventsListResponse: Codable {
    let events: [EventResponse]
    let total: Int
    let page: Int
    let perPage: Int
    
    enum CodingKeys: String, CodingKey {
        case events
        case total
        case page
        case perPage = "per_page"
    }
}

/// Главный API клиент для взаимодействия с backend'ом
class APIClient {
    static let shared = APIClient()
    
    // Конфигурация
    // Используем AppConfig для динамического выбора URL
    // Поддерживает автоматический fallback между localhost (simulator) и hostname.local (device)
    private var baseURL: String {
        AppConfig.shared.baseURL
    }
    private let apiPath = "/api"
    
    // Токен хранится в памяти и в KeyChain
    @Published var authToken: String? {
        didSet {
            if let token = authToken {
                KeychainManager.saveToken(token)
            } else {
                KeychainManager.deleteToken()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Загружаем токен из Keychain при инициализации
        if let savedToken = KeychainManager.getToken() {
            authToken = savedToken
        }
    }
    
    // MARK: - URL Building
    
    private func buildURL(endpoint: String) -> URL? {
        let urlString = "\(baseURL)\(apiPath)\(endpoint)"
        return URL(string: urlString)
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) -> AnyPublisher<T, APIError> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Добавляем Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Добавляем авторизацию если есть токен
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Добавляем кастомные headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Кодируем body если нужно
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                if method != "GET" {
                    if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                        print("📤 APIClient: \(method) \(url.path) | Body: \(bodyString.prefix(100))...")
                    }
                }
            } catch {
                return Fail(error: .decodingError).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                print("❌ APIClient: Network error: \(error.localizedDescription)")
                return APIError.networkError
            }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("📨 APIClient: Response status \(httpResponse.statusCode) from \(url.path)")
                
                // Логируем ответ для отладки
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📝 Response: \(jsonString.prefix(200))...")
                }
                
                // Обработка HTTP ошибок
                switch httpResponse.statusCode {
                case 200...299:
                    // Success
                    print("✅ APIClient: Success response")
                    break
                case 401:
                    print("🔐 APIClient: Unauthorized (401)")
                    throw APIError.unauthorizedError
                case 400...499:
                    // Try to decode error message
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let detail = errorResponse["detail"] {
                        print("⚠️ APIClient: Client error - \(detail)")
                        throw APIError.serverError(detail)
                    }
                    print("⚠️ APIClient: Client error \(httpResponse.statusCode)")
                    throw APIError.serverError("Client error: \(httpResponse.statusCode)")
                case 500...599:
                    print("⚠️ APIClient: Server error \(httpResponse.statusCode)")
                    throw APIError.serverError("Server error: \(httpResponse.statusCode)")
                default:
                    throw APIError.unknown("HTTP \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                print("⚠️ APIClient: Decode error - \(error)")
                return .decodingError
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Authentication Endpoints
    
    /// Регистрация нового пользователя
    func register(
        username: String,
        email: String,
        password: String,
        fullName: String,
        city: String,
        phone: String? = nil
    ) -> AnyPublisher<AuthResponse, APIError> {
        guard let url = buildURL(endpoint: "/auth/register") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        struct RegisterRequest: Encodable {
            let username: String
            let email: String
            let password: String
            let full_name: String
            let city: String
            let phone: String?
        }
        
        let body = RegisterRequest(
            username: username,
            email: email,
            password: password,
            full_name: fullName,
            city: city,
            phone: phone
        )
        
        return request(url: url, method: "POST", body: body)
    }
    
    /// Вход пользователя
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, APIError> {
        guard let url = buildURL(endpoint: "/auth/login") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        let body = LoginRequest(email: email, password: password)
        
        return request(url: url, method: "POST", body: body)
    }
    
    /// Получить информацию текущего пользователя
    func getCurrentUser() -> AnyPublisher<UserResponse, APIError> {
        guard let url = buildURL(endpoint: "/auth/profile") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url)
    }
    
    /// Изменить пароль
    func changePassword(
        oldPassword: String,
        newPassword: String
    ) -> AnyPublisher<EmptyResponse, APIError> {
        guard let url = buildURL(endpoint: "/auth/change-password") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        struct ChangePasswordRequest: Encodable {
            let old_password: String
            let new_password: String
        }
        
        let body = ChangePasswordRequest(old_password: oldPassword, new_password: newPassword)
        
        return request(url: url, method: "POST", body: body)
    }
        // MARK: - Helper for Events
    
    private func requestEventsList(url: URL) -> AnyPublisher<[EventResponse], APIError> {
        let publisher: AnyPublisher<EventsListResponse, APIError> = request(url: url)
        return publisher
            .map { response in
                print("📦 APIClient: Extracted \(response.events.count) events from list")
                return response.events
            }
            .eraseToAnyPublisher()
    }
        // MARK: - Event Endpoints
    
    /// Получить все события с фильтацией
    func getEvents(
        skip: Int = 0,
        limit: Int = 10,
        city: String? = nil
    ) -> AnyPublisher<[EventResponse], APIError> {
        var endpoint = "/events?skip=\(skip)&limit=\(limit)"
        
        if let city = city, !city.isEmpty {
            endpoint += "&city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)"
        }
        
        guard let url = buildURL(endpoint: endpoint) else {
            print("❌ APIClient: Invalid URL for endpoint: \(endpoint)")
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        print("🌐 APIClient: GET request to \(url.absoluteString)")
        return requestEventsList(url: url)
            .handleEvents(receiveOutput: { events in
                print("✅ APIClient: Received \(events.count) events")
            }, receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ APIClient: Request failed - \(error)")
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Получить событие по ID
    func getEvent(id: Int) -> AnyPublisher<EventResponse, APIError> {
        guard let url = buildURL(endpoint: "/events/\(id)") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url)
    }
    
    /// Получить события по категории
    func getEventsByCategory(category: String) -> AnyPublisher<[EventResponse], APIError> {
        guard let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = buildURL(endpoint: "/events/category/\(encodedCategory)") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return requestEventsList(url: url)
    }
    
    /// Зарегистрировать пользователя на событие
    func registerForEvent(eventId: Int) -> AnyPublisher<EmptyResponse, APIError> {
        guard let url = buildURL(endpoint: "/registrations/register-event") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        let requestBody: [String: Int] = ["event_id": eventId]
        return request(url: url, method: "POST", body: requestBody)
    }
    
    /// Отменить регистрацию на событие
    func unregisterFromEvent(eventId: Int) -> AnyPublisher<EmptyResponse, APIError> {
        guard let url = buildURL(endpoint: "/registrations/unregister/\(eventId)") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url, method: "DELETE")
    }
    
    /// Получить QR токен для текущего пользователя
    func getQRToken() -> AnyPublisher<QRToken, APIError> {
        guard let url = buildURL(endpoint: "/registrations/get-qr") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url)
    }
    
    /// Сгенерировать новый QR токен
    func generateQRToken() -> AnyPublisher<QRToken, APIError> {
        guard let url = buildURL(endpoint: "/registrations/generate-qr") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url, method: "POST")
    }
    
    /// Получить все билеты текущего пользователя
    func getMyTickets() -> AnyPublisher<UserTicketsResponse, APIError> {
        guard let url = buildURL(endpoint: "/registrations/my-tickets") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url)
    }
    
    /// Провериться на событие (check-in)
    func checkInToEvent(eventId: Int) -> AnyPublisher<EmptyResponse, APIError> {
        guard let url = buildURL(endpoint: "/events/\(eventId)/check-in") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url, method: "POST", body: [:] as [String: String])
    }
    
    // MARK: - Additional Account Endpoints
    
    func changeEmail(newEmail: String, password: String) -> AnyPublisher<UserResponse, APIError> {
        guard let url = buildURL(endpoint: "/auth/change-email") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        struct ChangeEmailRequest: Encodable {
            let new_email: String
            let password: String
        }
        
        let payload = ChangeEmailRequest(new_email: newEmail, password: password)
        return request(url: url, method: "POST", body: payload)
    }
    
    // MARK: - Event Management Endpoints
    
    func getMyEvents() -> AnyPublisher<[EventResponse], APIError> {
        guard let url = buildURL(endpoint: "/events/my-events") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url, method: "GET")
            .map { (response: EventsListResponse) in response.events }
            .eraseToAnyPublisher()
    }
    
    func createEvent(
        title: String,
        date: String,
        location: String,
        description: String,
        category: String? = nil,
        image_url: String? = nil
    ) -> AnyPublisher<EventResponse, APIError> {
        guard let url = buildURL(endpoint: "/events") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        struct CreateEventRequest: Encodable {
            let title: String
            let date: String
            let location: String
            let description: String
            let category: String?
            let image_url: String?
        }
        
        let payload = CreateEventRequest(
            title: title,
            date: date,
            location: location,
            description: description,
            category: category,
            image_url: image_url
        )
        
        return request(url: url, method: "POST", body: payload)
    }
    
    func uploadEventImage(eventId: Int, imageData: Data, filename: String) -> AnyPublisher<UploadImageResponse, APIError> {
        guard let url = buildURL(endpoint: "/events/\(eventId)/upload-image") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response in
                guard let httpResponse = response.response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorizedError
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                }
                
                return response.data
            }
            .decode(type: UploadImageResponse.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let error = error as? APIError {
                    return error
                }
                return .decodingError
            }
            .eraseToAnyPublisher()
    }
    
    func updateEvent(
        eventId: Int,
        title: String? = nil,
        date: String? = nil,
        location: String? = nil,
        description: String? = nil,
        category: String? = nil
    ) -> AnyPublisher<EventResponse, APIError> {
        guard let url = buildURL(endpoint: "/events/\(eventId)") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        struct UpdateEventRequest: Encodable {
            let title: String?
            let date: String?
            let location: String?
            let description: String?
            let category: String?
        }
        
        let payload = UpdateEventRequest(
            title: title,
            date: date,
            location: location,
            description: description,
            category: category
        )
        
        return request(url: url, method: "PUT", body: payload)
    }
    
    // MARK: - QR Scanner Endpoints
    
    func scanQRCode(token: String, eventId: Int) -> AnyPublisher<QRScanResponse, APIError> {
        guard var url = buildURL(endpoint: "/registrations/scan-with-event/\(token)") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        url.append(queryItems: [URLQueryItem(name: "event_id", value: String(eventId))])
        
        return request(url: url, method: "GET")
    }
    
    // MARK: - Cities Endpoints
    
    /// Получить список городов
    func getCities() -> AnyPublisher<[CityResponse], APIError> {
        guard let url = buildURL(endpoint: "/cities") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return request(url: url)
    }
}

// MARK: - City Response
struct CityResponse: Codable {
    let id: Int
    let name: String
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Keychain Manager
class KeychainManager {
    static let service = "com.soberemsya.app"
    static let account = "authToken"
    
    static func saveToken(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: token.data(using: .utf8) ?? Data()
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        
        return nil
    }
    
    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

struct QRScanResponse: Codable {
    let user_id: Int
    let email: String
    let username: String
    let full_name: String
    let is_registered: Bool
    let registered_at: String?
    let tickets: [Event]?
}
