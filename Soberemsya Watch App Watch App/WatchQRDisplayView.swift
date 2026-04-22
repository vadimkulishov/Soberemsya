import SwiftUI

struct WatchQRDisplayView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    let token: String
    let userName: String

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // QR Code image from iPhone
                if let imageData = connectivity.qrImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                } else {
                    // Fallback: show token text
                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("QR-код загружается...")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkGray).opacity(0.3))
                    .cornerRadius(8)
                }

                // User name
                if !userName.isEmpty {
                    Text(userName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                }

                // Refresh button
                Button(action: {
                    connectivity.requestQRFromPhone()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Билет")
    }
}
