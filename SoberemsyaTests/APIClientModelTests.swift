import Testing
import Foundation
@testable import Soberemsya

@MainActor
@Suite("API Client Model Tests")
struct APIClientModelTests {

    @Test("AuthResponse decoding")
    func authResponseDecoding() throws {
        let json = """
        {
            "access_token": "jwt_token_here",
            "user": {
                "id": 1,
                "username": "testuser",
                "email": "test@example.com",
                "full_name": "Test User",
                "city": "Москва",
                "phone": null,
                "role": "user",
                "qr_code_data": null,
                "profile_completed": true,
                "is_active": true,
                "created_at": "2026-01-01"
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AuthResponse.self, from: json)
        #expect(response.accessToken == "jwt_token_here")
        #expect(response.user.id == 1)
        #expect(response.user.username == "testuser")
        #expect(response.user.email == "test@example.com")
        #expect(response.user.fullName == "Test User")
        #expect(response.user.city == "Москва")
        #expect(response.user.profileCompleted == true)
    }

    @Test("EventResponse decoding")
    func eventResponseDecoding() throws {
        let json = """
        {
            "id": 10,
            "title": "Music Festival",
            "description": "Annual music festival",
            "date": "01.06.2026",
            "time_start": "12:00",
            "time_end": "23:00",
            "location": "Park",
            "city": "Москва",
            "category": "Музыка",
            "capacity": 5000,
            "registered_count": 1500,
            "image_url": "https://example.com/img.jpg",
            "is_active": true,
            "is_published": true,
            "organizer": "admin",
            "created_at": "2026-04-01"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(EventResponse.self, from: json)
        #expect(response.id == 10)
        #expect(response.title == "Music Festival")
        #expect(response.timeStart == "12:00")
        #expect(response.registeredCount == 1500)
        #expect(response.imageName == "https://example.com/img.jpg")
        #expect(response.organizer == "admin")
    }

    @Test("EventsListResponse decoding")
    func eventsListResponseDecoding() throws {
        let json = """
        {
            "events": [],
            "total": 0,
            "page": 1,
            "per_page": 10
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(EventsListResponse.self, from: json)
        #expect(response.events.isEmpty)
        #expect(response.total == 0)
        #expect(response.page == 1)
        #expect(response.perPage == 10)
    }

    @Test("APIError descriptions are non-empty")
    func apiErrorDescriptions() {
        let errors: [APIError] = [
            .invalidURL,
            .invalidResponse,
            .decodingError,
            .unauthorizedError,
            .serverError("test"),
            .networkError,
            .unknown("test error")
        ]

        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }

    @Test("APIError serverError includes message")
    func apiErrorServerMessage() {
        let error = APIError.serverError("DB connection failed")
        #expect(error.errorDescription?.contains("DB connection failed") == true)
    }

    @Test("QRCodeResponse decoding")
    func qrCodeResponseDecoding() throws {
        let json = """
        {
            "user_id": 1,
            "qr_code_base64": "base64data",
            "qr_code_data": "qrdata"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(QRCodeResponse.self, from: json)
        #expect(response.userId == 1)
        #expect(response.qrCodeBase64 == "base64data")
        #expect(response.qrCodeData == "qrdata")
    }
}
