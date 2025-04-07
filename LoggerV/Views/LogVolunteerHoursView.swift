import SwiftUI

struct LogVolunteerHoursView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var isDarkMode = false
    
    @State private var organization = ""
    @State private var description = ""
    @State private var duration = 1.0
    @State private var date = Date()
    @State private var category: VolunteerCategory = .education
    
    var body: some View {
        NavigationView {
            ZStack {
                (isDarkMode ? Color.black : Color(white: 0.97))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Organization")
                                .foregroundColor(isDarkMode ? .white : .black)
                            TextField("Enter organization name", text: $organization)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(isDarkMode ? Color(white: 0.2) : .white)
                                .cornerRadius(10)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Details")
                                .foregroundColor(isDarkMode ? .white : .black)
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                                .padding()
                                .background(isDarkMode ? Color(white: 0.2) : .white)
                                .cornerRadius(10)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time (hours)")
                                    .foregroundColor(isDarkMode ? .white : .black)
                                TextField("", value: $duration, format: .number)
                                    .textFieldStyle(.plain)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(isDarkMode ? Color(white: 0.2) : .white)
                                    .cornerRadius(10)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .foregroundColor(isDarkMode ? .white : .black)
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(isDarkMode ? Color(white: 0.2) : .white)
                                    .cornerRadius(10)
                                    .accentColor(AppTheme.primaryBlue)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .foregroundColor(isDarkMode ? .white : .black)
                            Menu {
                                ForEach(VolunteerCategory.allCases, id: \.self) { category in
                                    Button(category.rawValue) {
                                        self.category = category
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(category.rawValue)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                .padding()
                                .background(isDarkMode ? Color(white: 0.2) : .white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Log Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLog()
                        dismiss()
                    }
                    .disabled(organization.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveLog() {
        let log = VolunteerLog(
            id: UUID().uuidString,
            organization: organization,
            description: description,
            duration: duration,
            date: date,
            category: category
        )
        appState.logs.append(log)
    }
}

#Preview {
    LogVolunteerHoursView()
        .environmentObject(AppState())
} 