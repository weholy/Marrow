import SwiftUI
import SwiftData

struct ChatView: View {
    @Binding var isSidebarPresented: Bool
    @Binding var currentChat: Chat?
    @Environment(\.modelContext) private var context
    @State private var draft = ""
    @State private var isStreaming = false
    @State private var streamingReply = ""

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
                Text(ModelCatalog.model(for: currentChat?.modelID).displayName)
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
                    MessageBubble(role: message.role, text: message.text)
                }
                if isStreaming {
                    MessageBubble(role: .assistant, text: streamingReply.isEmpty ? "…" : streamingReply)
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
                .disabled(isStreaming)

            Button {
                send()
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundStyle(Palette.background)
            }
            .frame(width: 32, height: 32)
            .background(Palette.textPrimary, in: .circle)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isStreaming ? 0.4 : 1)
            .disabled(isStreaming)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }

        let chat: Chat
        if let existing = currentChat {
            chat = existing
        } else {
            chat = Chat(title: String(text.prefix(40)))
            context.insert(chat)
            currentChat = chat
        }

        let userMessage = Message(role: .user, text: text)
        userMessage.chat = chat
        chat.messages.append(userMessage)
        chat.updatedAt = .now
        draft = ""

        Task { await requestReply(for: chat) }
    }

    private func requestReply(for chat: Chat) async {
        isStreaming = true
        streamingReply = ""

        let history = chat.messages
            .sorted(by: { $0.createdAt < $1.createdAt })
            .map { GroqMessage(role: $0.role.rawValue, content: $0.text) }

        let client = GroqStreamingClient(apiKey: AppSecrets.groqKey)

        do {
            for try await token in client.stream(model: chat.modelID, messages: history) {
                streamingReply += token
            }
            let reply = Message(role: .assistant, text: streamingReply)
            reply.chat = chat
            chat.messages.append(reply)
        } catch GroqError.missingKey {
            let reply = Message(role: .assistant, text: "Нет ключа Groq — добавьте GROQ_API_KEY в секреты репозитория.")
            reply.chat = chat
            chat.messages.append(reply)
        } catch {
            let reply = Message(role: .assistant, text: "Не получилось получить ответ: \(error.localizedDescription)")
            reply.chat = chat
            chat.messages.append(reply)
        }

        chat.updatedAt = .now
        isStreaming = false
        streamingReply = ""
    }
}
