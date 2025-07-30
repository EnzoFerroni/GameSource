import Foundation

struct APIConfiguration {
    static let shared = APIConfiguration()
    
    private init() {}
    
    var steamAPIKey: String {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["STEAM_API_KEY"] as? String else {
            return ""
        }
        return key
    }
}
