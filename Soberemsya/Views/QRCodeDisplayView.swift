import SwiftUI

struct QRCodeDisplayView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ticketViewModel = TicketViewModel()
    @State private var showCopiedToast = false
    
    var body: some View {
        ZStack {
            DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // QR Code Card
                    qrCodeCard
                    
                    // Actions
                    actionsSection
                }
                .padding(DesignConstants.padding)
            }
            
            // Copied toast
            if showCopiedToast {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignConstants.Colors.success)
                        Text("Токен скопирован")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
                    .padding(.bottom, 32)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Мой QR-код")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if ticketViewModel.qrToken == nil {
                ticketViewModel.getQRCode()
            }
        }
        .errorAlert(error: $ticketViewModel.error)
    }
    
    // MARK: - QR Code Card
    
    private var qrCodeCard: some View {
        VStack(spacing: 0) {
            if let token = ticketViewModel.qrToken {
                VStack(spacing: 20) {
                    // QR Code
                    QRCodeView(data: token.token)
                        .frame(width: 220, height: 220)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(DesignConstants.largeCornerRadius)
                    
                    // Expiration info
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 13))
                            .foregroundColor(DesignConstants.Colors.textTertiary)
                        
                        Text("Действителен до:")
                            .font(.system(size: 13))
                            .foregroundColor(DesignConstants.Colors.textTertiary)
                        
                        Text(formatDate(token.expiresAt))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(DesignConstants.Colors.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                    .cornerRadius(DesignConstants.smallCornerRadius)
                }
                .padding(DesignConstants.largePadding)
            } else {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    
                    Text("Загрузка QR-кода...")
                        .font(.system(size: 14))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button(action: copyToken) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                    Text("Скопировать токен")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DesignConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(DesignConstants.cornerRadius)
            }
            .disabled(ticketViewModel.qrToken == nil)
            .opacity(ticketViewModel.qrToken == nil ? 0.5 : 1)
            
            Button(action: {
                ticketViewModel.generateQRCode()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                    Text("Обновить QR-код")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DesignConstants.Colors.primary.opacity(0.1))
                .foregroundColor(DesignConstants.Colors.primary)
                .cornerRadius(DesignConstants.cornerRadius)
            }
        }
    }
    
    // MARK: - Methods
    
    private func copyToken() {
        guard let token = ticketViewModel.qrToken?.token else { return }
        UIPasteboard.general.string = token
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "ru_RU")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// QR Code View - Simple and Reliable
struct QRCodeView: UIViewRepresentable {
    let data: String
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        
        if let qrImage = generateQRCode(from: data) {
            let imageView = UIImageView(image: qrImage)
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .white
            
            container.addSubview(imageView)
            imageView.frame = container.bounds
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            let label = UILabel()
            label.text = "Ошибка генерации QR"
            label.textColor = .red
            label.textAlignment = .center
            label.numberOfLines = 0
            
            container.addSubview(label)
            label.frame = container.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private func generateQRCode(from string: String) -> UIImage? {
        guard !string.isEmpty,
              let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaled = ciImage.transformed(by: transform)
        
        let context = CIContext(options: [.useSoftwareRenderer: true])
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    NavigationStack {
        QRCodeDisplayView()
    }
}
