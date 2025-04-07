import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isDarkMode = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                LogsView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                    .tag(0)
                
                CalendarView()
                    .tabItem {
                        Label("Log", systemImage: "square.and.pencil")
                    }
                    .tag(1)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .tint(isDarkMode ? .white : .blue)
        }
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

struct LogsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingLogSheet = false
    @State private var selectedTimeFrame = "Weekly"
    @State private var isDarkMode = false
    @State private var showingGoalPrompt = false
    @State private var targetHours = 1.0
    @State private var targetOrgs = 1
    @Binding var selectedTab: Int
    let timeFrames = ["Weekly", "Monthly"]
    
    // Add this to check if it's a new day
    private var shouldShowGoalPrompt: Bool {
        if let lastPromptDate = UserDefaults.standard.object(forKey: "LastGoalPromptDate") as? Date {
            return !Calendar.current.isDate(lastPromptDate, inSameDayAs: Date())
        }
        return true
    }
    
    private var savedTargetHours: Double {
        UserDefaults.standard.double(forKey: "DailyTargetHours")
    }
    
    private var savedTargetOrgs: Int {
        UserDefaults.standard.integer(forKey: "DailyTargetOrgs")
    }
    
    // Add these computed properties to track progress
    private var todaysLogs: [VolunteerLog] {
        appState.logs.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var hoursCompleted: Double {
        todaysLogs.reduce(0) { $0 + $1.duration }
    }
    
    private var uniqueOrganizationsToday: Int {
        Set(todaysLogs.map { $0.organization }).count
    }
    
    private var bestResultText: String {
        let targetHours = UserDefaults.standard.double(forKey: "DailyTargetHours")
        let targetOrgs = UserDefaults.standard.integer(forKey: "DailyTargetOrgs")
        
        if targetHours > 0 {
            return String(format: "Hours: %.1f/%.1f", hoursCompleted, targetHours)
        } else if targetOrgs > 0 {
            return "Organizations: \(uniqueOrganizationsToday)/\(targetOrgs)"
        } else {
            return "Set your daily goals"
        }
    }
    
    // Add this computed property to calculate progress percentage
    @State private var forceUpdate = false
    
    private var progressPercentage: Double {
        let targetHours = UserDefaults.standard.double(forKey: "DailyTargetHours")
        if targetHours > 0 {
            return min((hoursCompleted / targetHours) * 100, 100)
        }
        return 0
    }
    
    // Add this computed property for the progress message
    private var progressMessage: String {
        if progressPercentage >= 100 {
            return "You Reached your goal!"
        } else if progressPercentage >= 75 {
            return "You're so close to your goal!"
        } else if progressPercentage >= 25 {
            return "You are doing Great!"
        } else {
            return "Keep Going!"
        }
    }
    
    var userName: String {
        if case .authenticated(let user) = appState.authState {
            return user.name
        }
        return ""
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color(white: 0.97))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with share button
                        HStack {
                            Text("Statistics")
                                .font(.subheadline)
                                .foregroundColor(Color(.darkGray))
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color(.darkGray))
                            }
                        }
                        
                        // Greeting with fixed colors
                        HStack(spacing: 8) {
                            Text("Hello")
                                .font(.title)
                                .foregroundColor(Color(.label))
                            Text(userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.label))
                            Image(systemName: "hand.wave.fill")
                                .foregroundColor(.yellow)
                        }
                        
                        // Progress indicators with fixed colors
                        HStack {
                            Spacer()
                            Text(bestResultText)
                                .font(.caption)
                                .foregroundColor(Color(.darkGray))
                        }
                    }
                    .padding(20)
                    .background(isDarkMode ? Color(white: 0.2) : .white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    .padding()
                    
                    // Progress Section
                    VStack(spacing: 20) {
                        HStack {
                            // Time frame selector with better contrast
                            Picker("Time Frame", selection: $selectedTimeFrame) {
                                ForEach(timeFrames, id: \.self) { frame in
                                    Text(frame)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .colorMultiply(isDarkMode ? .white : .black)
                            
                            Spacer()
                        }
                        
                        // Progress Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your progress")
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            HStack {
                                Text(progressMessage)
                                    .font(.title3)
                                    .foregroundColor(isDarkMode ? .white : .black.opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(Int(progressPercentage))%")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.blue)
                                        .frame(width: geometry.size.width * progressPercentage / 100, height: 10)
                                }
                            }
                            .frame(height: 10)
                        }
                        .padding(20)
                        .background(isDarkMode ? Color(white: 0.2) : Color(hex: "E0FFFF"))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Today's Goals Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today's Goals")
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(AppTheme.primaryBlue)
                                    Text("Target Hours:")
                                        .foregroundColor(isDarkMode ? .gray : .black.opacity(0.6))
                                    Spacer()
                                    Text("\(savedTargetHours, specifier: "%.1f") hrs")
                                        .fontWeight(.semibold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                
                                HStack {
                                    Image(systemName: "building.2")
                                        .foregroundColor(AppTheme.primaryBlue)
                                    Text("Organizations:")
                                        .foregroundColor(isDarkMode ? .gray : .black.opacity(0.6))
                                    Spacer()
                                    Text("\(savedTargetOrgs) org\(savedTargetOrgs > 1 ? "s" : "")")
                                        .fontWeight(.semibold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                
                                Button(action: { showingGoalPrompt = true }) {
                                    Text("Update Goals")
                                        .font(.footnote)
                                        .foregroundColor(AppTheme.primaryBlue)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(20)
                        .background(isDarkMode ? Color(white: 0.2) : Color(hex: "E0FFFF"))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTab = 2
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                if shouldShowGoalPrompt {
                    showingGoalPrompt = true
                }
            }
            .sheet(isPresented: $showingGoalPrompt) {
                GoalPromptView(isPresented: $showingGoalPrompt, targetHours: $targetHours, targetOrgs: $targetOrgs)
            }
            .onChange(of: showingGoalPrompt) { _ in
                // Force UI update when goals change
                forceUpdate.toggle()
            }
        }
        .tint(isDarkMode ? .white : .blue)
        .tabItem {
            Label("Info", systemImage: "info.circle")
                .environment(\.colorScheme, isDarkMode ? .dark : .light)
        }
        .animation(.easeInOut(duration: 0.3), value: isDarkMode)
    }
}

struct LogRow: View {
    let log: VolunteerLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.organization)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f hrs", log.duration))
                    .font(.subheadline)
            }
            
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text(log.category.rawValue.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(AppTheme.primaryBlue.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(formatDate(log.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.15))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .listRowBackground(AppTheme.backgroundColor)
        .foregroundColor(.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingLogSheet = false
    @State private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color(white: 0.97))
                    .ignoresSafeArea()
                
                if appState.logs.isEmpty {
                    VStack {
                        Text("Here you can log your volunteer hours")
                            .foregroundColor(isDarkMode ? .white : .black)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(appState.logs.sorted(by: { $0.date > $1.date })) { log in
                                LogCard(log: log, isDarkMode: isDarkMode)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Logs")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingLogSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingLogSheet) {
            LogVolunteerHoursView()
        }
    }
}

struct LogCard: View {
    let log: VolunteerLog
    let isDarkMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.organization)
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Spacer()
                
                Text(String(format: "%.1f hrs", log.duration))
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(isDarkMode ? .gray : .black.opacity(0.6))
            
            HStack {
                Text(log.category.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryBlue.opacity(0.2))
                    .cornerRadius(6)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Spacer()
                
                Text(formatDate(log.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(isDarkMode ? Color(white: 0.15) : Color(hex: "FFFACD").opacity(0.5))
        .cornerRadius(15)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingLogSheet = false
    @State private var isEditingProfile = false
    @State private var bio = ""
    @State private var location = ""
    @State private var interests: [String] = []
    @State private var newInterest = ""
    @State private var hasProfile = false
    @State private var showingLogoutAlert = false
    @State private var isDarkMode = false
    
    var userName: String {
        if case .authenticated(let user) = appState.authState {
            return user.name
        }
        return ""
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color(white: 0.97))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Hi, \(userName)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(.top, 20)
                        
                        if !isEditingProfile {
                            VStack(spacing: 16) {
                                if !hasProfile {
                                    Button(action: { isEditingProfile = true }) {
                                        HStack {
                                            Text("Create Your Profile")
                                                .font(.headline)
                                            Image(systemName: "arrow.right")
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppTheme.primaryBlue)
                                        .cornerRadius(10)
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 20) {
                                        // About Me section
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("About Me")
                                                .font(.headline)
                                                .foregroundColor(isDarkMode ? .white : .black)
                                            Text(bio)
                                                .foregroundColor(isDarkMode ? .gray : .black.opacity(0.7))
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(isDarkMode ? Color(white: 0.15) : .white)
                                        .cornerRadius(12)
                                        
                                        // Location section
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Location")
                                                .font(.headline)
                                                .foregroundColor(isDarkMode ? .white : .black)
                                            Text(location)
                                                .foregroundColor(isDarkMode ? .gray : .black.opacity(0.7))
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(isDarkMode ? Color(white: 0.15) : .white)
                                        .cornerRadius(12)
                                        
                                        // Interests section
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Interests")
                                                .font(.headline)
                                                .foregroundColor(isDarkMode ? .white : .black)
                                            FlowLayout(items: interests) { _ in }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(isDarkMode ? Color(white: 0.15) : .white)
                                        .cornerRadius(12)
                                    }
                                }
                                
                                // Impact section
                                VStack(spacing: 12) {
                                    Text("Your Impact")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    
                                    HStack(spacing: 30) {
                                        StatView(title: "Hours", value: String(format: "%.1f", appState.logs.reduce(0) { $0 + $1.duration }))
                                        StatView(title: "Activities", value: "\(appState.logs.count)")
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(isDarkMode ? Color(white: 0.15) : .white)
                                .cornerRadius(12)
                                
                                // Logout button
                                Button(action: { showingLogoutAlert = true }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Log Out")
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isDarkMode ? Color(white: 0.15) : .white)
                                    .cornerRadius(12)
                                }
                                .padding(.top, 20)
                            }
                        } else {
                            // Edit Profile Form
                            VStack(alignment: .leading, spacing: 20) {
                                Text(hasProfile ? "Edit Profile" : "Create Profile")
                                    .font(.headline)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                // Text fields with proper colors
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bio")
                                        .foregroundColor(isDarkMode ? .gray : .black.opacity(0.6))
                                    TextField("Tell us about yourself", text: $bio, axis: .vertical)
                                        .textFieldStyle(.plain)
                                        .padding()
                                        .background(isDarkMode ? Color(white: 0.1) : Color(white: 0.95))
                                        .cornerRadius(10)
                                        .foregroundColor(Color(.label))
                                        .lineLimit(3...6)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location")
                                        .foregroundColor(isDarkMode ? .gray : .black.opacity(0.6))
                                    TextField("Your city", text: $location)
                                        .textFieldStyle(.plain)
                                        .padding()
                                        .background(isDarkMode ? Color(white: 0.1) : Color(white: 0.95))
                                        .cornerRadius(10)
                                        .foregroundColor(Color(.label))
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Interests")
                                        .foregroundColor(isDarkMode ? .gray : .black.opacity(0.6))
                                    
                                    FlowLayout(items: interests) { interest in
                                        interests.removeAll { $0 == interest }
                                    }
                                    
                                    HStack {
                                        TextField("Add interest", text: $newInterest)
                                            .textFieldStyle(.plain)
                                            .padding()
                                            .background(isDarkMode ? Color(white: 0.1) : Color(white: 0.95))
                                            .cornerRadius(10)
                                            .foregroundColor(Color(.label))
                                        
                                        Button(action: addInterest) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(AppTheme.primaryBlue)
                                        }
                                        .disabled(newInterest.isEmpty)
                                    }
                                }
                                
                                Button(action: saveProfile) {
                                    Text(hasProfile ? "Save Changes" : "Save Profile")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppTheme.primaryBlue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    private func addInterest() {
        if !newInterest.isEmpty {
            interests.append(newInterest)
            newInterest = ""
        }
    }
    
    private func saveProfile() {
        hasProfile = true
        isEditingProfile = false
    }
    
    private func logout() {
        bio = ""
        location = ""
        interests = []
        hasProfile = false
        isEditingProfile = false
        
        appState.authState = .unauthenticated
    }
}

// Helper Views
struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryBlue)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct InterestTag: View {
    let interest: String
    let onDelete: () -> Void
    var showDelete: Bool = true
    
    var body: some View {
        HStack(spacing: 4) {
            Text(interest)
                .font(.subheadline)
            if showDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppTheme.primaryBlue.opacity(0.2))
        .cornerRadius(8)
        .foregroundColor(.white)
    }
}

struct FlowLayout: View {
    let items: [String]
    let onDelete: (String) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                InterestTag(interest: item) {
                    onDelete(item)
                }
            }
        }
    }
}

// Add this new view for the goal prompt
struct GoalPromptView: View {
    @Binding var isPresented: Bool
    @Binding var targetHours: Double
    @Binding var targetOrgs: Int
    @State private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color(white: 0.97))
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("What's your goal for today?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Hours goal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Volunteer Hours")
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            HStack {
                                Slider(value: $targetHours, in: 0.5...8, step: 0.5)
                                    .accentColor(AppTheme.primaryBlue)
                                
                                Text("\(targetHours, specifier: "%.1f") hrs")
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .frame(width: 60)
                            }
                        }
                        .padding()
                        .background(isDarkMode ? Color(white: 0.15) : .white)
                        .cornerRadius(12)
                        
                        // Organizations goal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Organizations to Visit")
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            HStack {
                                Stepper("\(targetOrgs) org\(targetOrgs > 1 ? "s" : "")", value: $targetOrgs, in: 1...5)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                        }
                        .padding()
                        .background(isDarkMode ? Color(white: 0.15) : .white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: saveGoals) {
                        Text("Set Goals")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private func saveGoals() {
        // Save the goals
        UserDefaults.standard.set(targetHours, forKey: "DailyTargetHours")
        UserDefaults.standard.set(targetOrgs, forKey: "DailyTargetOrgs")
        UserDefaults.standard.set(Date(), forKey: "LastGoalPromptDate")
        
        // Force immediate UI update
        NotificationCenter.default.post(name: NSNotification.Name("GoalsUpdated"), object: nil)
        
        isPresented = false
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
} 