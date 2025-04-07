import SwiftUI

struct ElegantCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from top-left and extend beyond top edge
        path.move(to: CGPoint(x: 0, y: -100)) // Move start point up
        
        // Line to top-right
        path.addLine(to: CGPoint(x: rect.width, y: -100)) // Extend top right point up
        
        // Line down right side
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.7))
        
        // Smooth curve to bottom-left
        let control1 = CGPoint(x: rect.width * 0.8, y: rect.height * 1.1)
        let control2 = CGPoint(x: rect.width * 0.4, y: rect.height * 0.8)
        let endPoint = CGPoint(x: 0, y: rect.height * 0.85)
        
        path.addCurve(to: endPoint,
                     control1: control1,
                     control2: control2)
        
        // Close the path
        path.addLine(to: CGPoint(x: 0, y: -100)) // Connect back to top-left
        
        return path
    }
}

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var isSignIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isDarkMode = false
    
    var body: some View {
        ZStack {
            // Background color based on dark mode
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Elegant curved section with gradient
                ZStack {
                    ElegantCurvedShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "1E3A8A"),
                                    Color(hex: "2563EB")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 320)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 20) {
                        // Content container
                        VStack(spacing: 16) {
                            // Centered App Name
                            Text("LoggerV")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Sign up section
                            VStack(alignment: .leading, spacing: 8) {
                                Text(isSignIn ? "Sign in" : "Sign up")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                if !isSignIn {
                                    Text("Please enter the required\ninformation to sign in to LoggerV.")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineSpacing(4)
                                }
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 30)
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxHeight: 320, alignment: .top) // Constrain to shape height
                }
                
                // Form section
                ScrollView {
                    VStack(spacing: 20) {
                        if !isSignIn {
                            // Name field
                            TextField("", text: $name)
                                .placeholder(when: name.isEmpty) {
                                    Text("Full Name").foregroundColor(.gray)
                                }
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color(white: 0.97)) // Subtle grey
                                .cornerRadius(10)
                        }
                        
                        // Email field
                        TextField("", text: $email)
                            .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(.gray)
                            }
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(white: 0.97)) // Subtle grey
                            .cornerRadius(10)
                        
                        // Password field
                        SecureField("", text: $password)
                            .placeholder(when: password.isEmpty) {
                                Text("Password").foregroundColor(.gray)
                            }
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(white: 0.97)) // Subtle grey
                            .cornerRadius(10)
                        
                        if !isSignIn {
                            // Confirm Password field
                            SecureField("", text: $confirmPassword)
                                .placeholder(when: confirmPassword.isEmpty) {
                                    Text("Confirm Password").foregroundColor(.gray)
                                }
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color(white: 0.97)) // Subtle grey
                                .cornerRadius(10)
                        }
                        
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .transition(.opacity)
                        }
                        
                        // Next/Sign in button
                        Button(action: isSignIn ? signIn : signUp) {
                            Text(isSignIn ? "Sign In" : "Next")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "2563EB"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.headline)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 24)
                    
                    // Sign in/up toggle
                    HStack {
                        Text(isSignIn ? "Don't have an account?" : "Already have an account?")
                            .foregroundColor(isDarkMode ? .white : .gray)
                        Button(action: {
                            isSignIn.toggle()
                            showError = false
                            errorMessage = ""
                        }) {
                            Text(isSignIn ? "Sign up" : "Sign in")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "2563EB"))
                        }
                    }
                    
                    // Dark mode toggle
                    Button(action: { isDarkMode.toggle() }) {
                        HStack {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 16))
                            Text(isDarkMode ? "Light Mode" : "Dark Mode")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(isDarkMode ? .white : .gray)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isDarkMode)
    }
    
    private func signUp() {
        // Reset error state
        showError = false
        errorMessage = ""
        
        // Validate inputs
        if name.isEmpty {
            showError = true
            errorMessage = "Please enter your name"
            return
        }
        
        if email.isEmpty {
            showError = true
            errorMessage = "Please enter your email"
            return
        }
        
        if !email.lowercased().hasSuffix("@gmail.com") {
            showError = true
            errorMessage = "Please use a valid Gmail address"
            return
        }
        
        if password.isEmpty {
            showError = true
            errorMessage = "Please enter a password"
            return
        }
        
        if password != confirmPassword {
            showError = true
            errorMessage = "Passwords do not match"
            return
        }
        
        // Simulate authentication for now
        appState.authState = .loading
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: name,
                totalHours: 0,
                goals: []
            )
            appState.authState = .authenticated(user)
        }
    }
    
    private func signIn() {
        // Reset error state
        showError = false
        errorMessage = ""
        
        // Show message to sign up first
        showError = true
        errorMessage = "Please Sign up First"
        
        // Optional: Automatically switch to sign up after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSignIn = false  // Switch to sign up mode
            showError = false
            errorMessage = ""
        }
        
        // Comment out or remove the authentication simulation code
        /*
        // Validate inputs
        if email.isEmpty {
            showError = true
            errorMessage = "Please enter your email"
            return
        }
        
        if password.isEmpty {
            showError = true
            errorMessage = "Please enter your password"
            return
        }
        
        // Simulate authentication for now
        appState.authState = .loading
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: "Test User",
                totalHours: 0,
                goals: []
            )
            appState.authState = .authenticated(user)
        }
        */
    }
}

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
} 