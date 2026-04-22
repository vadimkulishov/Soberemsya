import Foundation

struct Event: Identifiable, Codable, Equatable {
    var id: Int  // ID с backend'а (int вместо UUID)
    var title: String
    var description: String
    var date: String  // DD.MM.YYYY format
    var timeStart: String?
    var timeEnd: String?
    var location: String
    var city: String?
    var imageName: String?
    var category: String
    var capacity: Int?
    var registeredCount: Int?
    var isActive: Bool?
    var isPublished: Bool?
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case timeStart = "time_start"
        case timeEnd = "time_end"
        case location
        case city
        case imageName = "image_url"
        case category
        case capacity
        case registeredCount = "registered_count"
        case isActive = "is_active"
        case isPublished = "is_published"
        case createdAt = "created_at"
    }
    
    init(
        id: Int = 0,
        title: String = "",
        description: String = "",
        date: String = "",
        timeStart: String? = nil,
        timeEnd: String? = nil,
        location: String = "",
        city: String? = nil,
        imageName: String? = nil,
        category: String = "Музыка",
        capacity: Int? = nil,
        registeredCount: Int? = nil,
        isActive: Bool? = nil,
        isPublished: Bool? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.location = location
        self.city = city
        self.imageName = imageName
        self.category = category
        self.capacity = capacity
        self.registeredCount = registeredCount
        self.isActive = isActive
        self.isPublished = isPublished
        self.createdAt = createdAt
    }
}
