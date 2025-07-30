import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    let games: [SteamGame]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime = Date()
    @State private var isNotificationEnabled = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection
                
                timePickerSection
                
                toggleSection
                
                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNotificationSettings()
                    }
                }
            }
        }
        .alert("Notification", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadCurrentSettings()
            requestNotificationPermissionOnAppear()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Game Recommendations")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Get daily recommendations for unplayed games")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notification Time")
                .font(.headline)
            
            DatePicker(
                "Select Time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
        }
    }
    
    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enable Notifications")
                .font(.headline)
            
            Toggle("Daily game recommendations", isOn: $isNotificationEnabled)
                .toggleStyle(.switch)
        }
    }
    
    private func loadCurrentSettings() {
        let defaults = UserDefaults.standard
        isNotificationEnabled = defaults.bool(forKey: "notificationsEnabled")
        
        if let savedTime = defaults.object(forKey: "notificationTime") as? Date {
            selectedTime = savedTime
        }
    }
    
    private func requestNotificationPermissionOnAppear() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    alertMessage = "Notification permission is required for game recommendations"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveNotificationSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isNotificationEnabled, forKey: "notificationsEnabled")
        defaults.set(selectedTime, forKey: "notificationTime")
        
        if isNotificationEnabled {
            scheduleRandomGameNotification()
            alertMessage = "Notifications enabled successfully"
        } else {
            cancelScheduledNotifications()
            alertMessage = "Notifications disabled successfully"
        }
        
        showingAlert = true
    }
    
    private func scheduleRandomGameNotification() {
        let unplayedGames = games.filter { $0.playtimeForever == 0 }
        guard let randomGame = unplayedGames.randomElement() else {
            alertMessage = "No unplayed games found for recommendations"
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "GameSource Recommendation"
        content.body = "Try playing \(randomGame.name) today!"
        content.sound = .default
        content.userInfo = ["gameAppId": randomGame.appid]
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "gameRecommendation", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["gameRecommendation"])
    }
}

#Preview {
    NotificationSettingsView(games: [])
}
