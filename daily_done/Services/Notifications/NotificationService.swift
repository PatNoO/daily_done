import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

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

    func scheduleReminder(for habit: Habit) {
        guard habit.isReminderEnabled,
            let reminderTime = habit.reminderTime,
            let habitId = habit.id
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "Daily Done"
        content.body = "Time for your habit: \(habit.name)"
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
    }

    func cancelReminder(habitId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [habitId])
    }
}
