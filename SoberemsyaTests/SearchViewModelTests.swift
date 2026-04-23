import Testing
import Foundation
@testable import Soberemsya

@MainActor
@Suite("SearchViewModel Tests")
struct SearchViewModelTests {

    @Test("Initial state has all categories")
    func initialState() {
        let vm = SearchViewModel()
        #expect(vm.filteredCategories.count == EventCategory.allCategories.count)
        #expect(vm.query.isEmpty)
        #expect(vm.searchResults.isEmpty)
    }

    @Test("updateFilteredCategories with empty query shows all")
    func filterEmptyQuery() {
        let vm = SearchViewModel()
        vm.query = ""
        vm.updateFilteredCategories()
        #expect(vm.filteredCategories.count == EventCategory.allCategories.count)
    }

    @Test("updateFilteredCategories filters by query")
    func filterByQuery() {
        let vm = SearchViewModel()
        vm.query = "Муз"
        vm.updateFilteredCategories()
        #expect(vm.filteredCategories.count == 1)
        #expect(vm.filteredCategories.first?.title == "Музыка")
    }

    @Test("updateFilteredCategories is case-insensitive")
    func filterCaseInsensitive() {
        let vm = SearchViewModel()
        vm.query = "спорт"
        vm.updateFilteredCategories()
        #expect(vm.filteredCategories.count == 1)
        #expect(vm.filteredCategories.first?.title == "Спорт")
    }

    @Test("updateFilteredCategories with no match returns empty")
    func filterNoMatch() {
        let vm = SearchViewModel()
        vm.query = "zzzzz"
        vm.updateFilteredCategories()
        #expect(vm.filteredCategories.isEmpty)
    }
}
