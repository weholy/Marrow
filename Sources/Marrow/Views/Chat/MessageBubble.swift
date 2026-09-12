import SwiftUI

struct MessageBubble: View {
    let role: MessageRole
    let text: String
    var attachments: [Attachment] = []
    var sourceTitles: [String] = []
    var sourceURLs: [String] = []
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

            if !sourceURLs.isEmpty {
                sourcesRow
            }
        }
    }

    private var sourcesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(sourceURLs.enumerated()), id: \.offset) { index, url in
                    Text(sourceTitles.indices.contains(index) ? sourceTitles[index] : url)
                        .font(.system(size: 11.5))
                        .lineLimit(1)
                        .foregroundStyle(Palette.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Palette.surfaceElevated, in: .capsule)
                }
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
