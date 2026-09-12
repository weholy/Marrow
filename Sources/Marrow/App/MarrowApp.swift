import SwiftUI
import SwiftData

@main
struct MarrowApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Chat.self, Folder.self, Message.self, Attachment.self, MemoryFact.self)
        } catch {
            fatalError("Не удалось создать хранилище: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
