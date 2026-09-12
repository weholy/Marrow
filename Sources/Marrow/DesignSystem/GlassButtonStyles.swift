import SwiftUI

struct GlassIconButtonStyle: ButtonStyle {
    var isActive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(isActive ? Palette.background : Palette.textPrimary)
            .frame(width: 46, height: 46)
            .glassEffect(isActive ? .regular.tint(Palette.textPrimary).interactive() : .regular.interactive(), in: .circle)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct GlassCapsuleButtonStyle: ButtonStyle {
    var filled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(filled ? Palette.background : Palette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .glassEffect(filled ? .regular.tint(Palette.textPrimary).interactive() : .regular.interactive(), in: .capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
