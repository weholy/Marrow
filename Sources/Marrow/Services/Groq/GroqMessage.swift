import Foundation

struct GroqMessage: Codable, Sendable {
    let role: String
    let content: String
}
