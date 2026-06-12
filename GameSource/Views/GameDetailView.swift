//
//  GameDetailView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// Detail sheet for a game: banner, stats and a link to the store.
// Uses only data already loaded by the library, so no extra request.
struct GameDetailView: View {

    let game: SteamGame

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    banner

                    Text(game.name)
                        .font(.title2.bold())

                    stats

                    if let storeURL {
                        Link(destination: storeURL) {
                            Label("View on Steam Store", systemImage: "cart")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Steam's wide banner keeps a 460x215 ratio.
    private var banner: some View {
        AsyncImage(url: game.headerURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(.quaternary)

                Image(systemName: "gamecontroller")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .aspectRatio(460 / 215, contentMode: .fit)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var stats: some View {
        VStack(spacing: 16) {
            statRow(
                icon: "clock",
                title: "Total Playtime",
                value: game.formattedPlaytime
            )

            statRow(
                icon: "gamecontroller",
                title: "App ID",
                value: "\(game.appid)"
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }

    private var storeURL: URL? {
        URL(string: "https://store.steampowered.com/app/\(game.appid)")
    }
}

#Preview {
    GameDetailView(
        game: SteamGame(appid: 440, name: "Team Fortress 2", playtimeForever: 7500)
    )
}
