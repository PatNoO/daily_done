import Foundation

enum FirebaseServiceError: LocalizedError {
    case invalidDate
    case invalidId

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Could not calculate a valid date range. Please try again."
        case .invalidId:
            return "Habit ID is missing. Please reload and try again."
        }
    }
}
