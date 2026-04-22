import SwiftUI

/// Красивая карточка с информацией о результате сканирования QR кода
struct ScanResultCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    
    let visitosName: String
    let visitorEmail: String
    let visitorUsername: String
    let isRegistered: Bool
    let registeredDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with status
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(visitosName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                    
                    Text("@\(visitorUsername)")
                        .font(.caption)
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isRegistered ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isRegistered ? DesignConstants.Colors.success : DesignConstants.Colors.error)
            }
            
            Divider()
            
            // Contact info
            VStack(alignment: .leading, spacing: 12) {
                Label(visitorEmail, systemImage: "envelope.fill")
                    .font(.caption)
                    .foregroundColor(DesignConstants.Colors.primary)
                    .lineLimit(1)
            }
            
            Divider()
            
            // Registration status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Регистрация")
                        .font(.caption)
                        .foregroundColor(DesignConstants.Colors.textTertiary)
                    
                    if let date = registeredDate {
                        Text(DateFormatter.shortDateTimeFormat.string(from: date))
                            .font(.caption)
                            .foregroundColor(DesignConstants.Colors.textPrimary)
                    } else {
                        Text("Нет данных")
                            .font(.caption)
                            .foregroundColor(DesignConstants.Colors.textTertiary)
                            .italic()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isRegistered ? DesignConstants.Colors.success : DesignConstants.Colors.error)
                            .frame(width: 8, height: 8)
                        
                        Text(isRegistered ? "Активен" : "Неактивен")
                            .font(.caption)
                            .foregroundColor(isRegistered ? DesignConstants.Colors.success : DesignConstants.Colors.error)
                    }
                }
            }
        }
        .padding(DesignConstants.padding)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .stroke(
                    (isRegistered ? DesignConstants.Colors.success : DesignConstants.Colors.error).opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ScanResultCardComponent(
            visitosName: "Иван Петров",
            visitorEmail: "ivan@example.com",
            visitorUsername: "ivanpetrov",
            isRegistered: true,
            registeredDate: Date()
        )
        
        ScanResultCardComponent(
            visitosName: "Мария Сидорова",
            visitorEmail: "maria@example.com",
            visitorUsername: "marioosumka",
            isRegistered: false,
            registeredDate: nil
        )
    }
    .padding()
    .environmentObject(ThemeManager.shared)
}
