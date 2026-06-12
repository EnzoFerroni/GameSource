//
//  SteamGame.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Mirrors the JSON returned by Steam's GetOwnedGames endpoint:
// { "response": { "games": [...] } }
struct SteamGamesResponse: Decodable {
    let response: GameList
}

struct GameList: Decodable {
    // Steam omits this field entirely when the profile is private,
    // so it must be optional for decoding to succeed.
    let games: [SteamGame]?
}

// A single game in the user's library.
struct SteamGame: Decodable, Identifiable, Hashable {
    let appid: Int
    let name: String
    let playtimeForever: Int

    var id: Int {
        appid
    }

    // Vertical cover art shown in the library list.
    var coverURL: URL? {
        URL(string: "https://shared.steamstatic.com/store_item_assets/steam/apps/\(appid)/library_600x900.jpg")
    }

    // Wide banner image shown on the detail screen.
    var headerURL: URL? {
        URL(string: "https://shared.steamstatic.com/store_item_assets/steam/apps/\(appid)/header.jpg")
    }

    // Steam returns playtime in minutes; show hours when it reads better.
    var formattedPlaytime: String {
        guard playtimeForever >= 60 else {
            return "\(playtimeForever) min"
        }
        return String(format: "%.1f h", Double(playtimeForever) / 60)
    }
}
