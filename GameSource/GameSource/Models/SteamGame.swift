//
//  SteamGame.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import Foundation

struct SteamGamesResponse: Codable {
    let response: GamesList
}

struct GamesList: Codable {
    let gameCount: Int
    let games: [SteamGame]
    
    enum CodingKeys: String, CodingKey {
        case gameCount = "game_count"
        case games
    }
}

struct SteamGame: Codable, Identifiable {
    let appid: Int
    let name: String
    let playtimeForever: Int
    let playtime2Weeks: Int?
    let imgIconUrl: String
    let imgLogoUrl: String?
    let hasCommunityVisibleStats: Bool?
    let rtimeLastPlayed: Int?
    
    enum CodingKeys: String, CodingKey {
        case appid
        case name
        case playtimeForever = "playtime_forever"
        case playtime2Weeks = "playtime_2weeks"
        case imgIconUrl = "img_icon_url"
        case imgLogoUrl = "img_logo_url"
        case hasCommunityVisibleStats = "has_community_visible_stats"
        case rtimeLastPlayed = "rtime_last_played"
    }
    
    var id: Int {
        appid
    }
    
    var imageUrl: String {
        return "https://shared.steamstatic.com/store_item_assets/steam/apps/\(appid)/library_600x900.jpg"
    }
}
