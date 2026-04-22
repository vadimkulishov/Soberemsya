import Foundation

class CityService {
    static let shared = CityService()
    
    private let defaults = UserDefaults.standard
    private let selectedCityKey = "selectedCity"
    
    var allCities: [City] {
        return City.russianCities.sorted { $0.name < $1.name }
    }
    
    func getSelectedCity() -> String {
        return defaults.string(forKey: selectedCityKey) ?? "Москва"
    }
    
    func setSelectedCity(_ city: String) {
        defaults.set(city, forKey: selectedCityKey)
    }
    
    func searchCities(query: String) -> [City] {
        guard !query.isEmpty else { return allCities }
        
        return allCities.filter { city in
            city.name.lowercased().contains(query.lowercased())
        }
    }
    
    func getCityByName(_ name: String) -> City? {
        return allCities.first { $0.name == name }
    }
}
