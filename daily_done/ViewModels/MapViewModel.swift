import Combine
import CoreLocation
import Foundation


@MainActor
final class MapViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var annotations: [HabitLogAnnotation] = []
    @Published var selectedHabitId: String? = nil
    @Published var isLoading = false
    @Published var error: String? = nil

    private var userId: String = ""
    private let service: FirebaseServiceProtocol

    init(userId: String = "", service: FirebaseServiceProtocol? = nil) {
        self.userId = userId
        self.service = service ?? FirebaseService.shared
    }

    var filteredAnnotations: [HabitLogAnnotation] {
        guard let id = selectedHabitId else { return annotations }
        return annotations.filter { $0.habitId == id }
    }

    func loadNearbyHabits() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let fetchedHabits = try service.fetchHabits(userId: userId)
            async let fetchedLogs = try service.fetchAllLogs(userId: userId)

            let (loadedHabits, logs) = try await (fetchedHabits, fetchedLogs)
            habits = loadedHabits

            let nameById = Dictionary(
                uniqueKeysWithValues: loadedHabits.compactMap {
                    habit -> (String, String)? in
                    guard let id = habit.id else { return nil }
                    return (id, habit.name)
                }
            )

            annotations = logs.compactMap { log -> HabitLogAnnotation? in
                guard let loc = log.location,
                    let logId = log.id
                else { return nil }
                let name = nameById[log.habitId] ?? String(localized: "map.unknown_habit")
                return HabitLogAnnotation(
                    id: logId,
                    habitId: log.habitId,
                    habitName: name,
                    completedAt: log.completedAt,
                    coordinate: CLLocationCoordinate2D(
                        latitude: loc.lat,
                        longitude: loc.lng
                    )
                )
            }

        } catch let fetchError {
            error = "Could not load map data. Please try again."
            print("MapViewModel loadNearbyHabits failed: \(fetchError.localizedDescription)")
        }
    }
    
    func configure(userId: String) {
        self.userId = userId
    }
}
