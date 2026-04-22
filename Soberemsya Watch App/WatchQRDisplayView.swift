import SwiftUI
import CoreImage.CIFilterBuiltins

struct WatchQRDisplayView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    let token: String
    let userName: String

    @State private var qrImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // QR Code
                if let image = qrImage {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                } else {
                    ProgressView()
                        .frame(height: 120)
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
        .onAppear {
            generateQR()
        }
        .onChange(of: token) {
            generateQR()
        }
    }

    private func generateQR() {
        guard !token.isEmpty else { return }

        guard let data = token.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return }

        filter.setValue(data, forKey: "inputMessage")

        guard let ciImage = filter.outputImage else { return }

        let transform = CGAffineTransform(scaleX: 8, y: 8)
        let scaled = ciImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return }

        qrImage = UIImage(cgImage: cgImage)
    }
}
