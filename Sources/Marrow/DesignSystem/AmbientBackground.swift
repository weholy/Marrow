import SwiftUI

struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Palette.background
            RadialGradient(
                colors: [Color.white.opacity(0.10), Color.white.opacity(0.03), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
        }
    }
}
