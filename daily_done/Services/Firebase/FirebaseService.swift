import FirebaseFirestore
import Foundation

protocol FirebaseServiceProtocol {
    func fetchHabits(userId: String) async throws -> [Habit]
    func createHabit(_ habit: Habit) async throws
    func habitLogComplition(habitId: String, userId: String) async throws
    func fetchTodayLogs(userId: String) async throws -> [HabitLog]
    func fetchAllLogs(userId: String) async throws -> [HabitLog]
    func deleteHabit(habitId: String, userId: String) async throws
}

actor FirebaseService: FirebaseServiceProtocol {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()

    private init() {}

    func fetchHabits(userId: String) async throws -> [Habit] {
        let snapshot =
            try await db
            .collection("habits")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        return try await MainActor.run {
            try snapshot.documents.compactMap {
                try $0.data(as: Habit.self)
            }
        }
    }

    func createHabit(_ habit: Habit) async throws {
        let ref = db.collection("habits").document()
        let data = try await MainActor.run {
            try Firestore.Encoder().encode(habit)
        }
        try await ref.setData(data)
    }

    func habitLogComplition(habitId: String, userId: String) async throws {

        let log = HabitLog(
            id: UUID().uuidString,
            habitId: habitId,
            userId: userId,
            completedAt: Date(),
            location: nil
        )
        let ref = db.collection("habitLogs").document()
        let data = try await MainActor.run {
            try Firestore.Encoder().encode(log)
        }
        try await ref.setData(data)
    }

    func fetchTodayLogs(userId: String) async throws -> [HabitLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        let snapshot =
            try await db
            .collection("habitLogs")
            .whereField("userId", isEqualTo: userId)
            .whereField("completedAt", isGreaterThanOrEqualTo: startOfDay)
            .whereField("completedAt", isLessThan: endOfDay)  // undersök varning innan push
            .getDocuments()

        return try await MainActor.run {
            try snapshot.documents.compactMap {
                try $0.data(as: HabitLog.self)
            }
        }

    }

    func fetchAllLogs(userId: String) async throws -> [HabitLog] {
        let snapshot =
            try await db
            .collection("habitLogs")
            .whereField("userId", isEqualTo: userId)
            .order(by: "completedAt", descending: true)
            .getDocuments()

        return try await MainActor.run {
            try snapshot.documents.compactMap {
                try $0.data(as: HabitLog.self)
            }
        }
    }

    func deleteHabit(habitId: String, userId: String) async throws {

        let batch = db.batch()
        let habitRef = db.collection("habits").document(habitId)
        batch.deleteDocument(habitRef)

        let logsSnapshot =
            try await db
            .collection("habitLogs")
            .whereField("habitId", isEqualTo: habitId)
            .getDocuments()

        for doc in logsSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }

        try await batch.commit()
    }

}
