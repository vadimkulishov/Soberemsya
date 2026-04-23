import Testing
import Foundation
@testable import Soberemsya

@Suite("Registration Model Tests")
struct RegistrationTests {

    @Test("EventRegistration decoding from JSON")
    func eventRegistrationDecoding() throws {
        let json = """
        {
            "id": 1,
            "user_id": 42,
            "event_id": 10,
            "registered_at": "2026-04-23",
            "event": {
                "id": 10,
                "title": "Concert",
                "description": "Music event",
                "date": "01.05.2026",
                "location": "Arena",
                "category": "Музыка"
            }
        }
        """.data(using: .utf8)!

        let reg = try JSONDecoder().decode(EventRegistration.self, from: json)
        #expect(reg.id == 1)
        #expect(reg.userId == 42)
        #expect(reg.eventId == 10)
        #expect(reg.registeredAt == "2026-04-23")
        #expect(reg.event.title == "Concert")
    }

    @Test("QRToken decoding from JSON")
    func qrTokenDecoding() throws {
        let json = """
        {
            "token": "abc123",
            "created_at": "2026-04-23T10:00:00",
            "expires_at": "2026-04-24T10:00:00"
        }
        """.data(using: .utf8)!

        let token = try JSONDecoder().decode(QRToken.self, from: json)
        #expect(token.token == "abc123")
        #expect(token.createdAt == "2026-04-23T10:00:00")
        #expect(token.expiresAt == "2026-04-24T10:00:00")
    }

    @Test("UserTicketsResponse decoding")
    func userTicketsResponseDecoding() throws {
        let json = """
        {
            "id": 1,
            "email": "test@example.com",
            "username": "testuser",
            "registrations": []
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(UserTicketsResponse.self, from: json)
        #expect(response.id == 1)
        #expect(response.email == "test@example.com")
        #expect(response.username == "testuser")
        #expect(response.registrations.isEmpty)
    }

    @Test("QRToken Codable round-trip")
    func qrTokenRoundTrip() throws {
        let token = QRToken(token: "xyz789", createdAt: "2026-01-01", expiresAt: "2026-01-02")
        let data = try JSONEncoder().encode(token)
        let decoded = try JSONDecoder().decode(QRToken.self, from: data)
        #expect(decoded == token)
    }
}
