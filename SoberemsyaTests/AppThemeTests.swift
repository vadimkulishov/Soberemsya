import Testing
import SwiftUI
@testable import Soberemsya

@Suite("AppTheme Tests")
struct AppThemeTests {

    @Test("All theme cases exist")
    func allCases() {
        #expect(AppTheme.allCases.count == 3)
    }

    @Test("Raw values are Russian strings")
    func rawValues() {
        #expect(AppTheme.system.rawValue == "Системная")
        #expect(AppTheme.light.rawValue == "Светлая")
        #expect(AppTheme.dark.rawValue == "Тёмная")
    }

    @Test("ColorScheme mapping")
    func colorSchemeMapping() {
        #expect(AppTheme.system.colorScheme == nil)
        #expect(AppTheme.light.colorScheme == .light)
        #expect(AppTheme.dark.colorScheme == .dark)
    }

    @Test("Icons are non-empty SF Symbols")
    func icons() {
        for theme in AppTheme.allCases {
            #expect(!theme.icon.isEmpty)
        }
        #expect(AppTheme.system.icon == "circle.lefthalf.filled")
        #expect(AppTheme.light.icon == "sun.max.fill")
        #expect(AppTheme.dark.icon == "moon.fill")
    }

    @Test("Identifiable id matches rawValue")
    func identifiable() {
        for theme in AppTheme.allCases {
            #expect(theme.id == theme.rawValue)
        }
    }
}
