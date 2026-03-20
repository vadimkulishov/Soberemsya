import SwiftUI

struct SearchView: View {
    @State private var query: String = ""
    
    // Пример данных для поиска
    let items = [
        "SwiftUI",
        "UIKit",
        "Combine",
        "CoreData",
        "ARKit",
        "MapKit",
        "Swift Concurrency",
        "Machine Learning",
        "iOS 26 Features"
    ]
    
    var filteredItems: [String] {
        if query.isEmpty { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredItems, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("Поиск")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}
