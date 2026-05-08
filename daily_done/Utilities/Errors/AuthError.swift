import Foundation

enum AuthError: LocalizedError {
    case signInFailed(Error)
    case signOutFailed(Error)
    case signUpFailed(Error)
    case resetFailed(Error)

    var errorDescription: String? {
        switch self {
        case .signInFailed:
            return "Could not sign in. Check your email and password."
        case .signOutFailed:
            return "Could not sign out. Please try again."
        case .signUpFailed(let error):
            return "Could not create account. \(error.localizedDescription)"
        case .resetFailed:
            return
                "Could not send reset email. Check that the address is correct."
        }
    }
}
