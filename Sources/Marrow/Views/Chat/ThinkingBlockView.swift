import SwiftUI

struct ThinkingBlockView: View {
    let reasoningText: String
    let seconds: Int?
    let isStreaming: Bool
    @State private var isExpanded = false

    private var headline: String {
        if isStreaming { return "Думаю…" }
        if let seconds { return "Думал \(seconds) с" }
        return "Думал"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .font(.system(size: 11, weight: .semibold))
                    Text(headline)
                        .font(.system(size: 12.5, weight: .medium))
                }
                .foregroundStyle(Palette.textSecondary)
            }

            if isExpanded {
                Text(reasoningText)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Palette.surface, in: .rect(cornerRadius: 14))
    }
}
