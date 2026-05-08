import FirebaseFirestore
import Foundation

// MARK: - Protocol

protocol FirebaseServiceProtocol {
    func fetchHabits(userId: String) async throws -> [Habit]
    func createHabit(_ habit: Habit) async throws -> String
    func habitLogCompletion(
        habitId: String,
        userId: String,
        location: HabitLocation?
    ) async throws
    func fetchTodayLogs(userId: String) async throws -> [HabitLog]
    func fetchAllLogs(userId: String) async throws -> [HabitLog]
    func deleteHabit(habitId: String, userId: String) async throws
}

// MARK: - Service

actor FirebaseService: FirebaseServiceProtocol {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()

    private enum Collection {
        static let habits = "habits"
        static let habitLogs = "habitLogs"
    }

    private enum Field {
        static let userId = "userId"
        static let habitId = "habitId"
        static let completedAt = "completedAt"
    }

    private init() {}

    // MARK: - CREATE

    func createHabit(_ habit: Habit) async throws -> String {
        let ref = db.collection(Collection.habits).document()
        let data = try await MainActor.run {
            try Firestore.Encoder().encode(habit)
        }
        try await ref.setData(data)
        return ref.documentID
    }

    // MARK: - COMPLETION

    func habitLogCompletion(
        habitId: String,
        userId: String,
        location: HabitLocation?
    ) async throws {
        let log = HabitLog(
            id: UUID().uuidString,
            habitId: habitId,
            userId: userId,
            completedAt: Date(),
            location: location
        )
        let ref = db.collection(Collection.habitLogs).document()
        let data = try await MainActor.run {
            try Firestore.Encoder().encode(log)
        }
        try await ref.setData(data)
    }

    // MARK: - FETCH

    func fetchHabits(userId: String) async throws -> [Habit] {
        let snapshot =
            try await db
            .collection(Collection.habits)
            .whereField(Field.userId, isEqualTo: userId)
            .getDocuments()
        return try await MainActor.run {
            try snapshot.documents.compactMap {
                try $0.data(as: Habit.self)
            }
        }
    }

    func fetchTodayLogs(userId: String) async throws -> [HabitLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        guard
            let endOfDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: startOfDay
            )
        else {
            throw FirebaseServiceError.invalidDate
        }

        let snapshot =
            try await db
            .collection(Collection.habitLogs)
            .whereField(Field.userId, isEqualTo: userId)
            .whereField(Field.completedAt, isGreaterThanOrEqualTo: startOfDay)
            .whereField(Field.completedAt, isLessThan: endOfDay)
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
            .collection(Collection.habitLogs)
            .whereField(Field.userId, isEqualTo: userId)
            .order(by: Field.completedAt, descending: true)
            .getDocuments()

        return try await MainActor.run {
            try snapshot.documents.compactMap {
                try $0.data(as: HabitLog.self)
            }
        }
    }

    // MARK: - DELETE

    func deleteHabit(habitId: String, userId: String) async throws {
        let batch = db.batch()
        let habitRef = db.collection(Collection.habits).document(habitId)
        batch.deleteDocument(habitRef)

        let logsSnapshot =
            try await db
            .collection(Collection.habitLogs)
            .whereField(Field.habitId, isEqualTo: habitId)
            .whereField(Field.userId, isEqualTo: userId)
            .getDocuments()

        for doc in logsSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }

        try await batch.commit()
    }
}
