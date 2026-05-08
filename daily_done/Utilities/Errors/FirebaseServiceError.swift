import Foundation

enum FirebaseServiceError: LocalizedError {
    case invalidDate

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Could not calculate a valid date range. Please try again."
        }
    }
}
