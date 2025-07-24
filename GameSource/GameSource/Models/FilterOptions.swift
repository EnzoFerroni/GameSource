import Foundation

enum SortOption: String, CaseIterable {
    case name = "Name"
    case playtime = "Playtime"
    
    var displayName: String {
        return self.rawValue
    }
}

enum GroupOption: String, CaseIterable {
    case none = "None"
    case playtime = "By Playtime"
    case firstLetter = "Alphabetical"
    
    var displayName: String {
        return self.rawValue
    }
}

enum FilterOption: String, CaseIterable {
    case all = "All Games"
    case played = "Played Games"
    case unplayed = "Unplayed Games"
    
    var displayName: String {
        return self.rawValue
    }
}
