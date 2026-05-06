import Combine
import CoreLocation
import Foundation

struct HabitLogAnnoation: Identifiable {
    let id: String
    let habitId: String
    let habitName: String
    let completedAt: Date
    let coordinate: CLLocationCoordinate2D
}

@MainActor
final class MapViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var allAnnotations: [HabitLogAnnoation]
    @Published var selectedHabitId: String? = nil
    @Published var isloading = false
    @Published var error: String? = nil

    private let userId: String
    private let service: FirebaseServiceProtocol

    init(userId: String, service: FirebaseServiceProtocol? = nil) {
        self.userId = userId
        self.service = service ?? FirebaseService.shared
    }

    var filteredAnnnotations: [HabitLogAnnoation] {
        guard let id = selectedHabitId else { return allAnnotations }
        return allAnnotations.filter { $0.habitId == id }
    }

    func load() async {
        isloading = true
        defer { isloading = false }

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

            allAnnotations = logs.compactMap { log -> HabitLogAnnoation? in
                guard let loc = log.location,
                    let logId = log.id
                else { return nil }
                let name = nameById[log.habitId] ?? "Unknown Habit"
                return HabitLogAnnoation(
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
            print("MapViewModel load failed: \(fetchError.localizedDescription)")

        }
    }
}
