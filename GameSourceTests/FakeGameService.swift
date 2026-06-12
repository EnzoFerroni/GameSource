//
//  FakeGameService.swift
//  GameSourceTests
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation
@testable import GameSource

// A fake service so tests run without touching the network.
// Each test fills it with the exact data it wants the view model to see.
struct FakeGameService: GameFetching {

    var games: [SteamGame] = []
    var achievements: [SteamAchievement] = []
    var schemas: [AchievementSchema] = []

    // When true, every call fails like a network error would.
    var shouldFail = false

    func fetchOwnedGames(steamID: String) async throws -> [SteamGame] {
        guard !shouldFail else {
            throw SteamServiceError.requestFailed
        }
        return games
    }

    func fetchAchievements(steamID: String, appId: Int) async throws -> [SteamAchievement] {
        guard !shouldFail else {
            throw SteamServiceError.requestFailed
        }
        return achievements
    }

    func fetchAchievementSchemas(appId: Int) async throws -> [AchievementSchema] {
        guard !shouldFail else {
            throw SteamServiceError.requestFailed
        }
        return schemas
    }

    func fetchUserProfile(steamID: String) async throws -> SteamUserProfile? {
        guard !shouldFail else {
            throw SteamServiceError.requestFailed
        }
        return nil
    }
}
