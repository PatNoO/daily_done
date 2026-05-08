import Foundation

enum StatsError: LocalizedError {
    case loadFailed(Error)

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Could not load statistics. Please try again."
        }
    }
}
