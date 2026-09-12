import Foundation
import SwiftData

@Model
final class Attachment {
    var filename: String
    var utTypeIdentifier: String?
    var data: Data
    var message: Message?

    init(filename: String, utTypeIdentifier: String?, data: Data) {
        self.filename = filename
        self.utTypeIdentifier = utTypeIdentifier
        self.data = data
    }
}
