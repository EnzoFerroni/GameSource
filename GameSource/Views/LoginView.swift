//
//  LoginView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import SwiftUI

// Entry screen: signs in through Steam's real OpenID page.
// The view model stores the SteamID on success, which makes the
// app root swap to the library automatically.
struct LoginView: View {

    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            header

            VStack(spacing: 16) {
                signInButton

                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }

            Text("You will be redirected to the official Steam page. Your profile must be public.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                // Decorative image. The app name below says it all.
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("GameSource")
                    .font(.largeTitle.bold())

                Text("Connect with Steam to browse your library")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var signInButton: some View {
        Button {
            viewModel.signIn()
        } label: {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
                else {
                    Image(systemName: "gamecontroller")
                }

                Text(viewModel.isLoading ? "Connecting..." : "Sign in with Steam")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    LoginView()
}
