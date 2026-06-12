//
//  NotificationSettingsView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 12/06/26.
//

import SwiftUI

// Sheet to enable a daily notification suggesting an unplayed game.
struct NotificationSettingsView: View {

    // Games the suggestion is picked from.
    let games: [SteamGame]

    // Settings persist so the sheet reopens in the saved state.
    @AppStorage("suggestionEnabled") private var isEnabled = false
    @AppStorage("suggestionTime") private var savedTime = defaultTime

    @State private var showingPermissionAlert = false

    @Environment(\.dismiss) private var dismiss

    private let service = NotificationService()

    // 19:00 today, as seconds since 1970. @AppStorage cannot store
    // a Date directly, so the time is saved as a number.
    private static var defaultTime: Double {
        Calendar.current.date(
            bySettingHour: 19, minute: 0, second: 0, of: .now
        )?.timeIntervalSince1970 ?? 0
    }

    // Bridges the stored number to the Date the picker needs.
    private var selectedTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: savedTime) },
            set: { savedTime = $0.timeIntervalSince1970 }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Daily game suggestion", isOn: $isEnabled)

                    if isEnabled {
                        DatePicker(
                            "Time",
                            selection: selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } footer: {
                    Text("Once a day, GameSource suggests a game from your library you have not played yet.")
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await save()
                        }
                    }
                }
            }
            .alert("Permission needed", isPresented: $showingPermissionAlert) {
                Button("OK") { }
            } message: {
                Text("Enable notifications for GameSource in Settings.")
            }
        }
    }

    private func save() async {
        guard isEnabled else {
            service.cancelDailySuggestion()
            dismiss()
            return
        }

        guard await service.requestPermission() else {
            isEnabled = false
            showingPermissionAlert = true
            return
        }

        // Suggests an unplayed game; falls back to any game when
        // everything has been played already.
        let unplayed = games.filter { $0.playtimeForever == 0 }

        guard let game = (unplayed.isEmpty ? games : unplayed).randomElement() else {
            dismiss()
            return
        }

        service.scheduleDailySuggestion(
            game: game,
            at: Date(timeIntervalSince1970: savedTime)
        )

        dismiss()
    }
}

#Preview {
    NotificationSettingsView(games: [])
}
