import Combine
import Foundation

@MainActor
final class HabitViewModel: ObservableObject {

    // MARK: - Properties

    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var error: HabitError?
    @Published var completedHabitIds: Set<String> = []

    private var userId: String = ""
    private let service: FirebaseServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let locationService: LocationServiceProtocol

    // MARK: - Init

    init(
        userId: String = "" ,
        service: FirebaseServiceProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        locationService: LocationServiceProtocol? = nil
    ) {
        self.userId = userId
        self.service = service ?? FirebaseService.shared
        self.notificationService = notificationService ?? NotificationService.shared
        self.locationService = locationService ?? LocationService.shared
    }

    // MARK: - Load

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

    // MARK: - Actions

    func createHabit(
        name: String,
        category: HabitCategory,
        colorHex: String,
        iconName: String,
        isReminderEnabled: Bool,
        reminderTime: Date?
    ) async throws -> Habit {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw HabitError.nameMissing

        }

        var habit = Habit(
            userId: userId,
            name: trimmedName,
            category: category,
            colorHex: colorHex,
            iconName: iconName,
            createdAt: Date(),
            currentStreak: 0,
            longestStreak: 0,
            totalCompletions: 0,
            isReminderEnabled: isReminderEnabled,
            reminderTime: reminderTime

        )
        let docId = try await service.createHabit(habit)
        habit.id = docId
        habits.append(habit)
        return habit
    }

    func toggleCompletion(for habit: Habit) async {
        guard let habitId = habit.id else { return }
        guard !completedHabitIds.contains(habitId) else { return }
        completedHabitIds.insert(habitId)
        
        let location = await locationService.currentLocation()

        do {
            try await service.habitLogCompletion(
                habitId: habitId,
                userId: habit.userId,
                location: location
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

        if habit.isReminderEnabled {
            notificationService.cancelReminder(habitId: habitId)
        }

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
    
    func configure(userId: String) {
        self.userId = userId
    }
}

