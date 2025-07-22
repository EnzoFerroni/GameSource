//
//  GameCardView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import SwiftUI

struct GameCardView: View {
    let game: Game
    @Binding var selectedGame: Game?
    
    var body: some View {
        VStack(spacing: 8) {
            // Game Image
            AsyncImage(url: URL(string: game.headerImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.secondaryBackground)
                    .overlay(
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.mediumGray)
                            .font(.title2)
                    )
            }
            .frame(width: 160, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Game Title
            Text(game.name ?? "Unknown Game")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 160, height: 32)
        }
        .onTapGesture {
            selectedGame = game
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleGame = Game(context: context)
    sampleGame.appId = 1091500
    sampleGame.name = "Cyberpunk 2077"
    sampleGame.headerImage = "https://cdn.akamai.steamstatic.com/steam/apps/1091500/header.jpg"
    
    return GameCardView(game: sampleGame, selectedGame: .constant(nil))
        .background(Color.primaryBackground)
}