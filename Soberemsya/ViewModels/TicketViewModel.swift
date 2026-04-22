import Foundation
import Combine

class TicketViewModel: ObservableObject {
    @Published var qrToken: QRToken?
    @Published var userTickets: UserTicketsResponse?
    @Published var isLoading = false
    @Published var error: APIError? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let apiClient = APIClient.shared
    
    // MARK: - QR Code Methods
    
    func generateQRCode() {
        isLoading = true
        error = nil
        
        apiClient.generateQRToken()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                    print("❌ TicketViewModel: Failed to generate QR - \(error)")
                }
            } receiveValue: { [weak self] token in
                self?.qrToken = token
                print("✅ TicketViewModel: QR token generated")
            }
            .store(in: &cancellables)
    }
    
    func getQRCode() {
        isLoading = true
        error = nil
        
        apiClient.getQRToken()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                    print("❌ TicketViewModel: Failed to get QR - \(error)")
                }
            } receiveValue: { [weak self] token in
                self?.qrToken = token
                print("✅ TicketViewModel: QR token retrieved")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Registration Methods
    
    func registerForEvent(_ eventId: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        apiClient.registerForEvent(eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion_result in
                self?.isLoading = false
                
                if case let .failure(error) = completion_result {
                    self?.error = error
                    print("❌ TicketViewModel: Failed to register - \(error)")
                    completion(false)
                }
            } receiveValue: { [weak self] _ in
                self?.loadMyTickets()
                print("✅ TicketViewModel: Registered for event")
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    func unregisterFromEvent(_ eventId: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        apiClient.unregisterFromEvent(eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion_result in
                self?.isLoading = false
                
                if case let .failure(error) = completion_result {
                    self?.error = error
                    print("❌ TicketViewModel: Failed to unregister - \(error)")
                    completion(false)
                }
            } receiveValue: { [weak self] _ in
                self?.loadMyTickets()
                print("✅ TicketViewModel: Unregistered from event")
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tickets Methods
    
    func loadMyTickets() {
        isLoading = true
        error = nil
        
        apiClient.getMyTickets()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case let .failure(error) = completion {
                    self?.error = error
                    print("❌ TicketViewModel: Failed to load tickets - \(error)")
                }
            } receiveValue: { [weak self] tickets in
                self?.userTickets = tickets
                print("✅ TicketViewModel: Loaded \(tickets.registrations.count) tickets")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    func isRegisteredForEvent(_ eventId: Int) -> Bool {
        guard let tickets = userTickets else { return false }
        return tickets.registrations.contains { $0.eventId == eventId }
    }
    
    func getRegistrationForEvent(_ eventId: Int) -> EventRegistration? {
        guard let tickets = userTickets else { return nil }
        return tickets.registrations.first { $0.eventId == eventId }
    }
}
