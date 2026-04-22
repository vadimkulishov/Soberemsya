import SwiftUI

@main
struct SoberemsyaApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var authManager = AuthManager.shared
    private let connectivityManager = PhoneConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch themeManager.selectedTheme {
                case .system:
                    Color(.systemBackground).ignoresSafeArea()
                case .light:
                    Color.white.ignoresSafeArea()
                case .dark:
                    Color.black.ignoresSafeArea()
                }

                ContentView()
                    .environmentObject(themeManager)
                    .environmentObject(authManager)
                    .preferredColorScheme(themeManager.selectedTheme.colorScheme)
            }
        }
    }
}
