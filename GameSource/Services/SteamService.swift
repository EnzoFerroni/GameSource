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

        // games is nil when the profile is private; treat it as empty.
        let games = decoded.response.games ?? []

        return games.sorted { $0.playtimeForever > $1.playtimeForever }
    }
}
