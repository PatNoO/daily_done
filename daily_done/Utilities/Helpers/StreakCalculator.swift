import Foundation

enum StreakCalculator {

    static func currentStreak(from logs: [HabitLog]) -> Int {
        let days = completedDays(from: logs)
        guard !days.isEmpty else { return 0 }

        var streak = 0

        var expectedDay = Calendar.current.startOfDay(for: Date())

        for day in days {
            if day == expectedDay {
                streak += 1
                expectedDay = Calendar.current.date(byAdding: .day, value: -1, to: expectedDay)!
            } else {
                break
            }
        }
        return streak
    }

    static func longestStreak(from logs: [HabitLog]) -> Int {
        let days = completedDays(from: logs)
        guard days.count > 0 else { return 0 }

        var longest = 1
        var currentRun = 1

        for i in 1..<days.count {
            let daysBetween = Calendar.current.dateComponents(
                [.day], from: days[i], to: days[i - 1]
            ).day ?? 0

            if daysBetween == 1 {
                currentRun += 1
                longest = max(longest, currentRun)
            } else {
                currentRun = 1
            }
        }
        return longest
    }


    private static func completedDays(from logs: [HabitLog]) -> [Date] {
        let calendar = Calendar.current
        let uniqueDays = Set(logs.map { calendar.startOfDay(for: $0.completedAt) })
        return uniqueDays.sorted(by: >)
    }
}
