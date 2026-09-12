import SwiftUI

enum Palette {
    static let background = Color(hex: 0x121212)
    static let surface = Color(hex: 0x1C1C1C)
    static let surfaceElevated = Color(hex: 0x262626)
    static let textPrimary = Color(hex: 0xF5F5F5)
    static let textSecondary = Color(hex: 0x999999)
    static let hairline = Color(hex: 0x2C2C2C)
    static let accent = Color(hex: 0xC2453A)

    static var accentSoft: Color { accent.opacity(0.2) }
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
