import SwiftUI
import MarkdownUI
import Highlightr

struct HighlightrSyntaxHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr?

    init() {
        highlightr = Highlightr()
        highlightr?.setTheme(to: "atom-one-dark")
    }

    func highlightCode(_ code: String, language: String?) -> Text {
        guard let highlightr,
              let highlighted = highlightr.highlight(code, as: language) else {
            return Text(code)
        }
        return Text(AttributedString(highlighted))
    }
}
