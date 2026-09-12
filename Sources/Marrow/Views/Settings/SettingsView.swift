import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allChats: [Chat]
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Приложение") {
                    NavigationLink("Модели") {
                        Text("Скоро — офлайн-модели и загрузка на устройство.")
                            .foregroundStyle(Palette.textSecondary)
                            .padding()
                    }
                    NavigationLink("Персонализация") {
                        Text("Скоро — инструкции и температура.")
                            .foregroundStyle(Palette.textSecondary)
                            .padding()
                    }
                    NavigationLink("Память") {
                        MemoryView()
                    }
                }
                .listRowBackground(Palette.surface)

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Удалить всю историю чатов")
                    }
                }
                .listRowBackground(Palette.surface)
            }
            .scrollContentBackground(.hidden)
            .background(Palette.background)
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
            .alert("Удалить всю историю?", isPresented: $showDeleteConfirm) {
                Button("Удалить", role: .destructive) {
                    for chat in allChats { context.delete(chat) }
                }
                Button("Отмена", role: .cancel) {}
            }
        }
    }
}
