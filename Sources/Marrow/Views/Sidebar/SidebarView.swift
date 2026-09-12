import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var isPresented: Bool
    @Binding var currentChat: Chat?
    @Environment(\.modelContext) private var context

    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @Query(sort: \Chat.updatedAt, order: .reverse) private var allChats: [Chat]

    @State private var searchText = ""
    @State private var renamingChat: Chat?
    @State private var renameText = ""
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""

    private func chats(in folder: Folder?) -> [Chat] {
        allChats.filter { $0.folder == folder && matchesSearch($0) }
    }

    private func matchesSearch(_ chat: Chat) -> Bool {
        searchText.isEmpty || chat.title.localizedCaseInsensitiveContains(searchText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            searchField
            list
            footer
        }
        .frame(maxHeight: .infinity)
        .background(Palette.surface.ignoresSafeArea())
        .alert("Переименовать чат", isPresented: renameBinding) {
            TextField("Название", text: $renameText)
            Button("Сохранить") { commitRename() }
            Button("Отмена", role: .cancel) {}
        }
        .alert("Новая папка", isPresented: $isCreatingFolder) {
            TextField("Название папки", text: $newFolderName)
            Button("Создать") { commitNewFolder() }
            Button("Отмена", role: .cancel) {}
        }
    }

    private var renameBinding: Binding<Bool> {
        Binding(get: { renamingChat != nil }, set: { if !$0 { renamingChat = nil } })
    }

    private var header: some View {
        HStack {
            Text("Marrow")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Palette.textPrimary)
            Spacer()
            Button {
                newFolderName = ""
                isCreatingFolder = true
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .buttonStyle(GlassIconButtonStyle())
            Button {
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(GlassIconButtonStyle())
        }
        .padding(16)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Palette.textSecondary)
            TextField("Поиск", text: $searchText)
                .foregroundStyle(Palette.textPrimary)
                .tint(Palette.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Palette.surfaceElevated, in: .rect(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private var list: some View {
        List {
            ForEach(folders) { folder in
                let items = chats(in: folder)
                if !items.isEmpty {
                    Section(folder.name) {
                        ForEach(items) { chat in row(for: chat) }
                    }
                }
            }

            let unfiled = chats(in: nil)
            if !unfiled.isEmpty {
                Section(folders.isEmpty ? "Недавние" : "Без папки") {
                    ForEach(unfiled) { chat in row(for: chat) }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .foregroundStyle(Palette.textPrimary)
    }

    private func row(for chat: Chat) -> some View {
        Button {
            currentChat = chat
            isPresented = false
        } label: {
            HStack {
                if chat.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.accent)
                }
                Text(chat.title)
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(1)
            }
        }
        .listRowBackground(Palette.surface)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                context.delete(chat)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .contextMenu {
            Button {
                renameText = chat.title
                renamingChat = chat
            } label: {
                Label("Переименовать", systemImage: "pencil")
            }
            Button {
                chat.isPinned.toggle()
            } label: {
                Label(chat.isPinned ? "Открепить" : "Закрепить", systemImage: "pin")
            }
            Menu("В папку") {
                Button("Без папки") { chat.folder = nil }
                ForEach(folders) { folder in
                    Button(folder.name) { chat.folder = folder }
                }
            }
            Button(role: .destructive) {
                context.delete(chat)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button {
                currentChat = nil
                isPresented = false
            } label: {
                Label("Chat", systemImage: "square.and.pencil")
            }
            .buttonStyle(GlassCapsuleButtonStyle(tinted: true))
        }
        .padding(16)
    }

    private func commitRename() {
        renamingChat?.title = renameText
        renamingChat = nil
    }

    private func commitNewFolder() {
        guard !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let folder = Folder(name: newFolderName, sortOrder: folders.count)
        context.insert(folder)
        newFolderName = ""
    }
}
