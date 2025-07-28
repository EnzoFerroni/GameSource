//
//  ContentView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                AuthenticatedView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
