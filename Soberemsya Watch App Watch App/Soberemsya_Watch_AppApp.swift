import SwiftUI

@main
struct Soberemsya_Watch_App_Watch_AppApp: App {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(connectivityManager)
        }
    }
}
