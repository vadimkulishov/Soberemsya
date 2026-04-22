import Foundation
import Combine

/// ViewModel для управления регистрацией пользователя и его события
class RegisterViewModel: ObservableObject {
    @Published var registeredEventIds: [Int] = []
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var fullName: String = ""
    @Published var city: String = "Москва"
    @Published var phone: String = ""
    @Published var cities: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: APIError? = nil
    @Published var registrationComplete: Bool = false
    
    private var authManager = AuthManager.shared
    private var eventService = EventService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCities()
        observeAuthState()
    }
    
    // MARK: - Setup
    
    private func observeAuthState() {
        authManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user = user {
                    self?.registeredEventIds = user.registeredEventIds
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Cities
    
    func loadCities() {
        APIClient.shared.getCities()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // Handle error if needed
            } receiveValue: { [weak self] response in
                self?.cities = response.map { $0.name }.sorted()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Registration
    
    func register() {
        guard validateForm() else {
            error = APIError.unknown("Пожалуйста, заполните все поля корректно")
            return
        }
        
        isLoading = true
        error = nil
        
        authManager.register(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
            city: city,
            phone: phone.isEmpty ? nil : phone
        )
    }
    
    // MARK: - Event Registration
    
    func toggleEventRegistration(_ eventId: Int) {
        if registeredEventIds.contains(eventId) {
            eventService.unregisterFromEvent(eventId: eventId) { [weak self] (success: Bool, error: APIError?) in
                if success {
                    self?.registeredEventIds.removeAll { $0 == eventId }
                }
            }
        } else {
            eventService.registerForEvent(eventId: eventId) { [weak self] (success: Bool, error: APIError?) in
                if success {
                    self?.registeredEventIds.append(eventId)
                }
            }
        }
    }
    
    func isEventRegistered(_ eventId: Int) -> Bool {
        return registeredEventIds.contains(eventId)
    }
    
    func getRegisteredEventCount() -> Int {
        return registeredEventIds.count
    }
    
    // MARK: - Validation
    
    private func validateForm() -> Bool {
        return !username.isEmpty &&
               username.count >= 3 &&
               !email.isEmpty &&
               isValidEmail(email) &&
               !fullName.isEmpty &&
               !password.isEmpty &&
               password.count >= 6 &&
               password == confirmPassword
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
