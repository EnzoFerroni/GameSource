//
//  GameRowView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// A single game in the library list: cover, name and playtime.
struct GameRowView: View {

    let game: SteamGame

    var body: some View {
        HStack(spacing: 12) {
            cover

            VStack(alignment: .leading, spacing: 4) {
                Text(game.name)
                    .font(.headline)
                    .lineLimit(2)

                Label(game.formattedPlaytime, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // AsyncImage downloads the cover lazily; the placeholder keeps
    // the row size stable while the image loads or if it fails.
    private var cover: some View {
        AsyncImage(url: game.coverURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(.quaternary)

                Image(systemName: "gamecontroller")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 50, height: 75)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    GameRowView(
        game: SteamGame(appid: 440, name: "Team Fortress 2", playtimeForever: 7500)
    )
}
