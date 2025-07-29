import Foundation
import UserNotifications

// MARK: - Local Notification Service

class NotificationService: ObservableObject {
    @Published var isAuthorized = false
    
    // MARK: - Initialization
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func scheduleGameSuggestionNotification(with game: SteamGame) {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Play!"
        content.body = "How about playing \(game.name)? You've played for \(formatPlaytime(minutes: game.playtimeForever))!"
        content.sound = .default
        content.badge = 1
        
        // Add game info to userInfo for potential future use
        content.userInfo = [
            "gameId": game.appid,
            "gameName": game.name,
            "type": "game_suggestion"
        ]
        
        // Schedule for 5 seconds from now (for testing)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "game_suggestion_\(game.appid)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for game: \(game.name)")
            }
        }
    }
    
    func scheduleRandomGameSuggestion(from games: [SteamGame]) {
        guard !games.isEmpty else {
            print("No games available for suggestion")
            return
        }
        
        let randomGame = games.randomElement()!
        scheduleGameSuggestionNotification(with: randomGame)
    }
    
    func scheduleDailyGameSuggestions(from games: [SteamGame]) {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        guard !games.isEmpty else {
            print("No games available for daily suggestions")
            return
        }
        
        // Cancel any existing daily notifications
        cancelDailyNotifications()
        
        // Pick a random game for the notification
        let randomGame = games.randomElement()!
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Game!"
        content.body = "How about playing \(randomGame.name)? You've played for \(formatPlaytime(minutes: randomGame.playtimeForever))!"
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "gameId": randomGame.appid,
            "gameName": randomGame.name,
            "type": "daily_game_suggestion"
        ]
        
        // Create date components for 6 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_game_suggestion",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            } else {
                print("Daily game suggestions scheduled for 6 PM")
            }
        }
    }
    
    func cancelDailyNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_game_suggestion"])
        print("Daily notifications cancelled")
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All notifications cancelled")
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func formatPlaytime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours == 0 {
            return "\(minutes) minutes"
        } else if remainingMinutes == 0 {
            return "\(hours) hours"
        } else {
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}
