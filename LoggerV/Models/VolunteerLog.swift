import Foundation

struct VolunteerLog: Identifiable {
    let id: String
    let organization: String
    let description: String
    let duration: Double
    let date: Date
    let category: VolunteerCategory
} 