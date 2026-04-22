import Foundation

/// Configuration для подключения к серверу
struct AppConfig {
    static let shared = AppConfig()
    
    // MARK: - Keys
    private let baseURLKey = "app.config.baseURL"
    private let isSimulatorKey = "app.isSimulator"
    
    // MARK: - Defaults
    private let simulatorDefaultURL = "http://localhost:8002"
    private let deviceDefaultURL = "http://MacBook-Air-Vadim.local:8002"
    
    // MARK: - Methods
    
    /// Получить базовый URL API
    var baseURL: String {
        // Если сохранен custom URL - используем его
        if let customURL = UserDefaults.standard.string(forKey: baseURLKey),
           !customURL.isEmpty {
            return customURL
        }
        
        // Иначе используем default в зависимости от типа устройства
        return isSimulator ? simulatorDefaultURL : deviceDefaultURL
    }
    
    /// Сохранить custom базовый URL
    func setBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: baseURLKey)
    }
    
    /// Сбросить на default URL
    func resetBaseURL() {
        UserDefaults.standard.removeObject(forKey: baseURLKey)
    }
    
    /// Получить URL для симулятора
    var simulatorURL: String {
        simulatorDefaultURL
    }
    
    /// Получить URL для физического устройства
    var deviceURL: String {
        deviceDefaultURL
    }
    
    /// Проверить это симулятор или физическое устройство
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Получить информацию о текущей конфигурации
    var debugInfo: String {
        """
        === Server Configuration ===
        Current Base URL: \(baseURL)
        Is Simulator: \(isSimulator)
        Device Default: \(deviceDefaultURL)
        Simulator Default: \(simulatorDefaultURL)
        Custom URL Set: \(UserDefaults.standard.string(forKey: baseURLKey) != nil)
        """
    }
}
