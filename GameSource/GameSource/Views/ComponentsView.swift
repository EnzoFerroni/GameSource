//
//  UIComponents.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import SwiftUI

// MARK: - App Header View
struct AppHeaderView: View {
    let iconName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Error Message View
struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Steam Login Button
struct SteamLoginButton: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title2)
                }
                
                Text(isLoading ? "Connecting..." : "Sign in with Steam")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Preview Providers
#Preview("App Header") {
    AppHeaderView(
        iconName: "gamecontroller.fill",
        title: "GameSource",
        subtitle: "Connect with Steam to get started"
    )
    .padding()
}

#Preview("Error Message") {
    ErrorMessageView(message: "Failed to authenticate with Steam. Please try again.") {
        print("Error dismissed")
    }
    .padding()
}

#Preview("Steam Login Button") {
    VStack(spacing: 20) {
        SteamLoginButton(isLoading: false) {
            print("Login tapped")
        }
        
        SteamLoginButton(isLoading: true) {
            print("Login tapped")
        }
    }
    .padding()
}