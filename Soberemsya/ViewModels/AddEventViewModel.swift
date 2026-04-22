import Foundation
import Combine
import UIKit

class AddEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var category: String = ""
    @Published var date: String = ""
    @Published var location: String = ""
    @Published var image_url: String? = nil
    @Published var isCreating: Bool = false
    @Published var error: APIError? = nil
    @Published var selectedImage: UIImage? = nil
    
    // Legacy properties (kept for compatibility)
    @Published var selectedCategory: String = ""
    @Published var selectedDate: Date = Date()
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var capacity: Int = 0
    @Published var eventType: String = "Открытое"
    
    let categories = ["Музыка", "Спорт", "Театр", "Кино", "Образование", "Еда", "Путешествия", "Технологии"]
    let eventTypes = ["Открытое", "Закрытое", "По приглашениям"]
    
    private var authManager = AuthManager.shared
    private var apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Event Creation
    
    func createEvent() {
        print("📝 AddEventViewModel.createEvent() called")
        print("📋 Form valid: \(isFormValid())")
        print("🔐 Logged in: \(authManager.isLoggedIn)")
        print("👤 User role: \(authManager.currentUser?.role ?? "unknown")")
        
        guard validateForm() else {
            print("❌ Form validation failed")
            error = APIError.unknown("Пожалуйста, заполните все обязательные поля")
            return
        }
        
        guard authManager.isLoggedIn else {
            print("❌ Not logged in")
            error = APIError.unknown("Необходимо войти в аккаунт")
            return
        }
        
        isCreating = true
        error = nil
        
        print("📤 Sending to API: title=\(title), category=\(category), date=\(date)")
        
        // If user selected an image, upload it first
        if let selectedImage = selectedImage {
            print("🖼️ User selected image, uploading...")
            uploadImage(selectedImage)
                .flatMap { imageUrl in
                    print("✅ Image uploaded: \(imageUrl)")
                    self.image_url = imageUrl
                    return self.apiClient.createEvent(
                        title: self.title,
                        date: self.date,
                        location: self.location,
                        description: self.description,
                        category: self.category,
                        image_url: imageUrl
                    )
                }
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isCreating = false
                        switch completion {
                        case .finished:
                            print("✅ Event created successfully!")
                            self?.resetForm()
                        case .failure(let error):
                            print("❌ Event creation error: \(error)")
                            self?.error = error
                        }
                    },
                    receiveValue: { [weak self] _ in
                        print("✅ Event response received")
                        self?.resetForm()
                    }
                )
                .store(in: &cancellables)
        } else {
            print("ℹ️ No image selected")
            // No image selected, create event without image
            let _ = apiClient.createEvent(
                title: title,
                date: date,
                location: location,
                description: description,
                category: category,
                image_url: nil
            )
            .sink(receiveCompletion: { [weak self] completion in
                self?.isCreating = false
                switch completion {
                case .finished:
                    print("✅ Event created successfully (no image)!")
                    self?.resetForm()
                case .failure(let error):
                    print("❌ Event creation error: \(error)")
                    self?.error = error
                }
            }, receiveValue: { [weak self] _ in
                print("✅ Event response received")
                self?.resetForm()
            })
            .store(in: &cancellables)
        }
    }
    
    private func uploadImage(_ image: UIImage) -> AnyPublisher<String, APIError> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return Fail(error: APIError.unknown("Не удалось обработать изображение"))
                .eraseToAnyPublisher()
        }
        
        // Create a temporary event first to get an ID, then upload image to it
        // For now, we'll create event first without image, then upload
        // In production, you might want to refactor this flow
        
        return Just(imageData)
            .setFailureType(to: APIError.self)
            .flatMap { data in
                // For MVP, return a base64 encoded image as data URL
                let base64String = data.base64EncodedString()
                let dataUrl = "data:image/jpeg;base64,\(base64String)"
                return Just(dataUrl)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func resetForm() {
        title = ""
        description = ""
        category = ""
        date = ""
        location = ""
        image_url = nil
        selectedImage = nil
        selectedCategory = ""
        selectedDate = Date()
        startTime = Date()
        endTime = Date()
        capacity = 0
    }
    
    func isFormValid() -> Bool {
        return !title.isEmpty &&
               !category.isEmpty &&
               !location.isEmpty &&
               !date.isEmpty &&
               !description.isEmpty
    }
    
    private func validateForm() -> Bool {
        return isFormValid()
    }
}
