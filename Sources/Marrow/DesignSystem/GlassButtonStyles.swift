import SwiftUI

struct GlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Palette.textPrimary)
            .frame(width: 34, height: 34)
            .glassEffect(.regular.interactive(), in: .circle)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct GlassCapsuleButtonStyle: ButtonStyle {
    var tinted: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(tinted ? Palette.background : Palette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .glassEffect(tinted ? .regular.tint(Palette.accent).interactive() : .regular.interactive(), in: .capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
