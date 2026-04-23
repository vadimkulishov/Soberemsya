import Foundation
import CoreLocation
import Combine
import MapKit

/// LocationManager отвечает за определение текущего города пользователя
/// Использует современные iOS APIs (async/await, CLLocationManager)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentCity: String = "Москва"
    @Published var isDenied: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    private let cityService = CityService.shared
    private let geocoder = CLGeocoder()
    private var hasLoaded = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer // Оптимизировано для определения города
        
        // Загружаем сохраненный город из CityService
        currentCity = cityService.getSelectedCity()
        
        // Проверяем текущий статус авторизации
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission Management
    
    /// Проверяет текущий статус авторизации
    private func checkAuthorizationStatus() {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .notDetermined:
            // Не запрашиваем автоматически, даём пользователю контроль
            break
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isDenied = true
                self.errorMessage = "Доступ к геолокации запрещён. Разрешите доступ в Настройках."
            }
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    /// Запрашивает разрешение на использование геолокации
    func requestLocationPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isDenied = true
                self.errorMessage = "Доступ к геолокации запрещён. Откройте Настройки для изменения."
            }
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isDenied = true
                self.isLoading = false
                self.errorMessage = "Доступ к геолокации запрещён. Откройте Настройки для изменения."
            }
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                self.isDenied = false
                self.errorMessage = ""
            }
            startLocationUpdates()
        case .notDetermined:
            DispatchQueue.main.async {
                self.isDenied = false
                self.errorMessage = ""
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Location Updates
    
    func startLocationUpdates() {
        guard !hasLoaded else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        manager.requestLocation()
    }
    
    /// Принудительно обновить геолокацию (сбрасывает hasLoaded)
    func refreshLocation() {
        hasLoaded = false
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Игнорируем слишком старые или неточные координаты
        let age = -location.timestamp.timeIntervalSinceNow
        guard age < 60, location.horizontalAccuracy >= 0 else { return }
        
        guard !hasLoaded else { return }
        hasLoaded = true
        
        reverseGeocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            
            // CLError.locationUnknown — временная ошибка, не показываем
            if let clError = error as? CLError, clError.code == .locationUnknown {
                return
            }
            
            self.errorMessage = "Не удалось определить местоположение"
        }
    }
    
    // MARK: - Reverse Geocoding
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        if #available(iOS 26.0, *),
           let request = MKReverseGeocodingRequest(location: location) {
            request.preferredLocale = Locale(identifier: "ru_RU")

            Task {
                do {
                    let mapItems = try await request.mapItems
                    await MainActor.run {
                        if let mapItem = mapItems.first,
                           let cityName = mapItem.addressRepresentations?.cityName {
                            self.setCity(cityName)
                        } else {
                            self.errorMessage = "Город не определён"
                            self.isLoading = false
                        }
                    }
                } catch {
                    print("Geocode error: \(error.localizedDescription)")
                    self.reverseGeocodeWithCLGeocoder(location)
                }
            }
            return
        }

        reverseGeocodeWithCLGeocoder(location)
    }

    private func reverseGeocodeWithCLGeocoder(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ru_RU")) { placemarks, error in
            DispatchQueue.main.async {
                if let error {
                    print("CLGeocoder error: \(error.localizedDescription)")
                    self.errorMessage = "Не удалось определить город"
                    self.isLoading = false
                    return
                }

                if let placemark = placemarks?.first,
                   let cityName = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea {
                    self.setCity(cityName)
                } else {
                    self.errorMessage = "Город не определён"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - City Management
    
    /// Устанавливает город и синхронизирует с CityService
    func setCity(_ newCity: String) {
        currentCity = newCity
        cityService.setSelectedCity(newCity)
        errorMessage = ""
        isLoading = false
    }
    
    /// Находит ближайший город из списка российских городов
    func findNearestCity() {
        let russianCities = City.russianCities
        guard !russianCities.isEmpty else {
            currentCity = "Москва"
            return
        }
        
        // Если уже есть сохраненный город - используем его
        let savedCity = cityService.getSelectedCity()
        if savedCity != "Выбрать город" {
            currentCity = savedCity
            return
        }
        
        // По умолчанию Москва
        currentCity = "Москва"
        cityService.setSelectedCity("Москва")
    }
}
