import Testing
import Foundation
@testable import Soberemsya

@MainActor
@Suite("AddEventViewModel Tests")
struct AddEventViewModelTests {

    @Test("isFormValid returns false for empty form")
    func emptyFormInvalid() {
        let vm = AddEventViewModel()
        #expect(!vm.isFormValid())
    }

    @Test("isFormValid returns true when all required fields filled")
    func validForm() {
        let vm = AddEventViewModel()
        vm.title = "Concert"
        vm.category = "Музыка"
        vm.location = "Arena"
        vm.date = "01.05.2026"
        vm.description = "Great event"
        #expect(vm.isFormValid())
    }

    @Test("isFormValid returns false when title is missing")
    func missingTitle() {
        let vm = AddEventViewModel()
        vm.category = "Музыка"
        vm.location = "Arena"
        vm.date = "01.05.2026"
        vm.description = "Great event"
        #expect(!vm.isFormValid())
    }

    @Test("resetForm clears all fields")
    func resetForm() {
        let vm = AddEventViewModel()
        vm.title = "Concert"
        vm.category = "Музыка"
        vm.location = "Arena"
        vm.date = "01.05.2026"
        vm.description = "Description"

        vm.resetForm()

        #expect(vm.title.isEmpty)
        #expect(vm.category.isEmpty)
        #expect(vm.location.isEmpty)
        #expect(vm.date.isEmpty)
        #expect(vm.description.isEmpty)
        #expect(vm.image_url == nil)
        #expect(vm.selectedImage == nil)
        #expect(vm.selectedCategory.isEmpty)
        #expect(vm.capacity == 0)
    }

    @Test("Categories list has expected items")
    func categoriesList() {
        let vm = AddEventViewModel()
        #expect(vm.categories.count == 8)
        #expect(vm.categories.contains("Музыка"))
        #expect(vm.categories.contains("Спорт"))
    }

    @Test("Event types list has expected items")
    func eventTypesList() {
        let vm = AddEventViewModel()
        #expect(vm.eventTypes.count == 3)
        #expect(vm.eventTypes.contains("Открытое"))
    }
}
