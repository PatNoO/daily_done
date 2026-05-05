import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userId: String?
    @Published var error: AuthError?
    @Published var isLoading: Bool = true

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
                isLoading = false
            }
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
}

extension AuthViewModel {
    enum AuthError: LocalizedError {
        case signInFailed(Error)
        case signOutFailed(Error)

        var errorDescription: String? {
            switch self {
            case .signInFailed:
                return "Could not sign in. Check your email and password."
            case .signOutFailed:
                return "Could not sign out. Please try again."
            }
        }
    }
}
