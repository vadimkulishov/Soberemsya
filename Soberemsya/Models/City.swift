import Foundation

struct City: Identifiable, Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension City {
    static let russianCities = [
        City(name: "Москва", latitude: 55.7558, longitude: 37.6173),
        City(name: "Санкт-Петербург", latitude: 59.9311, longitude: 30.3609),
        City(name: "Казань", latitude: 55.1835, longitude: 48.8016),
        City(name: "Екатеринбург", latitude: 56.8389, longitude: 60.6057),
        City(name: "Новосибирск", latitude: 55.0415, longitude: 82.9346),
        City(name: "Сочи", latitude: 43.5852, longitude: 39.7257),
        City(name: "Краснодар", latitude: 45.0355, longitude: 38.9746),
        City(name: "Нижний Новгород", latitude: 56.2965, longitude: 43.9361),
        City(name: "Самара", latitude: 53.1959, longitude: 50.1009),
        City(name: "Ростов-на-Дону", latitude: 47.2357, longitude: 39.7015),
        City(name: "Уфа", latitude: 54.7428, longitude: 55.9639),
        City(name: "Красноярск", latitude: 56.0153, longitude: 92.8932),
        City(name: "Пермь", latitude: 58.0122, longitude: 56.2288)
    ]
}
