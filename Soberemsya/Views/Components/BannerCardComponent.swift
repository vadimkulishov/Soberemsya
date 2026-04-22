import SwiftUI

/// Карточка баннера в стиле Apple Health - минималистичная и элегантная
struct BannerCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    var image: String? = nil
    var onTap: (() -> Void)? = nil
    
    // Приглушённые цвета как в Health
    let bannerColors: [Color] = [
        DesignConstants.Colors.categoryMusic,
        DesignConstants.Colors.categorySports,
        DesignConstants.Colors.categoryArt,
        DesignConstants.Colors.categoryTech,
        DesignConstants.Colors.categoryNature
    ]
    
    var bannerColor: Color {
        let index = abs(title.hashValue) % bannerColors.count
        return bannerColors[index]
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                // Минималистичный дизайн с акцентом на контент
                VStack(alignment: .leading, spacing: 12) {
                    // Иконка категории
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(bannerColor)
                    
                    Spacer()
                    
                    // Метка
                    Text("СПЕЦИАЛЬНОЕ")
                        .font(DesignConstants.Typography.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                        .tracking(0.5)
                    
                    // Заголовок
                    Text(title)
                        .font(DesignConstants.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Стрелка
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(bannerColor)
                    }
                }
                .padding(DesignConstants.largePadding)
            }
            .frame(height: 200)
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous)
                    .strokeBorder(bannerColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: DesignConstants.Shadows.card.color,
                radius: DesignConstants.Shadows.card.radius,
                x: DesignConstants.Shadows.card.x,
                y: DesignConstants.Shadows.card.y
            )
        }
        .buttonStyle(PressableCardButtonStyle())
    }
}

#Preview {
    BannerCardComponent(title: "Получите скидку 50% на первый билет")
        .frame(width: 280)
        .padding()
        .background(Color(.systemGroupedBackground))
}
