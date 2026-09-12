import Foundation

enum MemoryExtractor {
    static func extract(from text: String, apiKey: String?) async -> String? {
        guard let apiKey, !apiKey.isEmpty else { return nil }

        let prompt = """
        Пользователь попросил запомнить факт о себе. Извлеки из сообщения только конкретный факт (кто он, что любит, чем занимается и т.п.), коротко, одним предложением, от третьего лица. Если факта нет — ответь ровно NONE.

        Сообщение: \(text)
        """

        let client = GroqStreamingClient(apiKey: apiKey)
        var result = ""
        do {
            for try await token in client.stream(model: "openai/gpt-oss-120b", messages: [GroqMessage(role: "user", content: prompt)]) {
                if case .content(let piece) = token { result += piece }
            }
        } catch {
            return nil
        }

        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.isEmpty || trimmed == "NONE") ? nil : trimmed
    }
}
