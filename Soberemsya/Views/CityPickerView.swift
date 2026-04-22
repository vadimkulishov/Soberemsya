import SwiftUI

struct CityPickerView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    let cities = City.russianCities.map { $0.name }.sorted()
    var onSelect: (String) -> Void
    
    var filteredCities: [String] {
        if searchText.isEmpty {
            return cities
        }
        return cities.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCities, id: \.self) { city in
                Button(action: {
                    onSelect(city)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                        Text(city)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Выбор города")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Найти город")
        }
    }
}
