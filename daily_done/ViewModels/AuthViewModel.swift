import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Properties

    @Published var isSignedIn: Bool = false
    @Published var userId: String?
    @Published var email: String?
    @Published var displayName: String?
    @Published var error: AuthError?
    @Published var isLoading: Bool = true
    @Published var resetEmailSent: Bool = false

    private let service: FirebaseAuthServiceProtocol
    private var listenerTask: Task<Void, Never>?

    // MARK: - Init

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

    // MARK: - Actions

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
