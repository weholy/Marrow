import SwiftUI

struct MessageBubble: View {
    let role: MessageRole
    let text: String
    var reasoningText: String? = nil
    var reasoningSeconds: Int? = nil
    var isStreamingReasoning: Bool = false

    private var isUser: Bool { role == .user }

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
            if let reasoningText, !reasoningText.isEmpty {
                ThinkingBlockView(reasoningText: reasoningText, seconds: reasoningSeconds, isStreaming: isStreamingReasoning)
            }

            HStack {
                if isUser { Spacer(minLength: 40) }
                if isUser {
                    Text(text)
                        .foregroundStyle(Palette.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Palette.surfaceElevated, in: .rect(cornerRadius: 18))
                } else {
                    FormattedMessageView(text: text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Palette.surface, in: .rect(cornerRadius: 18))
                }
                if !isUser { Spacer(minLength: 40) }
            }
        }
    }
}
