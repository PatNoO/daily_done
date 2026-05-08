import Foundation
import CoreLocation


struct HabitLogAnnotation: Identifiable {
    let id: String
    let habitId: String
    let habitName: String
    let completedAt: Date
    let coordinate: CLLocationCoordinate2D
}
