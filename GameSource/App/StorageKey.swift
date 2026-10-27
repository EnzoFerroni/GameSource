//
//  StorageKey.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation

// Keys for values persisted in UserDefaults / @AppStorage.
// Centralized so a typo cannot split one value into two keys.
enum StorageKey {
    static let steamID = "steamID"
    static let suggestionEnabled = "suggestionEnabled"
    static let suggestionTime = "suggestionTime"
}
