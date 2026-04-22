import SwiftUI

/// Карточка секции в стиле Apple Health
struct SectionCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let description: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(DesignConstants.Typography.headline)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                    
                    Spacer()
                }
                
                Text(description)
                    .font(DesignConstants.Typography.footnote)
                    .foregroundColor(DesignConstants.Colors.textSecondary)
            }
            
            Divider()
                .background(DesignConstants.Colors.separator)
            
            content
        }
        .padding(DesignConstants.padding)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
        .shadow(
            color: DesignConstants.Shadows.card.color,
            radius: DesignConstants.Shadows.card.radius,
            x: DesignConstants.Shadows.card.x,
            y: DesignConstants.Shadows.card.y
        )
        .padding(.horizontal, DesignConstants.padding)
    }
}

#Preview {
    SectionCard(
        title: "Название раздела",
        description: "Описание с дополнительной информацией"
    ) {
        TextField("Введите текст", text: .constant(""))
            .textFieldStyle(.roundedBorder)
    }
    .background(DesignConstants.Colors.groupedBackground)
}
