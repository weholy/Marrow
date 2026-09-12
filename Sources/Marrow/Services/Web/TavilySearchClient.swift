import Foundation

struct WebSearchResult {
    let title: String
    let url: String
    let snippet: String
    var fullText: String?
}

struct TavilySearchClient {
    var apiKey: String?

    func search(query: String, maxResults: Int = 4) async throws -> [WebSearchResult] {
        guard let apiKey, !apiKey.isEmpty else { throw GroqError.missingKey }

        var request = URLRequest(url: URL(string: "https://api.tavily.com/search")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "api_key": apiKey,
            "query": query,
            "max_results": maxResults
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw GroqError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return []
        }

        return results.compactMap { item in
            guard let title = item["title"] as? String,
                  let url = item["url"] as? String,
                  let content = item["content"] as? String else { return nil }
            return WebSearchResult(title: title, url: url, snippet: content)
        }
    }

    func extractFullText(urls: [String]) async -> [String: String] {
        guard let apiKey, !apiKey.isEmpty, !urls.isEmpty else { return [:] }

        var request = URLRequest(url: URL(string: "https://api.tavily.com/extract")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["api_key": apiKey, "urls": urls])

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return [:]
        }

        var mapped: [String: String] = [:]
        for item in results {
            if let url = item["url"] as? String, let content = item["raw_content"] as? String {
                mapped[url] = content
            }
        }
        return mapped
    }
}
