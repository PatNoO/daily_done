import FirebaseFirestore
import Foundation

protocol FirebaseServiceProtocol {
    func fetchHabits() async throws -> [String: Any]
}

actor FirebaseService: FirebaseServiceProtocol {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()

    private init() {}

    func fetchHabits() async throws -> [String: Any] {
        // TODO: Replace with typed Habit model when DD-003 lands
        let snapshot = try await db.collection("habits").getDocuments()
        return Dictionary(uniqueKeysWithValues: snapshot.documents.map {
            ($0.documentID, $0.data())
        })
    }
}
