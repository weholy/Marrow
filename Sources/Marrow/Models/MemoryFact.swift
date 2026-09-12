import Foundation
import SwiftData

@Model
final class MemoryFact {
    var text: String
    var createdAt: Date

    init(text: String) {
        self.text = text
        self.createdAt = .now
    }
}
