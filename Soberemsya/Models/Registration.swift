import Foundation

// MARK: - Event Registration

struct EventRegistration: Identifiable, Codable, Equatable {
    let id: Int
    let userId: Int
    let eventId: Int
    let registeredAt: String
    let event: Event
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventId = "event_id"
        case registeredAt = "registered_at"
        case event
    }
}

// MARK: - QR Token

struct QRToken: Codable, Equatable {
    let token: String
    let createdAt: String
    let expiresAt: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

// MARK: - User Tickets Response

struct UserTicketsResponse: Codable, Equatable {
    let id: Int
    let email: String
    let username: String
    let registrations: [EventRegistration]
}
