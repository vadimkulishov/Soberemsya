import SwiftUI

/// Карточка категории в стиле Apple Health
struct CategoryCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let category: EventCategory
    var onTap: (() -> Void)? = nil
    
    var color: Color {
        Color(hex: category.color)
    }
    
    var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.14))
                    .frame(width: 56, height: 56)

                Image(systemName: category.icon)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(color)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 5) {
                Text(category.title)
                    .font(DesignConstants.Typography.headline)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .lineLimit(1)

                Label {
                    Text("События")
                        .font(DesignConstants.Typography.caption)
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                } icon: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(color)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignConstants.padding)
        .frame(height: 150)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: DesignConstants.Shadows.card.color,
            radius: DesignConstants.Shadows.card.radius,
            x: DesignConstants.Shadows.card.x,
            y: DesignConstants.Shadows.card.y
        )
    }
    
    var body: some View {
        if onTap != nil {
            Button(action: { onTap?() }) {
                cardContent
            }
            .buttonStyle(PressableCardButtonStyle(pressedScale: 0.96))
        } else {
            cardContent
        }
    }
}

#Preview {
    let category = EventCategory(
        title: "Музыка",
        icon: "music.note",
        color: "#FF453A"
    )
    return CategoryCardComponent(category: category)
        .padding()
        .background(DesignConstants.Colors.groupedBackground)
}
