import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    var totalHours: Double
    var goals: [VolunteerGoal]
    
    // Add coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case totalHours
        case goals
    }
}

struct VolunteerGoal: Codable, Identifiable {
    let id: String
    let targetHours: Double
    let deadline: Date
    let title: String
    var currentHours: Double
    
    // Add coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case targetHours
        case deadline
        case title
        case currentHours
    }
} 