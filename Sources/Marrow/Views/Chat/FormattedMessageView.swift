import SwiftUI
import MarkdownUI
import LaTeXSwiftUI

struct FormattedMessageView: View {
    let text: String

    private enum Segment {
        case markdown(String)
        case math(String, isBlock: Bool)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(Self.split(text).enumerated()), id: \.offset) { _, segment in
                switch segment {
                case .markdown(let content):
                    if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Markdown(content)
                            .markdownTextStyle { ForegroundColor(Palette.textPrimary) }
                            .markdownCodeSyntaxHighlighter(HighlightrSyntaxHighlighter())
                    }
                case .math(let content, let isBlock):
                    LaTeX(content)
                        .foregroundStyle(Palette.textPrimary)
                        .frame(maxWidth: isBlock ? .infinity : nil, alignment: .leading)
                }
            }
        }
    }

    private static func split(_ text: String) -> [Segment] {
        var result: [Segment] = []
        var remaining = Substring(text)

        while !remaining.isEmpty {
            if let blockRange = remaining.range(of: "$$") {
                let before = remaining[remaining.startIndex..<blockRange.lowerBound]
                if !before.isEmpty { result.append(.markdown(String(before))) }
                let afterOpen = remaining[blockRange.upperBound...]
                if let closeRange = afterOpen.range(of: "$$") {
                    result.append(.math(String(afterOpen[afterOpen.startIndex..<closeRange.lowerBound]), isBlock: true))
                    remaining = afterOpen[closeRange.upperBound...]
                } else {
                    result.append(.markdown(String(remaining)))
                    remaining = ""
                }
            } else if let inlineOpen = remaining.firstIndex(of: "$") {
                let before = remaining[remaining.startIndex..<inlineOpen]
                if !before.isEmpty { result.append(.markdown(String(before))) }
                let afterOpen = remaining[remaining.index(after: inlineOpen)...]
                if let closeIndex = afterOpen.firstIndex(of: "$") {
                    result.append(.math(String(afterOpen[afterOpen.startIndex..<closeIndex]), isBlock: false))
                    remaining = afterOpen[afterOpen.index(after: closeIndex)...]
                } else {
                    result.append(.markdown(String(remaining)))
                    remaining = ""
                }
            } else {
                result.append(.markdown(String(remaining)))
                remaining = ""
            }
        }

        return result
    }
}
