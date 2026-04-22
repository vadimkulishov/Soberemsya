import Foundation
import Combine

enum LoadingError: Error {
    case timeout
    case noInternet
    case serverError
    case unknown(String)
    
    var message: String {
        switch self {
        case .timeout:
            return "Время ожидания истекло"
        case .noInternet:
            return "Нет подключения к интернету"
        case .serverError:
            return "Ошибка сервера"
        case .unknown(let msg):
            return msg
        }
    }
    
    var icon: String {
        switch self {
        case .timeout, .noInternet:
            return "wifi.slash"
        case .serverError:
            return "exclamationmark.triangle"
        case .unknown:
            return "xmark.circle"
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var filteredEvents: [Event] = []
    @Published var banners: [String] = []
    @Published var promos: [PromoItem] = []
    @Published var selectedCity: String = ""
    @Published var isLoading: Bool = false
    @Published var loadingError: LoadingError? = nil
    @Published var eventsAppeared: Bool = false
    @Published var error: APIError? = nil
    @Published var cities: [String] = []
    
    private var eventService = EventService.shared
    private var cancellables = Set<AnyCancellable>()
    private var timeoutWorkItem: DispatchWorkItem?
    private let timeoutDuration: TimeInterval = 10.0
    
    init() {
        print("🏠 HomeViewModel: Initializing...")
        loadPromos()
        setupEventServiceBinding()
        loadEventsWithTimeout()
        print("🏠 HomeViewModel: Initialization complete")
    }
    
    // MARK: - Setup
    
    private func setupEventServiceBinding() {
        print("🔗 HomeViewModel: Setting up bindings...")
        eventService.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                print("🔗 HomeViewModel: Events updated - count: \(events.count)")
                self?.events = events
                if !events.isEmpty {
                    self?.cancelTimeout()
                    self?.isLoading = false
                    self?.loadingError = nil
                }
            }
            .store(in: &cancellables)
        
        eventService.$filteredEvents
            .receive(on: DispatchQueue.main)
            .assign(to: &$filteredEvents)
        
        eventService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.isLoading = loading
                if loading {
                    self?.loadingError = nil
                }
            }
            .store(in: &cancellables)
        
        eventService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] apiError in
                if let apiError = apiError {
                    self?.handleAPIError(apiError)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Events with Timeout
    
    func loadEventsWithTimeout() {
        loadingError = nil
        isLoading = true
        eventsAppeared = false
        
        startTimeout()
        
        if selectedCity.isEmpty {
            eventService.loadEvents()
        } else {
            eventService.loadEvents(city: selectedCity)
        }
    }
    
    func retryLoading() {
        print("🔄 HomeViewModel: Retrying...")
        loadEventsWithTimeout()
    }
    
    private func startTimeout() {
        cancelTimeout()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, self.isLoading else { return }
            
            print("⏰ HomeViewModel: Timeout reached!")
            self.isLoading = false
            
            if self.events.isEmpty {
                self.loadingError = .timeout
            }
        }
        
        timeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutDuration, execute: workItem)
    }
    
    private func cancelTimeout() {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
    }
    
    private func handleAPIError(_ apiError: APIError) {
        cancelTimeout()
        isLoading = false
        
        switch apiError {
        case .networkError:
            loadingError = .noInternet
        case .serverError:
            loadingError = .serverError
        case .unauthorizedError:
            loadingError = .unknown("Требуется авторизация")
        case .unknown(let msg):
            loadingError = .unknown(msg)
        default:
            loadingError = .unknown("Неизвестная ошибка")
        }
    }
    
    // MARK: - Load Events
    
    func loadEvents() {
        loadEventsWithTimeout()
    }
    
    // MARK: - Load Cities
    
    func loadCities() {
        print("🏙 HomeViewModel: loadCities() - skipped (endpoint may not exist)")
    }
    
    // MARK: - Filter
    
    func setCity(_ city: String) {
        selectedCity = city
        loadEventsWithTimeout()
    }
    
    func loadBanners() {
        banners = (1...5).map { "Баннер №\($0)" }
    }
    
    func loadPromos() {
        promos = PromoItem.samplePromos
    }
}
