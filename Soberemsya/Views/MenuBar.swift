import SwiftUI

struct MenuBar: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some View {
        TabView {
            Tab ("Главаня", systemImage: "house") {
                HomeView()
            }
            Tab ("Аккаунт", systemImage: "person.circle") {
                AccountView()
            }
            Tab ("Настройки", systemImage: "gearshape") {
                SetingsView()
            }
            if isLoggedIn{
                Tab(role: .search) {
                    } label: {
                        Image(systemName: "plus")
                    }
            }
        }
    }
}
