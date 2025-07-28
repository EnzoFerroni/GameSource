//
//  SteamService.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import Foundation

class SteamService {
    private let baseUrl = "https://api.steampowered.com"
    private let apiKey = APIConfiguration.shared.steamAPIKey
    
    func fetchUserGames(steamId: String) async -> [SteamGame] {
        let urlString = "\(baseUrl)/IPlayerService/GetOwnedGames/v0001/?key=\(apiKey)&steamid=\(steamId)&format=json&include_appinfo=1&include_played_free_games=1"
        
        guard let url = URL(string: urlString) else {
            return []
        }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(SteamGamesResponse.self, from: data) else {
            return []
        }
        
        return response.response.games.sorted { $0.playtimeForever > $1.playtimeForever }
    }
    
    func fetchUserProfile(steamId: String) async -> SteamUserProfile? {
        let urlString = "\(baseUrl)/ISteamUser/GetPlayerSummaries/v0002/?key=\(apiKey)&steamids=\(steamId)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(SteamUserProfileResponse.self, from: data),
              let profile = response.response.players.first else {
            return nil
        }
        
        return profile
    }
}
