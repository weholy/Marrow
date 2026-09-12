import SwiftUI

struct ChatView: View {
    @Binding var isSidebarPresented: Bool
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            welcome
            Spacer()
            chips
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
                Text("Marrow")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.textPrimary)
                Text("Kimi K2")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 2.5)
                    .background(Palette.accentSoft, in: .rect(cornerRadius: 8))
            }

            Spacer()

            Button {
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
        Text(text)
            .font(.system(size: 12.5))
            .foregroundStyle(Palette.textPrimary)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: .capsule)
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
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundStyle(Palette.background)
            }
            .frame(width: 32, height: 32)
            .background(Palette.textPrimary, in: .circle)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }
}
