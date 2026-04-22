import Foundation

struct User: Codable {
    var id: Int?  // ID с backend'а
    var username: String
    var name: String  // full_name
    var email: String
    var city: String
    var phone: String?
    var avatarData: Data?
    var qrCodeData: String?  // QR код с backend'а
    var registeredEventIds: [Int]  // IDs событий с backend'а
    var role: String  // user, organizer, admin
    var profileCompleted: Bool
    var isActive: Bool
    var createdAt: Date
    
    init(
        id: Int? = nil,
        username: String = "",
        name: String = "",
        email: String = "",
        city: String = "",
        phone: String? = nil,
        avatarData: Data? = nil,
        qrCodeData: String? = nil,
        registeredEventIds: [Int] = [],
        role: String = "user",
        profileCompleted: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.city = city
        self.phone = phone
        self.avatarData = avatarData
        self.qrCodeData = qrCodeData
        self.registeredEventIds = registeredEventIds
        self.role = role
        self.profileCompleted = profileCompleted
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
