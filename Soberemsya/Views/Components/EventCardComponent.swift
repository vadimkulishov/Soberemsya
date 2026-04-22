import SwiftUI

/// Карточка события в стиле Apple Health - чистая, минималистичная
struct EventCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let event: Event
    
    var categoryColor: Color {
        DesignConstants.Colors.categoryColor(for: event.category)
    }
    
    /// URL изображения: реальное от бэкенда или фолбэк по категории
    var displayImageUrl: String {
        if let imageUrl = event.imageName, !imageUrl.isEmpty {
            return imageUrl
        }
        return DesignConstants.categoryFallbackImageUrl(for: event.category)
    }

    var body: some View {
        NavigationLink(destination: EventDetailView(event: event)) {
            VStack(alignment: .leading, spacing: 0) {
                // Изображение события
                ZStack(alignment: .topLeading) {
                    // Фоновый градиент (виден пока грузится фото)
                    DesignConstants.Colors.categoryGradient(for: event.category)
                        .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)

                    // Фото — нативный AsyncImage (iOS 15+)
                    AsyncImage(url: URL(string: displayImageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            // Если фото не загрузилось — оставляем градиент
                            Color.clear
                        case .empty:
                            Color.clear
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        @unknown default:
                            Color.clear
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
                    .clipped()

                    // Градиент снизу для плавного перехода и читаемости
                    VStack {
                        Spacer()
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.45)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 70)
                    }
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)

                    // Бейдж категории с иконкой
                    HStack(spacing: 4) {
                        Image(systemName: categoryIcon(for: event.category))
                            .font(.system(size: 10, weight: .semibold))
                        Text(event.category)
                            .font(DesignConstants.Typography.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.35))
                            .background(Capsule().fill(.ultraThinMaterial))
                    )
                    .padding(12)
                }
                .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
                
                // Информация о событии
                VStack(alignment: .leading, spacing: 10) {
                    // Заголовок
                    Text(event.title)
                        .font(DesignConstants.Typography.headline)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Дата и место - как в Health app
                    VStack(alignment: .leading, spacing: 6) {
                        Label {
                            Text(event.date)
                                .font(DesignConstants.Typography.subheadline)
                                .foregroundColor(DesignConstants.Colors.textSecondary)
                        } icon: {
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(categoryColor)
                        }
                        
                        Label {
                            Text(event.location)
                                .font(DesignConstants.Typography.subheadline)
                                .foregroundColor(DesignConstants.Colors.textSecondary)
                                .lineLimit(1)
                        } icon: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(categoryColor)
                        }
                    }
                    
                    // Описание (если есть)
                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(DesignConstants.Typography.footnote)
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    // Индикатор подробнее
                    HStack {
                        Text("Подробнее")
                            .font(DesignConstants.Typography.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(DesignConstants.Colors.primary.opacity(0.08))
                    )
                }
                .padding(DesignConstants.padding)
            }
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
            .shadow(
                color: DesignConstants.Shadows.card.color,
                radius: DesignConstants.Shadows.card.radius,
                x: DesignConstants.Shadows.card.x,
                y: DesignConstants.Shadows.card.y
            )
        }
        .buttonStyle(PressableCardButtonStyle())
    }
    
    /// Получить иконку для категории
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "музыка": return "music.note"
        case "спорт": return "figure.run"
        case "театр": return "theatermasks.fill"
        case "кино": return "film.fill"
        case "образование": return "graduationcap.fill"
        case "искусство", "культура": return "paintpalette.fill"
        case "технологии", "технология", "it": return "desktopcomputer"
        case "еда", "кулинария": return "fork.knife"
        case "природа", "путешествия": return "airplane"
        default: return "star.fill"
        }
    }
}

#Preview {
    EventCardComponent(event: Event(
        id: 1,
        title: "Концерт электронной музыки",
        description: "Вечер электронной музыки с лучшими DJ города",
        date: "15 апреля, 19:00",
        location: "Москва, Клуб Aura",
        city: "Москва",
        imageName: nil,
        category: "Музыка"
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
}
