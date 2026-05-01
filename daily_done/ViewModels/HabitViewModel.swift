import Combine
import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var error: HabitError?

    private let service: FirebaseServiceProtocol

    init(service: FirebaseServiceProtocol? = nil) {
        self.service = service ?? FirebaseService.shared
    }

    func loadHabits() async {
            isLoading = true
            defer { isLoading = false }
            do {
                // TODO: Byt till Auth.auth().currentuser....  - senare tillfälle
                habits = try await service.fetchHabits(userId: "preview-user")
            } catch let fetchError {
                error = .loadFailed(fetchError)
                print("HabitViewModel loadHabits: \(fetchError.localizedDescription)")
            }
        }
    
    func createHabit (
        name: String,
        category: HabitCategory,
        colorHex: String,
        iconName: String
    )async throws {
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
