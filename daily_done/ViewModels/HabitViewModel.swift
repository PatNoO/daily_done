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
    }

    extension HabitViewModel {
        enum HabitError: LocalizedError {
            case loadFailed(Error)

            var errorDescription: String? {
                switch self {
                case .loadFailed:
                    return "Could not load habits. Please try again."
                }
            }
        }
    }
