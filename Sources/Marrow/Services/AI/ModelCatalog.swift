import Foundation

struct AIModel: Identifiable, Hashable {
    let id: String
    let displayName: String
    let isLocal: Bool
}

enum ModelCatalog {
    static let cloud: [AIModel] = [
        AIModel(id: "moonshotai/kimi-k2-thinking", displayName: "Kimi K2", isLocal: false),
        AIModel(id: "openai/gpt-oss-120b", displayName: "gpt-oss 120b", isLocal: false)
    ]

    static let all: [AIModel] = cloud

    static func model(for id: String?) -> AIModel {
        all.first { $0.id == id } ?? cloud[0]
    }
}
