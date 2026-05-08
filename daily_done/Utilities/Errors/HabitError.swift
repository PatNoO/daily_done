import Foundation

enum HabitError: LocalizedError {
    case loadFailed(Error)
    case nameMissing
    case saveFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Could not load habits. Please try again."
        case .nameMissing:
            return "Please enter a name for the habit."
        case .saveFailed:
            return "Could not save habit. Please try again."
        case .deleteFailed:
            return "Could not delete habit. Please try again."
        }
    }
}
