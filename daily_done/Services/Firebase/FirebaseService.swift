import FirebaseFirestore
import Foundation

protocol FirebaseServiceProtocol {
    func fetchHabits(userId: String) async throws -> [Habit]
    func createHabit(_ habit: Habit) async throws

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
}
