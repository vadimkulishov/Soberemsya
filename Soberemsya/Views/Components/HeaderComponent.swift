import SwiftUI

/// Хедер в стиле Apple Health - минималистичный и элегантный
struct HeaderComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let city: String
    let onCityTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Простой хедер без градиентов
            VStack(alignment: .leading, spacing: DesignConstants.padding) {
                // Верхняя строка с городом и уведомлениями
                HStack {
                    Button(action: onCityTap) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(city)
                                .font(DesignConstants.Typography.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(DesignConstants.Colors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            DesignConstants.Colors.primary.opacity(0.1)
                        )
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                            .padding(8)
                    }
                }
                
                // Приветствие
                VStack(alignment: .leading, spacing: 4) {
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
            .background(DesignConstants.Colors.background)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HeaderComponent(city: "Москва") {}
}

