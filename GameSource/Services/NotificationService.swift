//
//  NotificationService.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import Foundation
import UserNotifications

// Schedules the daily "try this game" local notification.
struct NotificationService {

    private let identifier = "gameSuggestion"

    // Asks the user for permission. Returns whether it was granted.
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        return (try? await center.requestAuthorization(
            options: [.alert, .sound]
        )) ?? false
    }

    // Schedules a repeating daily notification suggesting one game.
    // Scheduling with the same identifier replaces the previous one.
    func scheduleDailySuggestion(game: SteamGame, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "GameSource"
        content.body = "How about playing \(game.name) today?"
        content.sound = .default

        // Only hour and minute, so the trigger repeats every day.
        let components = Calendar.current.dateComponents(
            [.hour, .minute], from: time
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components, repeats: true
        )

        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelDailySuggestion() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
