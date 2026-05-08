import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func scheduleReminder(for habit: Habit) async
    func cancelReminder(habitId: String)
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    private init() {}

    private static var motivationalPhrases: [String] {
        [
            String(localized: "notification.phrase.keep_streak"),
            String(localized: "notification.phrase.small_steps"),
            String(localized: "notification.phrase.you_got_this"),
            String(localized: "notification.phrase.consistency"),
            String(localized: "notification.phrase.build_great"),
        ]
    }

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print(
                "Notification permission error: \(error.localizedDescription)"
            )
            return false
        }
    }

    func scheduleReminder(for habit: Habit) async {
        guard habit.isReminderEnabled,
            let reminderTime = habit.reminderTime,
            let habitId = habit.id
        else { return }

        let content = UNMutableNotificationContent()
        content.title = habit.name
        content.body = Self.motivationalPhrases.randomElement() ?? String(localized: "notification.phrase.fallback")
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: reminderTime
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: habitId,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        }catch {
            print("Failed to schedule notification for \(habit.name): \(error.localizedDescription)")

        }
    }

    func cancelReminder(habitId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [habitId])
    }
}
