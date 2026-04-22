import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuBar()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
        .environmentObject(ThemeManager.shared)
}
