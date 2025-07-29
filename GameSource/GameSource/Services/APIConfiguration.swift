import Foundation

struct APIConfiguration {
    // MARK: - Properties
    static let shared = APIConfiguration()
    
    private init() {}
    
    // MARK: - Steam API
    var steamAPIKey: String {
        
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {
            fatalError("APIKeys.plist file not found. Please add APIKeys.plist to your project")
        }
        
        guard let plist = NSDictionary(contentsOfFile: path) else {
            fatalError("Failed to load APIKeys.plist content")
        }
                
        guard let key = plist["STEAM_API_KEY"] as? String, !key.isEmpty else {
            fatalError("STEAM_API_KEY not found or empty in APIKeys.plist")
        }
        
        return key
    }
}
