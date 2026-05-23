import SwiftUI

/// Хедер главного экрана.
struct HeaderComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let city: String
    let onCityTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.padding) {
            HStack {
                Button(action: onCityTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text(city)
                            .font(DesignConstants.Typography.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(DesignConstants.Colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DesignConstants.Colors.primary.opacity(0.1), in: Capsule())
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme), in: Circle())
                        .overlay(Circle().strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.7), lineWidth: 1))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Соберёмся?")
                    .font(DesignConstants.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Text("Откройте лучшие мероприятия рядом")
                    .font(DesignConstants.Typography.subheadline)
                    .foregroundColor(DesignConstants.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DesignConstants.padding)
        .padding(.top, 8)
        .padding(.bottom, DesignConstants.padding)
        .background(
            LinearGradient(
                colors: [
                    DesignConstants.Colors.mainBackground(colorScheme: colorScheme),
                    DesignConstants.Colors.secondaryBackground.opacity(colorScheme == .dark ? 0.6 : 0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HeaderComponent(city: "Москва") {}
}
