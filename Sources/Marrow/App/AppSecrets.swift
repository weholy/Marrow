import Foundation

enum AppSecrets {
    static var groqKey: String? {
        value(forKey: "GroqAPIKey")
    }

    static var tavilyKey: String? {
        value(forKey: "TavilyAPIKey")
    }

    private static func value(forKey key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            return nil
        }
        return value
    }
}
