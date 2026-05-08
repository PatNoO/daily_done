import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: String
    var email: String?
    var displayName: String?
}
