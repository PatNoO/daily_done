import Combine
import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var error: HabitError?
    @Published var completedHabitIds: Set<String> = []

    private let service: FirebaseServiceProtocol

    init(service: FirebaseServiceProtocol? = nil) {
        self.service = service ?? FirebaseService.shared
    }

    func loadHabits() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let fetchedHabits = service.fetchHabits(
                userId: "preview-user"
            )
            async let fetchedLogs = service.fetchTodayLogs(
                userId: "preview-user"
            )
            let (loadedHabits, todayLogs) = try await (
                fetchedHabits, fetchedLogs
            )
            habits = loadedHabits
            completedHabitIds = Set(todayLogs.compactMap { $0.habitId })
        } catch let fetchError {
            error = .loadFailed(fetchError)
            print(
                "HabitViewModel loadHabits: \(fetchError.localizedDescription)"
            )
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
            userId: "preview-user",  // Todo: updateras Auth () id senare
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
}

extension HabitViewModel {
    enum HabitError: LocalizedError {
        case loadFailed(Error)
        case nameMissing
        case saveFailed(Error)

        var errorDescription: String? {
            switch self {
            case .loadFailed:
                return "Could not load habits. Please try again."
            case .nameMissing:
                return "Please enter a name for the habit."
            case .saveFailed:
                return "Could not save habit. Please try again."
            }
        }
    }
}
