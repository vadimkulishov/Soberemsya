import SwiftUI

struct PromoItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let accentColor: Color
    let type: PromoType
    
    enum PromoType {
        case discount
        case newFeature
        case partnership
        case seasonal
        case advertisement
    }
    
    static let samplePromos: [PromoItem] = [
        PromoItem(
            title: "Скидка 50%",
            subtitle: "На первый билет для новых пользователей",
            icon: "tag.fill",
            gradient: [
                Color(red: 1.0, green: 0.27, blue: 0.23),
                Color(red: 1.0, green: 0.45, blue: 0.35)
            ],
            accentColor: Color(red: 1.0, green: 0.27, blue: 0.23),
            type: .discount
        ),
        PromoItem(
            title: "Летний фестиваль",
            subtitle: "Более 50 мероприятий в вашем городе",
            icon: "sun.max.fill",
            gradient: [
                Color(red: 1.0, green: 0.62, blue: 0.04),
                Color(red: 1.0, green: 0.75, blue: 0.25)
            ],
            accentColor: Color(red: 1.0, green: 0.62, blue: 0.04),
            type: .seasonal
        ),
        PromoItem(
            title: "VIP доступ",
            subtitle: "Эксклюзивные события только для вас",
            icon: "crown.fill",
            gradient: [
                Color(red: 0.69, green: 0.32, blue: 0.87),
                Color(red: 0.82, green: 0.52, blue: 0.95)
            ],
            accentColor: Color(red: 0.69, green: 0.32, blue: 0.87),
            type: .newFeature
        ),
        PromoItem(
            title: "Партнёрская программа",
            subtitle: "Приглашайте друзей и получайте бонусы",
            icon: "person.2.fill",
            gradient: [
                Color(red: 0.0, green: 0.78, blue: 0.75),
                Color(red: 0.2, green: 0.88, blue: 0.85)
            ],
            accentColor: Color(red: 0.0, green: 0.78, blue: 0.75),
            type: .partnership
        ),
        PromoItem(
            title: "Реклама места",
            subtitle: "Закажите рекламу вашего мероприятия",
            icon: "megaphone.fill",
            gradient: [
                Color(red: 0.0, green: 0.48, blue: 1.0),
                Color(red: 0.2, green: 0.65, blue: 1.0)
            ],
            accentColor: Color(red: 0.0, green: 0.48, blue: 1.0),
            type: .advertisement
        ),
        PromoItem(
            title: "Ранняя регистрация",
            subtitle: "Регистрируйтесь заранее и экономьте до 30%",
            icon: "clock.badge.checkmark.fill",
            gradient: [
                Color(red: 0.18, green: 0.80, blue: 0.44),
                Color(red: 0.40, green: 0.90, blue: 0.56)
            ],
            accentColor: Color(red: 0.18, green: 0.80, blue: 0.44),
            type: .discount
        ),
        PromoItem(
            title: "Выходные события",
            subtitle: "Лучшие мероприятия каждые выходные",
            icon: "sparkles",
            gradient: [
                Color(red: 0.95, green: 0.50, blue: 0.13),
                Color(red: 1.0, green: 0.68, blue: 0.32)
            ],
            accentColor: Color(red: 0.95, green: 0.50, blue: 0.13),
            type: .seasonal
        ),
        PromoItem(
            title: "Скидка для групп",
            subtitle: "Приходите компанией — платите меньше",
            icon: "person.3.fill",
            gradient: [
                Color(red: 0.35, green: 0.34, blue: 0.84),
                Color(red: 0.55, green: 0.48, blue: 0.95)
            ],
            accentColor: Color(red: 0.35, green: 0.34, blue: 0.84),
            type: .discount
        ),
        PromoItem(
            title: "Новое в городе",
            subtitle: "Свежие площадки и уникальные форматы",
            icon: "building.2.fill",
            gradient: [
                Color(red: 0.90, green: 0.26, blue: 0.42),
                Color(red: 1.0, green: 0.45, blue: 0.55)
            ],
            accentColor: Color(red: 0.90, green: 0.26, blue: 0.42),
            type: .newFeature
        ),
        PromoItem(
            title: "Программа лояльности",
            subtitle: "Копите баллы за каждое посещение",
            icon: "gift.fill",
            gradient: [
                Color(red: 0.83, green: 0.69, blue: 0.22),
                Color(red: 0.95, green: 0.82, blue: 0.35)
            ],
            accentColor: Color(red: 0.83, green: 0.69, blue: 0.22),
            type: .partnership
        )
    ]
}
