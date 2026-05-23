import SwiftUI

struct QRCodeDisplayView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var ticketViewModel = TicketViewModel()
    @State private var showCopiedToast = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                QRCodeHeroCard(
                    colorScheme: colorScheme,
                    token: ticketViewModel.qrToken,
                    title: "Ваш QR-билет",
                    subtitle: "Покажите код на входе или у стойки регистрации."
                )

                VStack(spacing: 10) {
                    QRCodeActionButton(
                        title: "Скопировать токен",
                        icon: "doc.on.doc.fill",
                        style: .primary
                    ) {
                        copyToken()
                    }
                    .disabled(ticketViewModel.qrToken == nil)
                    .opacity(ticketViewModel.qrToken == nil ? 0.55 : 1)

                    QRCodeActionButton(
                        title: "Обновить QR-код",
                        icon: "arrow.clockwise",
                        style: .secondary
                    ) {
                        ticketViewModel.generateQRCode()
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(screenBackground)
        .navigationTitle("Мой QR-код")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            copiedToast
        }
        .onAppear {
            if ticketViewModel.qrToken == nil {
                ticketViewModel.getQRCode()
            }
        }
        .errorAlert(error: $ticketViewModel.error)
    }

    private var screenBackground: some View {
        ZStack {
            DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
            LinearGradient(
                colors: [
                    DesignConstants.Colors.primary.opacity(colorScheme == .dark ? 0.16 : 0.09),
                    Color.clear,
                    DesignConstants.Colors.success.opacity(colorScheme == .dark ? 0.08 : 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var copiedToast: some View {
        if showCopiedToast {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignConstants.Colors.success)
                Text("Токен скопирован")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func copyToken() {
        guard let token = ticketViewModel.qrToken?.token else { return }
        UIPasteboard.general.string = token

        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCopiedToast = false
            }
        }
    }
}

struct QRCodeHeroCard: View {
    let colorScheme: ColorScheme
    let token: QRToken?
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 18) {
            header

            if let token {
                VStack(spacing: 16) {
                    qrPanel(token: token)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if !token.expiresAt.isEmpty {
                        Label("Действителен до \(formatDate(token.expiresAt))", systemImage: "clock.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme), in: Capsule())
                    }
                }
            } else {
                VStack(spacing: 14) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Загрузка QR-кода...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.7), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.16 : 0.05), radius: 12, x: 0, y: 6)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DesignConstants.Colors.primary, DesignConstants.Colors.success],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                Text("Быстрый вход на мероприятие")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
            }

            Spacer(minLength: 0)
        }
    }

    private func qrPanel(token: QRToken) -> some View {
        VStack(spacing: 12) {
            QRCodeView(data: token.token)
                .frame(width: 220, height: 220)
                .padding(18)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            Text(shortToken(token.token))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(DesignConstants.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
        )
    }

    private func shortToken(_ value: String) -> String {
        guard value.count > 20 else { return value }
        return "\(value.prefix(10))...\(value.suffix(8))"
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

struct QRCodeActionButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let icon: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(backgroundView)
            .foregroundColor(foregroundColor)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DesignConstants.Colors.primary, DesignConstants.Colors.success],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        case .secondary:
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignConstants.Colors.primary.opacity(0.1))
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DesignConstants.Colors.primary
        }
    }
}

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
