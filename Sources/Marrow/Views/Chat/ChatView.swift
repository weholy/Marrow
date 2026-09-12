import SwiftUI
import SwiftData

struct ChatView: View {
    @Binding var isSidebarPresented: Bool
    @Binding var currentChat: Chat?
    @Environment(\.modelContext) private var context
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            if let chat = currentChat {
                messageList(for: chat)
            } else {
                Spacer()
                welcome
                Spacer()
                chips
            }
            composer
        }
        .background(Palette.background.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button {
                isSidebarPresented = true
            } label: {
                Image(systemName: "line.3.horizontal")
            }
            .buttonStyle(GlassIconButtonStyle())

            Spacer()

            VStack(spacing: 3) {
                Text(currentChat?.title ?? "Marrow")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(1)
                Text("Kimi K2")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 2.5)
                    .background(Palette.accentSoft, in: .rect(cornerRadius: 8))
            }

            Spacer()

            Button {
                currentChat = nil
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .buttonStyle(GlassIconButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
    }

    private var welcome: some View {
        VStack(spacing: 10) {
            Text("Что решаем?")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Palette.textPrimary)
            Text("Текст, файлы, картинки — что угодно.")
                .font(.system(size: 14))
                .foregroundStyle(Palette.textSecondary)
        }
    }

    private var chips: some View {
        HStack(spacing: 8) {
            chip("Разбери файл")
            chip("Нарисуй картинку")
            chip("Найди в сети")
        }
        .padding(.bottom, 16)
    }

    private func chip(_ text: String) -> some View {
        Button {
            draft = text
        } label: {
            Text(text)
                .font(.system(size: 12.5))
                .foregroundStyle(Palette.textPrimary)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
        }
    }

    private func messageList(for chat: Chat) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(chat.messages.sorted(by: { $0.createdAt < $1.createdAt })) { message in
                    MessageBubble(message: message)
                }
            }
            .padding(16)
        }
    }

    private var composer: some View {
        HStack(spacing: 8) {
            Button {
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(GlassIconButtonStyle())

            TextField("Спросите что угодно", text: $draft)
                .foregroundStyle(Palette.textPrimary)
                .tint(Palette.accent)

            Button {
                send()
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundStyle(Palette.background)
            }
            .frame(width: 32, height: 32)
            .background(Palette.textPrimary, in: .circle)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let chat: Chat
        if let existing = currentChat {
            chat = existing
        } else {
            chat = Chat(title: String(text.prefix(40)))
            context.insert(chat)
            currentChat = chat
        }

        let message = Message(role: .user, text: text)
        message.chat = chat
        chat.messages.append(message)
        chat.updatedAt = .now
        draft = ""
    }
}
