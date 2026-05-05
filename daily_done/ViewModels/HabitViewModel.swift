import Combine
import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var error: HabitError?
    @Published var completedHabitIds: Set<String> = []

    private let service: FirebaseServiceProtocol
    private let userId: String

    init(userId: String, service: FirebaseServiceProtocol? = nil) {
        self.userId = userId
        self.service = service ?? FirebaseService.shared
    }

    func loadHabits() async {
        isLoading = true
        defer { isLoading = false }

        do {
            habits = try await service.fetchHabits(userId: userId)
        } catch let fetchError {
            error = .loadFailed(fetchError)
            print(
                "HabitViewModel fetchHabits failed: \(fetchError.localizedDescription)"
            )
            return
        }

        do {
            let todayLogs = try await service.fetchTodayLogs(
                userId: userId
            )
            completedHabitIds = Set(todayLogs.compactMap { $0.habitId })
        } catch let logError {
            print(
                "HabitViewModel fetchTodayLogs failed: \(logError.localizedDescription)"
            )
        }

        do {
            let allLogs = try await service.fetchAllLogs(userId: userId)
            refreshStreaks(from: allLogs)
        } catch let streakError {
            print(
                "HabitViewModel fetchAllLogs failed: \(streakError.localizedDescription)"
            )
        }
    }

    private func refreshStreaks(from logs: [HabitLog]) {
        habits = habits.map { habit in
            let habitLogs = logs.filter { $0.habitId == habit.id }
            var updated = habit
            updated.currentStreak = StreakCalculator.currentStreak(
                from: habitLogs
            )
            updated.longestStreak = StreakCalculator.longestStreak(
                from: habitLogs
            )
            return updated
        }
    }

    func createHabit(
        name: String,
        category: HabitCategory,
        colorHex: String,
        iconName: String
    ) async throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw HabitError.nameMissing

        }

        let habit = Habit(
            userId: userId,
            name: trimmedName,
            category: category,
            colorHex: colorHex,
            iconName: iconName,
            createdAt: Date(),
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0

        )
        try await service.createHabit(habit)
        habits.append(habit)
    }

    func toggleCompletion(for habit: Habit) async {
        guard let habitId = habit.id else { return }
        guard !completedHabitIds.contains(habitId) else { return }
        completedHabitIds.insert(habitId)

        do {
            try await service.habitLogComplition(
                habitId: habitId,
                userId: habit.userId
            )
        } catch let saveError {
            completedHabitIds.remove(habitId)
            error = .saveFailed(saveError)
            print(
                "HabitViewModel toggleCompletion: \(saveError.localizedDescription)"
            )
        }
    }

    func deleteHabit(_ habit: Habit) async {
        guard let habitId = habit.id else { return }

        habits.removeAll { $0.id == habitId }

        do {
            try await service.deleteHabit(
                habitId: habitId,
                userId: habit.userId
            )
        } catch let deleteError {
            habits.append(habit)
            error = .deleteFailed(deleteError)
            print(
                "HabitViewModel deleteHabit: \(deleteError.localizedDescription)"
            )

        }
    }
}

extension HabitViewModel {
    enum HabitError: LocalizedError {
        case loadFailed(Error)
        case nameMissing
        case saveFailed(Error)
        case deleteFailed(Error)

        var errorDescription: String? {
            switch self {
            case .loadFailed:
                return "Could not load habits. Please try again."
            case .nameMissing:
                return "Please enter a name for the habit."
            case .saveFailed:
                return "Could not save habit. Please try again."
            case .deleteFailed:
                return "Could not delete habit. Please try again."
            }
        }
    }
}
