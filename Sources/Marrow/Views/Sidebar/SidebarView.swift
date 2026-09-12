import SwiftUI

struct SidebarView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Marrow")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Button {
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(GlassIconButtonStyle())
            }
            .padding(16)

            Text("Недавние")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Palette.textSecondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

            ScrollView {
                VStack(spacing: 0) {
                }
            }

            Spacer()

            HStack {
                Button {
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(GlassIconButtonStyle())

                Spacer()

                Button {
                } label: {
                    Label("Chat", systemImage: "square.and.pencil")
                }
                .buttonStyle(GlassCapsuleButtonStyle(tinted: true))
            }
            .padding(16)
        }
        .frame(maxHeight: .infinity)
        .background(Palette.surface.ignoresSafeArea())
    }
}
