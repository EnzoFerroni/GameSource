import Foundation
import UserNotifications

class GameRecommendationService {
    static let shared = GameRecommendationService()
    
    private init() {}
    
    func getUnplayedGame(from games: [SteamGame]) -> SteamGame? {
        let unplayedGames = games.filter { $0.playtimeForever == 0 }
        return unplayedGames.randomElement()
    }
    
    func scheduleRandomGameNotification(games: [SteamGame], at time: Date) {
        guard let randomGame = getUnplayedGame(from: games) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "GameSource Recommendation"
        content.body = "Try playing \(randomGame.name) today!"
        content.sound = .default
        content.userInfo = ["gameId": randomGame.appid]
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "randomGameRecommendation",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}