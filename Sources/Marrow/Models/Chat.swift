import Foundation
import SwiftData

@Model
final class Chat {
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var modelID: String
    var folder: Folder?

    @Relationship(deleteRule: .cascade, inverse: \Message.chat)
    var messages: [Message]

    init(title: String, modelID: String = "kimi-k2-thinking") {
        self.title = title
        self.createdAt = .now
        self.updatedAt = .now
        self.isPinned = false
        self.modelID = modelID
        self.messages = []
    }
}
