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

    private static let motivationalPhrases = [
        "Keep the streak alive!",
        "Small steps, big results.",
        "You've got this — one habit at a time.",
        "Consistency is the key to success.",
        "Time to build something great today.",
    ]

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
        content.body = Self.motivationalPhrases.randomElement() ?? "Time for your habit!"
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
