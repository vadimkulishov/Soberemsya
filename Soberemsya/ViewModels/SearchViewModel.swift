import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchResults: [Event] = []
    @Published var isLoading: Bool = false
    @Published var error: APIError? = nil
    @Published var selectedCategory: EventCategory?
    @Published var filteredCategories: [EventCategory] = []
    
    let allCategories = EventCategory.allCategories
    private var eventService = EventService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        updateFilteredCategories()
    }
    
    func updateFilteredCategories() {
        if query.isEmpty {
            filteredCategories = allCategories
        } else {
            filteredCategories = allCategories.filter { category in
                category.title.lowercased().contains(query.lowercased())
            }
        }
    }
    
    func selectCategory(_ category: EventCategory) {
        selectedCategory = category
        loadEventsByCategory(category.title)
    }
    
    // MARK: - Search
    
    func searchEvents() {
        if query.isEmpty {
            searchResults = []
            return
        }
        
        isLoading = true
        eventService.searchEvents(query)
        
        eventService.$filteredEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.searchResults = events
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load by Category
    
    func loadEventsByCategory(_ category: String) {
        isLoading = true
        eventService.filterByCategory(category)
        
        eventService.$filteredEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.searchResults = events
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}
