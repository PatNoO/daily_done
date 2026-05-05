import Combine
import Foundation

struct DayStat: Identifiable {
    let id: Date
    let count: Int
}

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var weeklyStats: [DayStat] = []
    @Published var monthlyStats: [DayStat] = []
    @Published var habitStats: [Habit] = []
    @Published var isLoading = false
    @Published var error: StatsError?

    private let service: FirebaseServiceProtocol

    init(service: FirebaseServiceProtocol? = nil) {
        self.service = service ?? FirebaseService.shared
    }

    func loadStats(for habitId: String? = nil) async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let fetchedHabits = service.fetchHabits(
                userId: "preview-user"
            )
            async let fetchedLogs = service.fetchAllLogs(userId: "preview-user")

            let (habits, logs) = try await (fetchedHabits, fetchedLogs)

            let filtered =
                habitId.map { id in
                    logs.filter { $0.habitId == id }
                } ?? logs
            weeklyStats = completionsPerDay(logs: filtered, days: 7)
            monthlyStats = completionsPerDay(logs: filtered, days: 30)

            habitStats = habits.map { habit in
                let habitLogs = logs.filter { $0.habitId == habit.id }
                var updated = habit
                updated.currentStreak = StreakCalculator.currentStreak(
                    from: habitLogs
                )
                updated.longestStreak = StreakCalculator.longestStreak(
                    from: habitLogs
                )
                updated.totalCompletions = habitLogs.count
                return updated
            }
        } catch {
            self.error = .loadFailed(error)
            print(
                "StatsViewModel loadStats failed: \(error.localizedDescription)"
            )
        }
    }

    private func completionsPerDay(logs: [HabitLog], days: Int) -> [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<days).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let count = logs.filter {
                calendar.startOfDay(for: $0.completedAt) == date
            }.count
            return DayStat(id: date, count: count)
        }.reversed()
    }
}

extension StatsViewModel {
    enum StatsError: LocalizedError {
        case loadFailed(Error)

        var errorDescription: String? {
            switch self {
            case .loadFailed:
                return "Could not load statistics. Please try again."
            }
        }
    }
}
