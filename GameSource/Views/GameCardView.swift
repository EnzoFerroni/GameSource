//
//  GameCardView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import SwiftUI

// A game cover card for the library grid: the 2:3 cover art with
// a dark gradient at the bottom so the name stays readable.
struct GameCardView: View {

    let game: SteamGame

    var body: some View {
        cover
            .aspectRatio(2 / 3, contentMode: .fit)
            .overlay(alignment: .bottom) {
                name
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // AsyncImage downloads the cover lazily; the placeholder keeps
    // the card size stable while the image loads or if it fails.
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
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var name: some View {
        Text(game.name)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.top, 32)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(
                // Fades the bottom of the cover to black behind the name.
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

#Preview {
    GameCardView(
        game: SteamGame(appid: 440, name: "Team Fortress 2", playtimeForever: 7500)
    )
    .frame(width: 160)
}
