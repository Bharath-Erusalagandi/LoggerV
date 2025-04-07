//
//  LoggerVApp.swift
//  LoggerV
//
//  Created by Bharath Erusalagandi on 1/1/25.
//

import SwiftUI

@main
struct LoggerVApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark) // Enable dark mode by default
                .accentColor(.blue)
        }
    }
}
