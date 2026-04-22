import SwiftUI

struct ErrorStateView: View {
    let error: LoadingError
    let onRetry: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(errorColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: error.icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(errorColor)
            }
            
            VStack(spacing: 8) {
                Text(error.message)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                
                Text(errorSubtitle)
                    .font(.system(size: 14))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Повторить")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            DesignConstants.Colors.primary,
                            DesignConstants.Colors.primary.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: DesignConstants.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(errorColor.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
            radius: 12,
            x: 0,
            y: 4
        )
    }
    
    private var errorColor: Color {
        switch error {
        case .timeout, .noInternet:
            return DesignConstants.Colors.warning
        case .serverError, .unknown:
            return DesignConstants.Colors.error
        }
    }
    
    private var errorSubtitle: String {
        switch error {
        case .timeout:
            return "Проверьте подключение к интернету\nи попробуйте снова"
        case .noInternet:
            return "Убедитесь, что устройство\nподключено к сети"
        case .serverError:
            return "Мы уже работаем над этим\nПопробуйте позже"
        case .unknown:
            return "Что-то пошло не так\nПопробуйте ещё раз"
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 30) {
        ErrorStateView(error: .noInternet) {
            print("Retry tapped")
        }
        
        ErrorStateView(error: .serverError) {
            print("Retry tapped")
        }
        
        ErrorStateView(error: .timeout) {
            print("Retry tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
