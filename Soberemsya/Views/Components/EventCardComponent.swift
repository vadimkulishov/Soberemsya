import SwiftUI

/// Карточка события: фото, ключевая информация и быстрый переход.
struct EventCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let event: Event
    @State private var showDetail = false
    
    var categoryColor: Color {
        DesignConstants.Colors.categoryColor(for: event.category)
    }
    
    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    EventImageView(
                        imagePath: event.imageName,
                        category: event.category,
                        height: 178,
                        cornerRadius: 0,
                        overlayStrength: 0.42,
                        preferCategoryImage: true
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        categoryBadge

                        Text(event.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
                    }
                    .padding(14)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        EventMetaPill(icon: "calendar", text: event.date, color: categoryColor)
                        EventMetaPill(icon: "mappin.and.ellipse", text: event.location, color: categoryColor)
                    }

                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(DesignConstants.Typography.footnote)
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                            .lineLimit(2)
                            .lineSpacing(2)
                    }

                    HStack {
                        Text("Подробнее")
                            .font(DesignConstants.Typography.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius, style: .continuous)
                            .fill(DesignConstants.Colors.primary.opacity(0.08))
                    )
                }
                .padding(DesignConstants.padding)
            }
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.28 : 0.08),
                radius: 14,
                x: 0,
                y: 7
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.7), lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardButtonStyle())
        .fullScreenCover(isPresented: $showDetail) {
            EventDetailView(event: event)
        }
    }

    private var categoryBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: DesignConstants.categoryIcon(for: event.category))
                .font(.system(size: 10, weight: .semibold))
            Text(event.category)
                .font(DesignConstants.Typography.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.28), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 1))
    }
}

private struct EventMetaPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        Label {
            Text(text)
                .font(DesignConstants.Typography.footnote)
                .fontWeight(.medium)
                .lineLimit(1)
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(DesignConstants.Colors.textSecondary)
        .labelStyle(.titleAndIcon)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
