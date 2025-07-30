import Foundation

enum SortOption: String, CaseIterable {
    case name = "Name"
    case playtime = "Playtime"
}

enum FilterOption: String, CaseIterable {
    case all = "All Games"
    case played = "Played Games"
    case unplayed = "Unplayed Games"
}
