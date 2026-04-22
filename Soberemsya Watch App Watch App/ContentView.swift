import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        NavigationStack {
            if let token = connectivity.qrToken {
                WatchQRDisplayView(
                    token: token,
                    userName: connectivity.userName ?? ""
                )
            } else {
                notLoggedInView
            }
        }
    }

    private var notLoggedInView: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone.and.arrow.right.inward")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("Откройте приложение на iPhone")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("Войдите в аккаунт, чтобы получить QR-код")
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .foregroundStyle(.tertiary)

            if connectivity.isLoading {
                ProgressView()
                    .padding(.top, 4)
            } else {
                Button(action: {
                    connectivity.requestQRFromPhone()
                }) {
                    Label("Обновить", systemImage: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.top, 4)
            }
        }
        .padding()
    }
}
