import SwiftUI

struct MessageBubble: View {
    let role: MessageRole
    let text: String

    private var isUser: Bool { role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(text)
                .foregroundStyle(Palette.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Palette.surfaceElevated : Palette.surface, in: .rect(cornerRadius: 18))
            if !isUser { Spacer(minLength: 40) }
        }
    }
}
