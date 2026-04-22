import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Тёмная"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "app_theme")
        }
    }
    
    private init() {
        let savedTheme = UserDefaults.standard.string(forKey: "app_theme")
        self.selectedTheme = AppTheme(rawValue: savedTheme ?? "") ?? .system
    }
    
    func setTheme(_ theme: AppTheme) {
        selectedTheme = theme
    }
}
