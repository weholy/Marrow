import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Chat.folder)
    var chats: [Chat]

    init(name: String, sortOrder: Int = 0) {
        self.name = name
        self.createdAt = .now
        self.sortOrder = sortOrder
        self.chats = []
    }
}
