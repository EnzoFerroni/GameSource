//
//  SteamAPIServiceFixed.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import Foundation
import Combine

class SteamAPIService: ObservableObject {
    private let baseURL = "https://api.steampowered.com"
    private let storeBaseURL = "https://store.steampowered.com/api"
    
    // MARK: - Fetch popular games list
    func fetchPopularGames() async throws -> [SteamApp] {
        let urlString = "\(baseURL)/ISteamApps/GetAppList/v2/"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(SteamAppListResponse.self, from: data)
            
            // Filter only games and return first 50 for MVP
            let gameApps = response.applist.apps
                .filter { !$0.name.isEmpty && $0.name.count > 2 }
                .prefix(50)
            
            return Array(gameApps)
        } catch let error as DecodingError {
            throw APIError.decodingError
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Fetch game details
    func fetchGameDetails(appId: Int32) async throws -> SteamGameDetails? {
        let urlString = "\(storeBaseURL)/appdetails?appids=\(appId)&cc=US&l=en"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Steam API returns a dictionary with appId as key
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let appData = json[String(appId)] as? [String: Any],
                  let success = appData["success"] as? Bool,
                  success,
                  let gameData = appData["data"] as? [String: Any] else {
                return nil
            }
            
            let gameDataJson = try JSONSerialization.data(withJSONObject: gameData)
            let gameDetails = try JSONDecoder().decode(SteamGameDetails.self, from: gameDataJson)
            
            return gameDetails
        } catch {
            print("Error fetching details for app \(appId): \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch featured games (alternative approach for MVP)
    func fetchFeaturedGames() async throws -> [SteamApp] {
        // Return some popular game IDs for MVP demonstration
        let popularGameIds: [Int32] = [
            730,     // Counter-Strike: Global Offensive
            570,     // Dota 2
            440,     // Team Fortress 2
            271590,  // Grand Theft Auto V
            292030,  // The Witcher 3
            431960,  // Wallpaper Engine
            1086940, // Baldur's Gate 3
            1174180, // Red Dead Redemption 2
            814380,  // Sekiro
            489830   // The Elder Scrolls V: Skyrim Special Edition
        ]
        
        var games: [SteamApp] = []
        
        for appId in popularGameIds {
            do {
                if let details = try await fetchGameDetails(appId: appId) {
                    let steamApp = SteamApp(appid: details.steamAppid, name: details.name)
                    games.append(steamApp)
                }
            } catch {
                // Continue with next game if one fails
                print("Failed to fetch details for game \(appId): \(error)")
                continue
            }
            
            // Add small delay to avoid overwhelming the API
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        return games
    }
}

// MARK: - API Error Enum
enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
