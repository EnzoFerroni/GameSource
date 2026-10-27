//
//  SteamService.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Possible errors when making a request to the Steam Web API.
enum SteamServiceError: Error {
    case invalidURL
    case requestFailed
}

// What the view model needs from a game service.
// Lets tests replace the real service with a fake one.
protocol GameFetching {
    func fetchOwnedGames(steamID: String) async throws -> [SteamGame]
    func fetchAchievements(steamID: String, appId: Int) async throws -> [SteamAchievement]
    func fetchAchievementSchemas(appId: Int) async throws -> [AchievementSchema]
    func fetchUserProfile(steamID: String) async throws -> SteamUserProfile?
}

// Handles all communication with the Steam Web API.
struct SteamService: GameFetching {

    private let apiKey = Secrets.steamAPIKey
    private let baseURL = "https://api.steampowered.com"

    // Fetches every game the user owns, most played first.
    func fetchOwnedGames(steamID: String) async throws -> [SteamGame] {
        let path = "/IPlayerService/GetOwnedGames/v0001/"

        guard var components = URLComponents(string: baseURL + path) else {
            throw SteamServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "steamid", value: steamID),
            // Without this flag Steam returns only appids, no names.
            URLQueryItem(name: "include_appinfo", value: "1"),
            URLQueryItem(name: "include_played_free_games", value: "1"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components.url else {
            throw SteamServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SteamServiceError.requestFailed
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let decoded = try decoder.decode(SteamGamesResponse.self, from: data)

        // Steam sends no games list when the profile is private.
        // Treat that as an empty library.
        let games = decoded.response.games ?? []

        return games.sorted { $0.playtimeForever > $1.playtimeForever }
    }

    // Fetches the user's achievements for one game.
    // The "l" parameter makes Steam include readable names and
    // descriptions, so no second request for the game schema is needed.
    func fetchAchievements(steamID: String, appId: Int) async throws -> [SteamAchievement] {
        let path = "/ISteamUserStats/GetPlayerAchievements/v0001/"

        guard var components = URLComponents(string: baseURL + path) else {
            throw SteamServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "steamid", value: steamID),
            URLQueryItem(name: "appid", value: String(appId)),
            URLQueryItem(name: "l", value: "english")
        ]

        guard let url = components.url else {
            throw SteamServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SteamServiceError.requestFailed
        }

        // Steam answers 400 when the game has no achievements.
        // For us that is not an error, just an empty list.
        guard httpResponse.statusCode != 400 else {
            return []
        }

        guard httpResponse.statusCode == 200 else {
            throw SteamServiceError.requestFailed
        }

        let decoded = try JSONDecoder().decode(
            SteamAchievementsResponse.self, from: data
        )

        return decoded.playerstats.achievements ?? []
    }

    // Fetches the achievement icons for one game. Unlike the call
    // above, this data is per game, not per user.
    func fetchAchievementSchemas(appId: Int) async throws -> [AchievementSchema] {
        let path = "/ISteamUserStats/GetSchemaForGame/v2/"

        guard var components = URLComponents(string: baseURL + path) else {
            throw SteamServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "appid", value: String(appId))
        ]

        guard let url = components.url else {
            throw SteamServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SteamServiceError.requestFailed
        }

        let decoded = try JSONDecoder().decode(
            AchievementSchemaResponse.self, from: data
        )

        return decoded.game?.availableGameStats?.achievements ?? []
    }

    // Fetches the logged user's public profile (name and avatar).
    func fetchUserProfile(steamID: String) async throws -> SteamUserProfile? {
        let path = "/ISteamUser/GetPlayerSummaries/v0002/"

        guard var components = URLComponents(string: baseURL + path) else {
            throw SteamServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "steamids", value: steamID)
        ]

        guard let url = components.url else {
            throw SteamServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SteamServiceError.requestFailed
        }

        let decoded = try JSONDecoder().decode(
            SteamUserProfileResponse.self, from: data
        )

        return decoded.response.players.first
    }
}
