import Foundation
import SwiftUI

struct EventCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let icon: String
    let color: String
    
    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        color: String
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
    }
}

extension EventCategory {
    static let allCategories = [
        EventCategory(title: "Музыка", icon: "music.note", color: "#A855F7"),
        EventCategory(title: "Спорт", icon: "sportscourt", color: "#22C55E"),
        EventCategory(title: "Театр", icon: "theatermasks", color: "#F97316"),
        EventCategory(title: "Кино", icon: "film", color: "#3B82F6"),
        EventCategory(title: "Образование", icon: "book", color: "#EF4444"),
        EventCategory(title: "Еда", icon: "fork.knife", color: "#EC4899"),
        EventCategory(title: "Путешествия", icon: "airplane", color: "#06B6D4"),
        EventCategory(title: "Технологии", icon: "desktopcomputer", color: "#6366F1")
    ]
}
