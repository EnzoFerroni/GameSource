//
//  GameGridView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import SwiftUI

struct GameGridView: View {
    let games: [SteamGame]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(games) { game in
                    GameCardView(game: game)
                }
            }
            .padding()
        }
    }
}

#Preview {
    GameGridView(games: [SteamGame(
        appid: 440,
        name: "TF2",
        playtimeForever: 60,
        playtime2Weeks: nil,
        imgIconUrl: "",
        imgLogoUrl: nil,
        hasCommunityVisibleStats: nil,
        rtimeLastPlayed: nil
    )])
}
