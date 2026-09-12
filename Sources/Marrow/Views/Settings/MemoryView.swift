import SwiftUI
import SwiftData

struct MemoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \MemoryFact.createdAt, order: .reverse) private var facts: [MemoryFact]

    var body: some View {
        List {
            if facts.isEmpty {
                Text("Пока нечего вспомнить.")
                    .foregroundStyle(Palette.textSecondary)
                    .listRowBackground(Palette.background)
            }
            ForEach(facts) { fact in
                Text(fact.text)
                    .foregroundStyle(Palette.textPrimary)
                    .listRowBackground(Palette.surface)
                    .swipeActions {
                        Button(role: .destructive) {
                            context.delete(fact)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Palette.background)
        .navigationTitle("Память")
    }
}
