import FirebaseFirestore
import Foundation

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case health = "health"
    case fitness = "fitness"
    case learning = "learning"
    case mindfulness = "mindfulness"
    case productivity = "productivity"
    case social = "social"
    case other = "other"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .learning: return "book.fill"
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "checkmark.circle.fill"
        case .social: return "person.2.fill"
        case .other: return "star.fill"
        }
    }

    var colorName: String {
        switch self {
        case .health: return "categoryHealth"
        case .fitness: return "categoryFitness"
        case .learning: return "categoryLearning"
        case .mindfulness: return "categoryMindfulness"
        case .productivity: return "categoryProductivity"
        case .social: return "categorySocial"
        case .other: return "categoryOther"
        }
    }
}

struct Habit: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var category: HabitCategory
    var colorHex: String
    var iconName: String
    var createdAt: Date
    var currentStreak: Int
    var longestStreak: Int
    var totalCompletions: Int
}

extension Habit {
    static var preview: Habit {
        Habit(
            id: "preview-id",
            userId: "preview-user",
            name: "Morning Run",
            category: .fitness,
            colorHex: "#FF6B35",
            iconName: "figure.run",
            createdAt: Date(),
            currentStreak: 5,
            longestStreak: 12,
            totalCompletions: 30
        )
    }
}
