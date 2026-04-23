import Testing
import Foundation
@testable import Soberemsya

@MainActor
@Suite("CityService Tests")
struct CityServiceTests {

    @Test("allCities returns sorted cities")
    func allCitiesSorted() {
        let service = CityService()
        let cities = service.allCities
        let names = cities.map { $0.name }
        let sorted = names.sorted()
        #expect(names == sorted)
    }

    @Test("searchCities with empty query returns all")
    func searchEmptyQuery() {
        let service = CityService()
        let result = service.searchCities(query: "")
        #expect(result.count == City.russianCities.count)
    }

    @Test("searchCities filters correctly")
    func searchFilters() {
        let service = CityService()
        let result = service.searchCities(query: "Москва")
        #expect(result.count == 1)
        #expect(result.first?.name == "Москва")
    }

    @Test("searchCities is case-insensitive")
    func searchCaseInsensitive() {
        let service = CityService()
        let result = service.searchCities(query: "москва")
        #expect(result.count == 1)
    }

    @Test("getCityByName finds existing city")
    func getCityByName() {
        let service = CityService()
        let city = service.getCityByName("Казань")
        #expect(city != nil)
        #expect(city?.name == "Казань")
    }

    @Test("getCityByName returns nil for unknown city")
    func getCityByNameNotFound() {
        let service = CityService()
        let city = service.getCityByName("Атлантида")
        #expect(city == nil)
    }
}
