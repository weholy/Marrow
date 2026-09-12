import Foundation

enum GroqError: Error {
    case missingKey
    case badStatus(Int)
}

enum GroqToken {
    case reasoning(String)
    case content(String)
}

struct GroqStreamingClient {
    var apiKey: String?
    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    func stream(model: String, messages: [GroqMessage]) -> AsyncThrowingStream<GroqToken, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    guard let apiKey, !apiKey.isEmpty else {
                        continuation.finish(throwing: GroqError.missingKey)
                        return
                    }

                    var request = URLRequest(url: endpoint)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

                    let payload: [String: Any] = [
                        "model": model,
                        "messages": messages.map { ["role": $0.role, "content": $0.content] },
                        "stream": true
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: payload)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                        continuation.finish(throwing: GroqError.badStatus(status))
                        return
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonText = String(line.dropFirst(6))
                        if jsonText == "[DONE]" { break }
                        guard let data = jsonText.data(using: .utf8),
                              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let choices = json["choices"] as? [[String: Any]],
                              let delta = choices.first?["delta"] as? [String: Any] else { continue }

                        if let reasoning = delta["reasoning"] as? String, !reasoning.isEmpty {
                            continuation.yield(.reasoning(reasoning))
                        }
                        if let content = delta["content"] as? String, !content.isEmpty {
                            continuation.yield(.content(content))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
