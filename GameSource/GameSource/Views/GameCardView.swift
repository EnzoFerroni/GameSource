//
//  GameCardView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import SwiftUI

struct GameCardView: View {
    let game: SteamGame
    
    var body: some View {
        VStack {
            SteamImageView(appid: game.appid)
                .aspectRatio(2/3, contentMode: .fit)
                .frame(maxWidth: 160)
                .cornerRadius(8)
            
            Text(game.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(height: 260)
    }
}

#Preview {
    GameCardView(
        game: SteamGame(
            appid: 440,
            name: "Sample Game",
            playtimeForever: 60,
            playtime2Weeks: nil,
            imgIconUrl: "",
            imgLogoUrl: nil,
            hasCommunityVisibleStats: nil,
            rtimeLastPlayed: nil
        )
    )
}
