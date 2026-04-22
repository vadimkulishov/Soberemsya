import Foundation
import Combine
import SwiftUI

/// ViewModel для управления аккаунтом пользователя
class AccountViewModel: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var textSize: Double = 16
    @Published var accentColor: Color = .blue
    @Published var isLoading: Bool = false
    @Published var error: APIError? = nil
    @Published var isChangingPassword: Bool = false

    // Реактивные свойства — синхронизируются с AuthManager
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil

    private let authManager = AuthManager.shared
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    private enum StorageKeys {
        static let isDarkMode = "app_isDarkMode"
        static let textSize = "app_textSize"
        static let accentColorHex = "app_accentColorHex"
    }

    init() {
        loadSettings()

        // Синхронизируем начальное состояние
        isLoggedIn = authManager.isLoggedIn
        currentUser = authManager.currentUser

        // Подписываемся на изменения AuthManager — при входе/выходе AccountView обновится
        authManager.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoggedIn)

        authManager.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }

    // MARK: - Auth

    func logout() {
        authManager.logout()
    }

    // MARK: - Settings

    func loadSettings() {
        isDarkMode = defaults.bool(forKey: StorageKeys.isDarkMode)
        let savedTextSize = defaults.double(forKey: StorageKeys.textSize)
        textSize = savedTextSize > 0 ? savedTextSize : 16
        let colorHex = defaults.string(forKey: StorageKeys.accentColorHex) ?? "#007AFF"
        accentColor = Color(hex: colorHex)
    }

    func saveSettings() {
        defaults.set(isDarkMode, forKey: StorageKeys.isDarkMode)
        defaults.set(textSize, forKey: StorageKeys.textSize)
        defaults.set(accentColor.toHex(), forKey: StorageKeys.accentColorHex)
    }

    // MARK: - Password

    func changePassword(oldPassword: String, newPassword: String) {
        isChangingPassword = true
        authManager.changePassword(oldPassword: oldPassword, newPassword: newPassword) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isChangingPassword = false
                self?.error = success ? nil : error
            }
        }
    }
}
