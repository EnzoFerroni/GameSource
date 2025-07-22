//
//  GameRowView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import SwiftUI

struct GameRowView: View {
    let game: Game
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
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
                    )
            }
            .frame(width: 80, height: 45)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Game Info
            VStack(alignment: .leading, spacing: 4) {
                Text(game.name ?? "Unknown Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let shortDescription = game.shortDescription {
                    Text(shortDescription)
                        .font(.caption)
                        .foregroundColor(.mediumGray)
                        .lineLimit(2)
                }
                
                if let price = game.price {
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.accentGreen)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onFavoriteToggle) {
                Image(systemName: game.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(game.isFavorite ? .red : .mediumGray)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleGame = Game(context: context)
    sampleGame.appId = 1091500
    sampleGame.name = "Cyberpunk 2077"
    sampleGame.shortDescription = "RPG, Action"
    sampleGame.headerImage = "https://cdn.akamai.steamstatic.com/steam/apps/1091500/header.jpg"
    sampleGame.price = "$59.99"
    
    return GameRowView(game: sampleGame) {
        // Toggle action
    }
    .background(Color.primaryBackground)
}
