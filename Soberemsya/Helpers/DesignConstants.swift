import SwiftUI

// MARK: - Preference Key для отслеживания скролла
struct HomeOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Константы для дизайна в стиле Apple Health
struct DesignConstants {
    // Радиусы скругления (как в Health app)
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 16
    
    // Отступы (минималистичные, с breathing space)
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 12
    static let largePadding: CGFloat = 20
    static let spacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 24
    
    struct Colors {
        // MARK: - Системные цвета (адаптивные)
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // MARK: - Акцентный цвет (как в Health - спокойный, не кричащий)
        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // SF Blue
        static let primaryLight = Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.1)
        
        // MARK: - Категории событий (приглушённые, пастельные)
        static let categoryMusic = Color(red: 1.0, green: 0.27, blue: 0.23) // SF Red
        static let categorySports = Color(red: 1.0, green: 0.62, blue: 0.04) // SF Orange
        static let categoryArt = Color(red: 0.69, green: 0.32, blue: 0.87) // SF Purple
        static let categoryTech = Color(red: 0.0, green: 0.78, blue: 0.75) // SF Teal
        static let categoryFood = Color(red: 1.0, green: 0.8, blue: 0.0) // SF Yellow
        static let categoryNature = Color(red: 0.2, green: 0.78, blue: 0.35) // SF Green
        
        // MARK: - Статусы
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // SF Green
        static let warning = Color(red: 1.0, green: 0.62, blue: 0.04) // SF Orange  
        static let error = Color(red: 1.0, green: 0.27, blue: 0.23) // SF Red
        
        // MARK: - Текст (системные, адаптивные)
        static let textPrimary = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary = Color(.tertiaryLabel)
        
        // MARK: - Разделители
        static let separator = Color(.separator)
        static let opaqueSeparator = Color(.opaqueSeparator)
        
        // MARK: - Функции для адаптивных цветов
        
        /// Основной фон приложения (белый в светлой теме, серый в тёмной)
        static func mainBackground(colorScheme: ColorScheme) -> Color {
            colorScheme == .dark 
                ? Color(.systemGroupedBackground)
                : Color.white
        }
        
        /// Фон карточки (как в Health)
        static func cardBackground(colorScheme: ColorScheme) -> Color {
            colorScheme == .dark 
                ? Color(.secondarySystemGroupedBackground)
                : Color(.systemBackground)
        }
        
        /// Фон для input полей
        static func inputBackground(colorScheme: ColorScheme) -> Color {
            colorScheme == .dark 
                ? Color(.tertiarySystemBackground)
                : Color(.secondarySystemBackground)
        }
        
        /// Мягкий градиент для хедера (приглушённый)
        static func headerGradient(colorScheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.48, blue: 1.0),
                    Color(red: 0.2, green: 0.6, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        /// Категория в мягкий цвет с градиентом
        static func categoryGradient(for category: String) -> LinearGradient {
            let color = categoryColor(for: category)
            return LinearGradient(
                gradient: Gradient(colors: [
                    color,
                    color.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        /// Получить цвет категории
        static func categoryColor(for category: String) -> Color {
            switch category.lowercased() {
            case "музыка": return categoryMusic
            case "спорт": return categorySports
            case "искусство", "культура", "театр": return categoryArt
            case "технология", "технологии", "it": return categoryTech
            case "еда", "кулинария": return categoryFood
            case "природа", "путешествия": return categoryNature
            case "кино": return primary
            case "образование": return Color(red: 0.2, green: 0.6, blue: 0.9)
            default: return primary
            }
        }
    }

    /// Фолбэк-изображение по категории (Unsplash CDN)
    static func categoryFallbackImageUrl(for category: String) -> String {
        let base = "https://images.unsplash.com/"
        let params = "?w=800&h=500&fit=crop&crop=entropy&auto=format&q=85"
        switch category.lowercased() {
        case "музыка":
            return "\(base)photo-1493225457124-a3eb161ffa5f\(params)"
        case "спорт":
            return "\(base)photo-1571019613454-1cb2f99b2d8b\(params)"
        case "театр":
            return "\(base)photo-1507003211169-0a1dd7228f2d\(params)"
        case "кино":
            return "\(base)photo-1536440136628-849c177e76a1\(params)"
        case "образование":
            return "\(base)photo-1523050854058-8df90110c9f1\(params)"
        case "еда", "кулинария":
            return "\(base)photo-1414235077428-338989a2e8c0\(params)"
        case "путешествия":
            return "\(base)photo-1488646953014-85cb44e25828\(params)"
        case "технологии", "технология", "it":
            return "\(base)photo-1518770660439-4636190af475\(params)"
        case "искусство", "культура":
            return "\(base)photo-1541961017774-22349e4a1262\(params)"
        default:
            return "\(base)photo-1492684223066-81342ee5ff30\(params)"
        }
    }
    
    struct Shadows {
        // Тени как в Health app - очень тонкие и ненавязчивые
        static let card = Shadow(
            color: Color.black.opacity(0.04), 
            radius: 8, 
            x: 0, 
            y: 2
        )
        
        static let cardHover = Shadow(
            color: Color.black.opacity(0.08), 
            radius: 12, 
            x: 0, 
            y: 4
        )
        
        static let subtle = Shadow(
            color: Color.black.opacity(0.02), 
            radius: 4, 
            x: 0, 
            y: 1
        )
    }
    
    struct Typography {
        // Шрифты как в Health - SF Pro
        static let largeTitle: Font = .system(size: 34, weight: .bold, design: .default)
        static let title: Font = .system(size: 28, weight: .bold, design: .default)
        static let title2: Font = .system(size: 22, weight: .bold, design: .default)
        static let title3: Font = .system(size: 20, weight: .semibold, design: .default)
        static let headline: Font = .system(size: 17, weight: .semibold, design: .default)
        static let body: Font = .system(size: 17, weight: .regular, design: .default)
        static let callout: Font = .system(size: 16, weight: .regular, design: .default)
        static let subheadline: Font = .system(size: 15, weight: .regular, design: .default)
        static let footnote: Font = .system(size: 13, weight: .regular, design: .default)
        static let caption: Font = .system(size: 12, weight: .regular, design: .default)
        static let caption2: Font = .system(size: 11, weight: .regular, design: .default)
    }
    
    struct Animation {
        // Анимации как в Health - плавные spring анимации
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
