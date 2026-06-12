//
//  SteamAchievement.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation

// Mirrors the JSON returned by Steam's GetPlayerAchievements endpoint:
// { "playerstats": { "achievements": [...] } }
struct SteamAchievementsResponse: Decodable {
    let playerstats: PlayerStats
}

struct PlayerStats: Decodable {
    // Missing when the game has no achievements.
    let achievements: [SteamAchievement]?
}

// A single achievement and whether the user unlocked it.
struct SteamAchievement: Decodable, Identifiable {
    let apiname: String
    let achieved: Int
    let name: String

    // Hidden achievements come without a description.
    let description: String?

    var id: String {
        apiname
    }

    var isUnlocked: Bool {
        achieved == 1
    }
}
