import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct ChatView: View {
    @Binding var isSidebarPresented: Bool
    @Binding var currentChat: Chat?
    @Environment(\.modelContext) private var context
    @State private var draft = ""
    @State private var isStreaming = false
    @State private var streamingReply = ""
    @State private var streamingReasoning = ""
    @State private var pendingAttachments: [Attachment] = []
    @State private var isShowingPhotosPicker = false
    @State private var isShowingFileImporter = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

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
            if !pendingAttachments.isEmpty {
                pendingAttachmentsRow
            }
            composer
        }
        .background(AmbientBackground().ignoresSafeArea())
        .photosPicker(isPresented: $isShowingPhotosPicker, selection: $selectedPhotoItems, matching: .any(of: [.images, .videos]))
        .onChange(of: selectedPhotoItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        let typeID = item.supportedContentTypes.first?.identifier
                        let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "bin"
                        pendingAttachments.append(Attachment(filename: "Вложение.\(ext)", utTypeIdentifier: typeID, data: data))
                    }
                }
                selectedPhotoItems = []
            }
        }
        .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            guard case .success(let urls) = result else { return }
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    pendingAttachments.append(Attachment(filename: url.lastPathComponent, utTypeIdentifier: nil, data: data))
                }
            }
        }
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
                    .foregroundStyle(Palette.textSecondary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 2.5)
                    .background(Palette.surfaceElevated, in: .rect(cornerRadius: 8))
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
        VStack(spacing: 12) {
            Text("Что решаем?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Palette.textPrimary)
            Text("Текст, файлы, картинки — что угодно.")
                .font(.system(size: 15))
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
                    MessageBubble(
                        role: message.role,
                        text: message.text,
                        attachments: message.attachments,
                        reasoningText: message.reasoningText,
                        reasoningSeconds: message.reasoningSeconds
                    )
                }
                if isStreaming {
                    MessageBubble(
                        role: .assistant,
                        text: streamingReply.isEmpty ? "…" : streamingReply,
                        reasoningText: streamingReasoning.isEmpty ? nil : streamingReasoning,
                        reasoningSeconds: nil,
                        isStreamingReasoning: streamingReply.isEmpty
                    )
                }
            }
            .padding(16)
        }
    }

    private var pendingAttachmentsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(pendingAttachments.enumerated()), id: \.offset) { index, attachment in
                    HStack(spacing: 6) {
                        Image(systemName: "doc")
                            .font(.system(size: 11))
                        Text(attachment.filename)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Button {
                            pendingAttachments.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 13))
                        }
                    }
                    .foregroundStyle(Palette.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .glassEffect(.regular, in: .capsule)
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 8)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            Menu {
                Button {
                    isShowingFileImporter = true
                } label: {
                    Label("Прикрепить файл", systemImage: "folder")
                }
                Button {
                    isShowingPhotosPicker = true
                } label: {
                    Label("Прикрепить фото или видео", systemImage: "photo")
                }
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(GlassIconButtonStyle())

            HStack(spacing: 8) {
                TextField("Спросите что угодно", text: $draft)
                    .foregroundStyle(Palette.textPrimary)
                    .tint(Palette.textPrimary)
                    .disabled(isStreaming)

                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up")
                        .foregroundStyle(Palette.background)
                }
                .frame(width: 32, height: 32)
                .background(Palette.textPrimary, in: .circle)
                .opacity((draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pendingAttachments.isEmpty) || isStreaming ? 0.4 : 1)
                .disabled(isStreaming)
            }
            .padding(.leading, 16)
            .padding(.trailing, 6)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: .capsule)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !pendingAttachments.isEmpty, !isStreaming else { return }

        let chat: Chat
        if let existing = currentChat {
            chat = existing
        } else {
            chat = Chat(title: text.isEmpty ? "Вложение" : String(text.prefix(40)))
            context.insert(chat)
            currentChat = chat
        }

        let userMessage = Message(role: .user, text: text)
        userMessage.chat = chat
        for attachment in pendingAttachments {
            attachment.message = userMessage
            userMessage.attachments.append(attachment)
            context.insert(attachment)
        }
        pendingAttachments = []
        chat.messages.append(userMessage)
        chat.updatedAt = .now
        draft = ""

        Task { await requestReply(for: chat) }
    }

    private func requestReply(for chat: Chat) async {
        isStreaming = true
        streamingReply = ""
        streamingReasoning = ""

        let history = chat.messages
            .sorted(by: { $0.createdAt < $1.createdAt })
            .map { GroqMessage(role: $0.role.rawValue, content: $0.text) }

        let client = GroqStreamingClient(apiKey: AppSecrets.groqKey)
        let startedAt = Date()
        var reasoningSeconds: Int?

        do {
            for try await token in client.stream(model: chat.modelID, messages: history) {
                switch token {
                case .reasoning(let piece):
                    streamingReasoning += piece
                case .content(let piece):
                    if reasoningSeconds == nil && !streamingReasoning.isEmpty {
                        reasoningSeconds = Int(Date().timeIntervalSince(startedAt).rounded())
                    }
                    streamingReply += piece
                }
            }
            let reply = Message(role: .assistant, text: streamingReply)
            reply.reasoningText = streamingReasoning.isEmpty ? nil : streamingReasoning
            reply.reasoningSeconds = reasoningSeconds
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
        streamingReasoning = ""
    }
}
