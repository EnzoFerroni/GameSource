//
//  SteamGameModel.swift
//  GameSource
//
//  Created by Enzo Ferroni on 21/07/25.
//

import Foundation

// MARK: - Steam API Response Models
struct SteamAppListResponse: Codable {
    let applist: AppList
}

struct AppList: Codable {
    let apps: [SteamApp]
}

struct SteamApp: Codable {
    let appid: Int32
    let name: String
}

// MARK: - Steam App Details Response
struct SteamAppDetailsResponse: Codable {
    let success: Bool
    let data: SteamGameDetails?
}

struct SteamGameDetails: Codable {
    let type: String
    let name: String
    let steamAppid: Int32
    let shortDescription: String?
    let headerImage: String?
    let priceOverview: PriceOverview?
    let releaseDate: ReleaseDate?
    let developers: [String]?
    let publishers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case type, name
        case steamAppid = "steam_appid"
        case shortDescription = "short_description"
        case headerImage = "header_image"
        case priceOverview = "price_overview"
        case releaseDate = "release_date"
        case developers, publishers
    }
}

struct PriceOverview: Codable {
    let currency: String
    let initial: Int
    let final: Int
    let discountPercent: Int
    let initialFormatted: String?
    let finalFormatted: String?
    
    enum CodingKeys: String, CodingKey {
        case currency, initial, final
        case discountPercent = "discount_percent"
        case initialFormatted = "initial_formatted"
        case finalFormatted = "final_formatted"
    }
}

struct ReleaseDate: Codable {
    let comingSoon: Bool
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case comingSoon = "coming_soon"
        case date
    }
}