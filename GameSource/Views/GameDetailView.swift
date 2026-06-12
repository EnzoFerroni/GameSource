//
//  GameDetailView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// Detail screen for a game: banner, playtime and a link to the store.
// Uses only data already loaded by the library, so no extra request.
struct GameDetailView: View {

    let game: SteamGame

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                banner

                VStack(alignment: .leading, spacing: 12) {
                    Text(game.name)
                        .font(.title.bold())

                    Label(
                        "\(game.formattedPlaytime) played",
                        systemImage: "clock"
                    )
                    .font(.headline)
                    .foregroundStyle(.secondary)

                    if let storeURL {
                        Link(destination: storeURL) {
                            Label("View on Steam Store", systemImage: "cart")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
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
    }

    private var storeURL: URL? {
        URL(string: "https://store.steampowered.com/app/\(game.appid)")
    }
}

#Preview {
    NavigationStack {
        GameDetailView(
            game: SteamGame(appid: 440, name: "Team Fortress 2", playtimeForever: 7500)
        )
    }
}
