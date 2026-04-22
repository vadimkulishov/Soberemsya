import SwiftUI

struct MyEventsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @State private var myEvents: [Event] = []
    @State private var isLoading = false
    @State private var showCreateEvent = false
    @State private var selectedEvent: Event?
    @State private var showEditEvent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if myEvents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Нет созданных событий")
                            .font(.headline)
                        Text("Создайте новое событие, чтобы привлечь участников")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignConstants.Colors.mainBackground(colorScheme: colorScheme))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(myEvents, id: \.id) { event in
                                EventCardComponent(event: event)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Мои события")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { showCreateEvent = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(DesignConstants.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView()
                    .onDisappear {
                        loadMyEvents()
                    }
            }
            .onAppear {
                loadMyEvents()
            }
        }
    }
    
    private func loadMyEvents() {
        isLoading = true
        
        // TODO: Call API to get user's events
        // apiClient.getMyEvents { result in
        //     isLoading = false
        //     switch result {
        //     case .success(let response):
        //         myEvents = response.events
        //     case .failure(let error):
        //         print("Error loading events: \(error)")
        //     }
        // }
        
        // For now, just show empty state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            myEvents = []
        }
    }
}

#Preview {
    MyEventsView()
        .environmentObject(AuthManager.shared)
        .environmentObject(ThemeManager.shared)
}
