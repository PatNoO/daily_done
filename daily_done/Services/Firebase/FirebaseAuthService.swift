import FirebaseAuth
import Foundation

protocol FirebaseAuthServiceProtocol {
    var authStatePublisher: AsyncStream<User?> { get }
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func createUser(email: String, password: String, displayName: String)
        async throws
    func sendPasswordReset(email: String) async throws
}

actor FirebaseAuthService: FirebaseAuthServiceProtocol {

    nonisolated var authStatePublisher: AsyncStream<User?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener {
                _,
                firebaseUser in
                let user = firebaseUser.map {
                    User(
                        id: $0.uid,
                        email: $0.email,
                        displayName: $0.displayName
                    )
                }
                continuation.yield(user)
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    func createUser(email: String, password: String, displayName: String)
        async throws
    {
        let result = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )
        let profileUpdate = result.user.createProfileChangeRequest()
        profileUpdate.displayName = displayName
        try await profileUpdate.commitChanges()

    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    nonisolated func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
