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
    
    func fetchGameAchievements(steamId: String, appId: Int) async -> [SteamAchievement] {
        // First, get user's achievement progress
        let userAchievements = await fetchUserAchievementProgress(steamId: steamId, appId: appId)
        
        // Then, get achievement schema (names, descriptions, and icons)
        let achievementSchema = await fetchAchievementSchema(appId: appId)
        
        // Merge the data
        return mergeAchievementData(userProgress: userAchievements, schema: achievementSchema)
    }
    
    func calculateAchievementStats(achievements: [SteamAchievement]) -> AchievementStats {
        let totalCount = achievements.count
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        let percentage = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) * 100 : 0.0
        
        return AchievementStats(
            totalAchievements: totalCount,
            unlockedAchievements: unlockedCount,
            completionPercentage: percentage
        )
    }
    
    // MARK: - Private Methods
    
    private func fetchUserAchievementProgress(steamId: String, appId: Int) async -> [SteamAchievement] {
        let urlString = "\(baseUrl)/ISteamUserStats/GetPlayerAchievements/v0001/?appid=\(appId)&key=\(apiKey)&steamid=\(steamId)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for user achievements")
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(SteamAchievementsResponse.self, from: data)
            return response.playerstats.achievements ?? []
        } catch {
            print("Error fetching user achievements: \(error)")
            return []
        }
    }
    
    private func fetchAchievementSchema(appId: Int) async -> [String: (name: String, description: String, iconUrl: String?, iconGrayUrl: String?)] {
        let urlString = "\(baseUrl)/ISteamUserStats/GetSchemaForGame/v2/?key=\(apiKey)&appid=\(appId)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for achievement schema")
            return [:]
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AchievementSchemaResponse.self, from: data)
            
            var schema: [String: (name: String, description: String, iconUrl: String?, iconGrayUrl: String?)] = [:]
            
            if let availableGameStats = response.game?.availableGameStats {
                for achievement in availableGameStats.achievements ?? [] {
                    schema[achievement.name] = (
                        name: achievement.displayName ?? achievement.name,
                        description: achievement.description ?? "Hidden achievement",
                        iconUrl: achievement.icon,
                        iconGrayUrl: achievement.icongray
                    )
                }
            }
            
            return schema
        } catch {
            print("Error fetching achievement schema: \(error)")
            return [:]
        }
    }
    
    private func mergeAchievementData(
        userProgress: [SteamAchievement],
        schema: [String: (name: String, description: String, iconUrl: String?, iconGrayUrl: String?)]
    ) -> [SteamAchievement] {
        return userProgress.map { achievement in
            let schemaData = schema[achievement.apiname]
            
            return SteamAchievement(
                apiname: achievement.apiname,
                achieved: achievement.achieved,
                unlocktime: achievement.unlocktime,
                name: schemaData?.name ?? achievement.apiname.replacingOccurrences(of: "_", with: " ").capitalized,
                description: schemaData?.description ?? "Achievement details not available",
                iconUrl: schemaData?.iconUrl,
                iconGrayUrl: schemaData?.iconGrayUrl
            )
        }
    }
}
