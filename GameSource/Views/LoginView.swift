//
//  LoginView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import SwiftUI

// Entry screen: asks for the user's SteamID before showing the library.
// A full Steam OpenID login would need a web session; for this scope
// the public SteamID is enough, since the API only reads public data.
struct LoginView: View {

    // Persisted across launches. The app switches to the library
    // as soon as this stops being empty.
    @AppStorage("steamID") private var steamID = ""

    @State private var typedID = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            header

            VStack(spacing: 16) {
                TextField("SteamID (64-bit)", text: $typedID)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Button {
                    steamID = typedID
                } label: {
                    Label("View Library", systemImage: "gamecontroller")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                // Avoids "logging in" with an empty or partial ID.
                .disabled(typedID.count < 17)
            }

            Text("Find your SteamID at steamid.io. Your profile must be public.")
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

            VStack(spacing: 8) {
                Text("GameSource")
                    .font(.largeTitle.bold())

                Text("Enter your SteamID to browse your library")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    LoginView()
}
