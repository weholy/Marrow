import Foundation
import SwiftData

@Model
final class Message {
    var role: MessageRole
    var text: String
    var createdAt: Date
    var reasoningText: String?
    var reasoningSeconds: Int?
    var sourceTitles: [String] = []
    var sourceURLs: [String] = []
    var chat: Chat?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.message)
    var attachments: [Attachment]

    init(role: MessageRole, text: String) {
        self.role = role
        self.text = text
        self.createdAt = .now
        self.attachments = []
    }
}
