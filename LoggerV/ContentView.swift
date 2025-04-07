//
//  ContentView.swift
//  LoggerV
//
//  Created by Bharath Erusalagandi on 1/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            Group {
                switch appState.authState {
                case .unauthenticated:
                    LoginView()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                case .authenticated:
                    MainTabView()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                case .loading:
                    LoadingView()
                        .transition(.opacity)
                }
            }
        }
        .animation(AppTheme.animation, value: appState.authState)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryBlue))
            (/*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/)
                .foregroundColor(AppTheme.primaryBlue)
                .font(AppTheme.TextStyles.body)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

