import SwiftUI

struct EmptyEventsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignConstants.Colors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(DesignConstants.Colors.primary)
            }
            
            VStack(spacing: 6) {
                Text("Нет мероприятий")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                
                Text("Попробуйте изменить фильтры")
                    .font(.system(size: 14))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    EmptyEventsView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
