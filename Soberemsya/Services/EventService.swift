import Foundation
import Combine

/// Сервис для работы с событиями
class EventService: ObservableObject {
    static let shared = EventService()
    
    @Published var events: [Event] = []
    @Published var filteredEvents: [Event] = []
    @Published var selectedEvent: Event? = nil
    @Published var isLoading: Bool = false
    @Published var error: APIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Load Events
    
    /// Загрузить все события
    func loadEvents(city: String? = nil, skip: Int = 0, limit: Int = 20) {
        isLoading = true
        error = nil
        
        print("🔄 EventService: Loading events... city=\(city ?? "all"), skip=\(skip)")
        
        APIClient.shared.getEvents(skip: skip, limit: limit, city: city)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                print("📡 EventService: Request completed")
                
                if case let .failure(error) = completion {
                    print("❌ EventService: Error - \(error)")
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                print("✅ EventService: Received \(response.count) events")
                
                // Преобразуем EventResponse в Event
                let events = response.map { Event(
                    id: $0.id,
                    title: $0.title,
                    description: $0.description,
                    date: $0.date,
                    timeStart: $0.timeStart,
                    timeEnd: $0.timeEnd,
                    location: $0.location,
                    city: $0.city,
                    imageName: $0.imageName,
                    category: $0.category ?? "Другое",
                    capacity: $0.capacity,
                    registeredCount: $0.registeredCount,
                    isActive: $0.isActive,
                    isPublished: $0.isPublished
                )}
                
                print("📝 EventService: Parsed \(events.count) events")
                
                if skip == 0 {
                    self?.events = events
                } else {
                    self?.events.append(contentsOf: events)
                }
                
                self?.filteredEvents = self?.events ?? []
                print("💾 EventService: Stored events. Total: \(self?.events.count ?? 0)")
            }
            .store(in: &cancellables)
    }
    
    /// Загрузить события по категории
    func loadEventsByCategory(_ category: String) {
        isLoading = true
        error = nil
        
        APIClient.shared.getEventsByCategory(category: category)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                let events = response.map { Event(
                    id: $0.id,
                    title: $0.title,
                    description: $0.description,
                    date: $0.date,
                    timeStart: $0.timeStart,
                    timeEnd: $0.timeEnd,
                    location: $0.location,
                    city: $0.city,
                    imageName: $0.imageName,
                    category: $0.category ?? "Другое",
                    capacity: $0.capacity,
                    registeredCount: $0.registeredCount,
                    isActive: $0.isActive,
                    isPublished: $0.isPublished
                )}
                
                self?.filteredEvents = events
            }
            .store(in: &cancellables)
    }
    
    /// Получить событие по ID
    func loadEvent(id: Int) {
        isLoading = true
        error = nil
        
        APIClient.shared.getEvent(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                let event = Event(
                    id: response.id,
                    title: response.title,
                    description: response.description,
                    date: response.date,
                    timeStart: response.timeStart,
                    timeEnd: response.timeEnd,
                    location: response.location,
                    city: response.city,
                    imageName: response.imageName,
                    category: response.category ?? "Другое",
                    capacity: response.capacity,
                    registeredCount: response.registeredCount,
                    isActive: response.isActive,
                    isPublished: response.isPublished
                )
                
                self?.selectedEvent = event
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Event Management
    
    /// Зарегистрировать на событие
    func registerForEvent(eventId: Int, completion: @escaping (Bool, APIError?) -> Void) {
        APIClient.shared.registerForEvent(eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case let .failure(error) = result {
                    completion(false, error)
                }
            } receiveValue: { _ in
                // Обновляем количество регистраций локально
                if let index = self.events.firstIndex(where: { $0.id == eventId }) {
                    self.events[index].registeredCount = (self.events[index].registeredCount ?? 0) + 1
                    // Обновляем и в filteredEvents если там есть
                    if let filteredIndex = self.filteredEvents.firstIndex(where: { $0.id == eventId }) {
                        self.filteredEvents[filteredIndex].registeredCount = (self.filteredEvents[filteredIndex].registeredCount ?? 0) + 1
                    }
                }
                
                // Обновляем selectedEvent если это он
                if self.selectedEvent?.id == eventId {
                    self.selectedEvent?.registeredCount = (self.selectedEvent?.registeredCount ?? 0) + 1
                }
                
                completion(true, nil)
            }
            .store(in: &cancellables)
    }
    
    /// Отменить регистрацию на событие
    func unregisterFromEvent(eventId: Int, completion: @escaping (Bool, APIError?) -> Void) {
        APIClient.shared.unregisterFromEvent(eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case let .failure(error) = result {
                    completion(false, error)
                }
            } receiveValue: { _ in
                // Обновляем количество регистраций локально
                if let index = self.events.firstIndex(where: { $0.id == eventId }) {
                    self.events[index].registeredCount = max(0, (self.events[index].registeredCount ?? 0) - 1)
                    if let filteredIndex = self.filteredEvents.firstIndex(where: { $0.id == eventId }) {
                        self.filteredEvents[filteredIndex].registeredCount = max(0, (self.filteredEvents[filteredIndex].registeredCount ?? 0) - 1)
                    }
                }
                
                if self.selectedEvent?.id == eventId {
                    self.selectedEvent?.registeredCount = max(0, (self.selectedEvent?.registeredCount ?? 0) - 1)
                }
                
                completion(true, nil)
            }
            .store(in: &cancellables)
    }
    
    /// Check-in на событие
    func checkInToEvent(eventId: Int, completion: @escaping (Bool, APIError?) -> Void) {
        APIClient.shared.checkInToEvent(eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case let .failure(error) = result {
                    completion(false, error)
                }
            } receiveValue: { _ in
                completion(true, nil)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Filtering
    
    /// Фильтровать события по городу
    func filterByCity(_ city: String) {
        if city.isEmpty {
            filteredEvents = events
        } else {
            filteredEvents = events.filter { $0.city == city }
        }
    }
    
    /// Фильтровать события по категории
    func filterByCategory(_ category: String) {
        if category.isEmpty {
            filteredEvents = events
        } else {
            filteredEvents = events.filter { $0.category == category }
        }
    }
    
    /// Поиск события по названию
    func searchEvents(_ query: String) {
        if query.isEmpty {
            filteredEvents = events
        } else {
            let lowercasedQuery = query.lowercased()
            filteredEvents = events.filter { event in
                event.title.lowercased().contains(lowercasedQuery) ||
                event.description.lowercased().contains(lowercasedQuery)
            }
        }
    }
}
