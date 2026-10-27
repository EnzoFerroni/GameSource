//
//  Secrets.swift
//  GameSource
//
//  Created by Enzo Ferroni on 11/06/26.
//

import Foundation

// Reads build-time secrets injected via Secrets.xcconfig.
// To run the project, fill Secrets.xcconfig with your own values.
enum Secrets {
    static let steamAPIKey: String = value(for: "SteamAPIKey")

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String,
              !value.isEmpty else {
            fatalError("\(key) missing. Fill Secrets.xcconfig with your values.")
        }
        return value
    }
}
