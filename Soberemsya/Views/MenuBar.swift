import SwiftUI

struct MenuBar: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        TabView {
            Tab("Главная", systemImage: "house.fill") {
                HomeView()
            }

            Tab("Поиск", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }

            if authManager.userRole == "user" {
                Tab("Мой билет", systemImage: "qrcode") {
                    RegisterView()
                }
            }

            if authManager.userRole == "organizer" || authManager.userRole == "admin" {
                Tab("Скан", systemImage: "qrcode.viewfinder") {
                    QRScannerView()
                }
                
                Tab("События", systemImage: "calendar.badge.plus") {
                    MyEventsView()
                }
            }

            Tab("Аккаунт", systemImage: "person.circle.fill") {
                AccountView()
            }
        }
        .tint(DesignConstants.Colors.primary)
    }
}

#Preview {
    MenuBar()
        .environmentObject(AuthManager.shared)
        .environmentObject(ThemeManager.shared)
}
