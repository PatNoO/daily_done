import Foundation
import Combine

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: FirebaseServiceProtocol

    init(service: FirebaseServiceProtocol = FirebaseService.shared) {
        self.service = service
    }

    func fetchHabits() async {
        isLoading = true
        errorMessage = nil

        do {
            habits = try await service.fetchHabits(userId: "preview-user")
        } catch {
            errorMessage = "Could not load habits. Please try again."
            print(
                "HabitListViewModel fetchHabits error: \(error.localizedDescription)"
            )
        }
        isLoading = false
    }
}
