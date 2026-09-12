import SwiftUI

struct MessageBubble: View {
    let role: MessageRole
    let text: String
    var attachments: [Attachment] = []
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
                VStack(alignment: .leading, spacing: 8) {
                    if !attachments.isEmpty {
                        attachmentRow
                    }
                    if isUser {
                        if !text.isEmpty {
                            Text(text)
                                .foregroundStyle(Palette.textPrimary)
                        }
                    } else {
                        FormattedMessageView(text: text)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Palette.surfaceElevated : Palette.surface, in: .rect(cornerRadius: 18))
                if !isUser { Spacer(minLength: 40) }
            }
        }
    }

    private var attachmentRow: some View {
        ForEach(Array(attachments.enumerated()), id: \.offset) { _, attachment in
            HStack(spacing: 6) {
                Image(systemName: attachment.utTypeIdentifier?.hasPrefix("public.image") == true ? "photo" : "doc")
                    .font(.system(size: 11))
                Text(attachment.filename)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
            .foregroundStyle(Palette.textSecondary)
        }
    }
}
