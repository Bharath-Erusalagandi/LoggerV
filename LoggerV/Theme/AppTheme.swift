import SwiftUI

enum AppTheme {
    static let primaryBlue = Color(red: 0, green: 122/255, blue: 255/255)
    static let secondaryBlue = Color(red: 64/255, green: 156/255, blue: 255/255)
    static let backgroundColor = Color.black
    static let cardBackground = Color(white: 0.1)
    
    static let animation = Animation.easeInOut(duration: 0.3)
    
    struct TextStyles {
        static let title = Font.title.weight(.bold)
        static let heading = Font.headline.weight(.semibold)
        static let body = Font.body
    }
} 