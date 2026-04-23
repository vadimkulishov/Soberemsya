import Testing
import Foundation
@testable import Soberemsya

@MainActor
@Suite("Event Model Tests")
struct EventTests {

    @Test("Default initialization")
    func defaultInit() {
        let event = Event()
        #expect(event.id == 0)
        #expect(event.title == "")
        #expect(event.description == "")
        #expect(event.date == "")
        #expect(event.location == "")
        #expect(event.category == "Музыка")
        #expect(event.timeStart == nil)
        #expect(event.timeEnd == nil)
        #expect(event.city == nil)
        #expect(event.imageName == nil)
        #expect(event.capacity == nil)
    }

    @Test("Custom initialization")
    func customInit() {
        let event = Event(
            id: 42,
            title: "Concert",
            description: "Great show",
            date: "25.04.2026",
            timeStart: "19:00",
            timeEnd: "22:00",
            location: "Stadium",
            city: "Москва",
            category: "Спорт",
            capacity: 1000
        )
        #expect(event.id == 42)
        #expect(event.title == "Concert")
        #expect(event.timeStart == "19:00")
        #expect(event.city == "Москва")
        #expect(event.capacity == 1000)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let event = Event(
            id: 1,
            title: "Test",
            description: "Desc",
            date: "01.01.2026",
            timeStart: "10:00",
            location: "Place",
            city: "Казань",
            category: "Кино"
        )
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(Event.self, from: data)
        #expect(decoded == event)
    }

    @Test("CodingKeys snake_case mapping")
    func codingKeysMapping() throws {
        let json = """
        {
            "id": 5,
            "title": "Event",
            "description": "Desc",
            "date": "01.01.2026",
            "time_start": "18:00",
            "time_end": "20:00",
            "location": "Venue",
            "city": "Сочи",
            "image_url": "https://example.com/img.jpg",
            "category": "Музыка",
            "capacity": 500,
            "registered_count": 100,
            "is_active": true,
            "is_published": true,
            "created_at": "2026-01-01"
        }
        """.data(using: .utf8)!

        let event = try JSONDecoder().decode(Event.self, from: json)
        #expect(event.id == 5)
        #expect(event.timeStart == "18:00")
        #expect(event.timeEnd == "20:00")
        #expect(event.imageName == "https://example.com/img.jpg")
        #expect(event.registeredCount == 100)
        #expect(event.isActive == true)
        #expect(event.isPublished == true)
        #expect(event.createdAt == "2026-01-01")
    }

    @Test("Equatable conformance")
    func equatable() {
        let event1 = Event(id: 1, title: "A", description: "B", date: "01.01.2026", location: "C")
        let event2 = Event(id: 1, title: "A", description: "B", date: "01.01.2026", location: "C")
        let event3 = Event(id: 2, title: "A", description: "B", date: "01.01.2026", location: "C")
        #expect(event1 == event2)
        #expect(event1 != event3)
    }
}
