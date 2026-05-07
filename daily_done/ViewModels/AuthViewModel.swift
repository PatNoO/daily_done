import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userId: String?
    @Published var email: String?
    @Published var displayName: String?
    @Published var error: AuthError?
    @Published var isLoading: Bool = true
    @Published var resetEmailSent: Bool = false

    private let service: FirebaseAuthServiceProtocol
    private var listenerTask: Task<Void, Never>?

    init(service: (any FirebaseAuthServiceProtocol)? = nil) {
        self.service = service ?? FirebaseAuthService()
        startListening()
    }

    deinit {
        listenerTask?.cancel()
    }

    private func startListening() {
        listenerTask = Task { [weak self] in
            guard let self else { return }
            for await user in service.authStatePublisher {
                isSignedIn = user != nil
                userId = user?.id
                email = user?.email
                displayName = user?.displayName
                isLoading = false
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.createUser(
                email: email,
                password: password,
                displayName: displayName
            )
        } catch {
            self.error = .signUpFailed(error)
        }
    }

    func signIn(email: String, password: String) async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.signIn(email: email, password: password)
        } catch {
            self.error = .signInFailed(error)
            print("AuthViewModel signIn failed: \(error.localizedDescription)")
        }
    }

    func signOut() {
        error = nil
        do {
            try service.signOut()
        } catch {
            self.error = .signOutFailed(error)
            print("AuthViewModel signOut failed: \(error.localizedDescription)")
        }
    }

    func sendPasswordReset(email: String) async {
        error = nil
        resetEmailSent = false
        do {
            try await service.sendPasswordReset(email: email)
            resetEmailSent = true
        } catch {
            self.error = .resetFailed(error)
        }
    }
}

extension AuthViewModel {
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
                return "Could not send reset email. Check that the address is correct."
            }
        }
    }
}
