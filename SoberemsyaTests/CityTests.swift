import Testing
import Foundation
@testable import Soberemsya

@Suite("City Model Tests")
struct CityTests {

    @Test("russianCities has 13 cities")
    func russianCitiesCount() {
        #expect(City.russianCities.count == 13)
    }

    @Test("Moscow is in the list")
    func moscowExists() {
        let moscow = City.russianCities.first { $0.name == "Москва" }
        #expect(moscow != nil)
        if let moscow = moscow {
            #expect(moscow.latitude > 55.0 && moscow.latitude < 56.0)
            #expect(moscow.longitude > 37.0 && moscow.longitude < 38.0)
        }
    }

    @Test("All cities have valid coordinates")
    func validCoordinates() {
        for city in City.russianCities {
            #expect(city.latitude >= -90 && city.latitude <= 90, "Invalid latitude for \(city.name)")
            #expect(city.longitude >= -180 && city.longitude <= 180, "Invalid longitude for \(city.name)")
        }
    }

    @Test("All cities have non-empty names")
    func nonEmptyNames() {
        for city in City.russianCities {
            #expect(!city.name.isEmpty, "City name should not be empty")
        }
    }

    @Test("City Codable round-trip")
    func codableRoundTrip() throws {
        let city = City(name: "Тест", latitude: 55.0, longitude: 37.0)
        let data = try JSONEncoder().encode(city)
        let decoded = try JSONDecoder().decode(City.self, from: data)
        #expect(decoded.name == city.name)
        #expect(decoded.latitude == city.latitude)
        #expect(decoded.longitude == city.longitude)
    }
}
