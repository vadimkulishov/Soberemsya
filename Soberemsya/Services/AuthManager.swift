import Foundation
import Combine

/// Менеджер для управления авторизацией и сессией пользователя
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    @Published var userRole: String = "user"  // user, organizer, admin
    @Published var isLoading: Bool = false
    @Published var error: APIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkIfLoggedIn()
    }
    
    // MARK: - Check Login Status
    
    /// Проверить есть ли сохраненный токен и загрузить данные пользователя
    func checkIfLoggedIn() {
        if APIClient.shared.authToken != nil {
            loadCurrentUser()
        } else {
            isLoggedIn = false
        }
    }
    
    // MARK: - Registration
    
    /// Регистрация нового пользователя
    func register(
        username: String,
        email: String,
        password: String,
        fullName: String,
        city: String,
        phone: String? = nil
    ) {
        isLoading = true
        error = nil
        
        APIClient.shared.register(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
            city: city,
            phone: phone
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            
            if case let .failure(error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] response in
            // Сохраняем токен
            APIClient.shared.authToken = response.accessToken
            
            // Преобразуем ответ в нашу User модель
            let user = User(
                id: response.user.id,
                username: response.user.username,
                name: response.user.fullName ?? response.user.username,
                email: response.user.email,
                city: response.user.city ?? "",
                phone: response.user.phone,
                qrCodeData: response.user.qrCodeData,
                profileCompleted: response.user.profileCompleted ?? false,
                isActive: response.user.isActive ?? true
            )
            
            self?.currentUser = user
            self?.userRole = response.user.role ?? "user"
            self?.isLoggedIn = true
            self?.sendQRTokenToWatch()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Login
    
    /// Вход пользователя
    func login(email: String, password: String) {
        isLoading = true
        error = nil
        
        APIClient.shared.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                // Сохраняем токен
                APIClient.shared.authToken = response.accessToken
                
                // Преобразуем ответ в нашу User модель
                let user = User(
                    id: response.user.id,
                    username: response.user.username,
                    name: response.user.fullName ?? response.user.username,
                    email: response.user.email,
                    city: response.user.city ?? "",
                    phone: response.user.phone,
                    qrCodeData: response.user.qrCodeData,
                    profileCompleted: response.user.profileCompleted ?? false,
                    isActive: response.user.isActive ?? true
                )
                
                self?.currentUser = user
                self?.userRole = response.user.role ?? "user"
                self?.isLoggedIn = true
                self?.sendQRTokenToWatch()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Current User
    
    /// Загрузить информацию текущего пользователя
    func loadCurrentUser() {
        isLoading = true
        error = nil
        
        APIClient.shared.getCurrentUser()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                    // Если 401, значит токен невалидный - выходим из системы
                    if case .unauthorizedError = error {
                        self?.logout()
                    }
                }
            } receiveValue: { [weak self] response in
                let user = User(
                    id: response.id,
                    username: response.username,
                    name: response.fullName ?? response.username,
                    email: response.email,
                    city: response.city ?? "",
                    phone: response.phone,
                    qrCodeData: response.qrCodeData,
                    profileCompleted: response.profileCompleted ?? false,
                    isActive: response.isActive ?? true
                )
                
                self?.currentUser = user
                self?.userRole = response.role ?? "user"
                self?.isLoggedIn = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: - QR Code
    
    /// Получить QR код пользователя
    func loadUserQRCode(completion: @escaping (String?, APIError?) -> Void) {
        APIClient.shared.getQRToken()
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case let .failure(error) = result {
                    completion(nil, error)
                }
            } receiveValue: { response in
                if var user = self.currentUser {
                    user.qrCodeData = response.token
                    self.currentUser = user
                }
                completion(response.token, nil)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Watch Connectivity
    
    /// Отправить QR токен на Apple Watch
    func sendQRTokenToWatch() {
        loadUserQRCode { [weak self] token, _ in
            guard let token = token, let user = self?.currentUser else { return }
            PhoneConnectivityManager.shared.sendQRToken(
                token,
                expiresAt: "",
                userName: user.name
            )
        }
    }
    
    // MARK: - Logout
    
    /// Выход из системы
    func logout() {
        APIClient.shared.authToken = nil
        currentUser = nil
        userRole = "user"
        isLoggedIn = false
        error = nil
        PhoneConnectivityManager.shared.clearWatchData()
    }
    
    // MARK: - Change Password
    
    /// Изменить пароль
    func changePassword(
        oldPassword: String,
        newPassword: String,
        completion: @escaping (Bool, APIError?) -> Void
    ) {
        APIClient.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case let .failure(error) = result {
                    completion(false, error)
                }
            } receiveValue: { _ in
                completion(true, nil)
            }
            .store(in: &cancellables)
    }
}
