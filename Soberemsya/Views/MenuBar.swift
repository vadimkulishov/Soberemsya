import SwiftUI

struct MenuBar: View {
    var body: some View {
        TabView{
            HomeView()
                .tabItem{
                    Label("Главная", systemImage: "house")
                }
            AccountView()
                .tabItem{
                    Label("Аккаунт", systemImage: "person.crop.circle")
                }
            SetingsView()
                .tabItem{
                    Label("Настройки", systemImage: "gearshape")
                }
        }
    }
}
