import SwiftUI

class AppState: ObservableObject {
    enum AuthState: Equatable {
        case unauthenticated
        case authenticated(User)
        case loading
        
        // Implement Equatable manually since we have associated values
        static func == (lhs: AuthState, rhs: AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.unauthenticated, .unauthenticated):
                return true
            case (.loading, .loading):
                return true
            case let (.authenticated(user1), .authenticated(user2)):
                return user1.id == user2.id
            default:
                return false
            }
        }
    }
    
    @Published var authState: AuthState = .unauthenticated
    @Published var logs: [VolunteerLog] = []
    @Published var selectedDate: Date = Date()
    @Published var isAddingNewLog: Bool = false
    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    
    // Cloud sync status
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
} 