//
//  SteamAchievement.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation

// MARK: - GetPlayerAchievements response

// Mirrors the JSON returned by Steam's GetPlayerAchievements endpoint:
// { "playerstats": { "achievements": [...] } }
struct SteamAchievementsResponse: Decodable {
    let playerstats: PlayerStats
}

struct PlayerStats: Decodable {
    // Missing when the game has no achievements.
    let achievements: [SteamAchievement]?
}

// One achievement as the player sees it: unlocked or not, and when.
struct SteamAchievement: Decodable {
    let apiname: String
    let achieved: Int

    // Unix timestamp; 0 when still locked.
    let unlocktime: Int

    let name: String

    // Hidden achievements come without a description.
    let description: String?
}

// MARK: - GetSchemaForGame response

// Mirrors the JSON returned by Steam's GetSchemaForGame endpoint.
// Only the icons are used; names already come localized above.
struct AchievementSchemaResponse: Decodable {
    let game: GameSchema?
}

struct GameSchema: Decodable {
    let availableGameStats: GameStats?
}

struct GameStats: Decodable {
    let achievements: [AchievementSchema]?
}

struct AchievementSchema: Decodable {
    let name: String

    // Steam ships two versions of every icon: colored and gray.
    let icon: String
    let icongray: String
}

// MARK: - Display model

// What the detail screen actually shows: the player's progress
// merged with the schema icon for one achievement.
struct GameAchievement: Identifiable {
    let id: String
    let name: String
    let description: String?
    let isUnlocked: Bool
    let unlockDate: Date?
    let iconURL: URL?
}
