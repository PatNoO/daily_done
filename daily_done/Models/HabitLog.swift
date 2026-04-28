import Foundation
import FirebaseFirestore

struct HabitLog: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var habitId: String
    var userId: String
    var completedAt: Date
}

extension HabitLog {
    static var preview: HabitLog {
        HabitLog(
            id: "log-preview-id",
            habitId: "preview-id",
            userId: "preview-user",
            completedAt: Date()
        )
    }
}
