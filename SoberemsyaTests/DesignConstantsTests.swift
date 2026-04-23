import Testing
import SwiftUI
@testable import Soberemsya

@MainActor
@Suite("DesignConstants Tests")
struct DesignConstantsTests {

    @Test("Corner radius values are positive")
    func cornerRadiusPositive() {
        #expect(DesignConstants.cornerRadius > 0)
        #expect(DesignConstants.smallCornerRadius > 0)
        #expect(DesignConstants.largeCornerRadius > 0)
    }

    @Test("Corner radius hierarchy")
    func cornerRadiusHierarchy() {
        #expect(DesignConstants.smallCornerRadius < DesignConstants.cornerRadius)
        #expect(DesignConstants.cornerRadius < DesignConstants.largeCornerRadius)
    }

    @Test("Padding values are positive")
    func paddingPositive() {
        #expect(DesignConstants.padding > 0)
        #expect(DesignConstants.smallPadding > 0)
        #expect(DesignConstants.largePadding > 0)
        #expect(DesignConstants.spacing > 0)
        #expect(DesignConstants.sectionSpacing > 0)
    }

    @Test("categoryFallbackImageUrl returns valid URL for known categories")
    func fallbackImageUrls() {
        let categories = ["музыка", "спорт", "театр", "кино", "образование", "еда", "путешествия", "технологии"]
        for category in categories {
            let url = DesignConstants.categoryFallbackImageUrl(for: category)
            #expect(url.hasPrefix("https://"), "URL for \(category) should start with https://")
            #expect(url.contains("unsplash.com"), "URL for \(category) should be from unsplash.com")
        }
    }

    @Test("categoryFallbackImageUrl returns default for unknown category")
    func fallbackImageUrlDefault() {
        let url = DesignConstants.categoryFallbackImageUrl(for: "unknown_category")
        #expect(url.hasPrefix("https://"))
        #expect(url.contains("unsplash.com"))
    }

    @Test("Shadow values are reasonable")
    func shadowValues() {
        #expect(DesignConstants.Shadows.card.radius > 0)
        #expect(DesignConstants.Shadows.cardHover.radius > DesignConstants.Shadows.card.radius)
        #expect(DesignConstants.Shadows.subtle.radius > 0)
    }
}
