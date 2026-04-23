import Testing
import Foundation
@testable import Soberemsya

@Suite("EventCategory Tests")
struct EventCategoryTests {

    @Test("allCategories has 8 categories")
    func allCategoriesCount() {
        #expect(EventCategory.allCategories.count == 8)
    }

    @Test("All categories have non-empty fields")
    func nonEmptyFields() {
        for cat in EventCategory.allCategories {
            #expect(!cat.title.isEmpty, "Title should not be empty")
            #expect(!cat.icon.isEmpty, "Icon should not be empty")
            #expect(!cat.color.isEmpty, "Color should not be empty")
        }
    }

    @Test("Expected category titles")
    func expectedTitles() {
        let titles = EventCategory.allCategories.map { $0.title }
        let expected = ["Музыка", "Спорт", "Театр", "Кино", "Образование", "Еда", "Путешествия", "Технологии"]
        #expect(titles == expected)
    }

    @Test("Color values are hex strings")
    func hexColors() {
        for cat in EventCategory.allCategories {
            #expect(cat.color.hasPrefix("#"), "\(cat.title) color should start with #")
            #expect(cat.color.count == 7, "\(cat.title) color should be 7 chars (#RRGGBB)")
        }
    }

    @Test("Hashable conformance")
    func hashable() {
        let cat1 = EventCategory.allCategories[0]
        let cat2 = EventCategory.allCategories[1]
        var set = Set<EventCategory>()
        set.insert(cat1)
        set.insert(cat2)
        set.insert(cat1)
        #expect(set.count == 2)
    }
}
