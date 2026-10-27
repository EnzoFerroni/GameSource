//
//  FilterOptions.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation

// How the library can be sorted. Raw values are the menu labels.
enum SortOption: String, CaseIterable {
    case playtime = "Playtime"
    case name = "Name"
}

// Which games the library shows. Raw values are the menu labels.
enum FilterOption: String, CaseIterable {
    case all = "All Games"
    case played = "Played"
    case unplayed = "Unplayed"
}
