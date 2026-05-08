import SwiftUI

private struct UserIdKey: EnvironmentKey {
    static let defaultValue: String = ""
}

extension EnvironmentValues {
    var userId: String {
        get { self[UserIdKey.self] }
        set { self[UserIdKey.self] = newValue }
    }
}
