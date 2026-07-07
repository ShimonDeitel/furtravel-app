import SwiftUI

/// Bespoke palette for Furtravel: warm/earthy tones distinct to this app's domain.
enum Theme {
    static let background = Color(red: 0x0D.0/255, green: 0x15.0/255, blue: 0x1A.0/255)
    static let primary = Color(red: 0x2E.0/255, green: 0x6E.0/255, blue: 0x8C.0/255)
    static let accent = Color(red: 0xE8.0/255, green: 0xA8.0/255, blue: 0x3D.0/255)
    static let card = Color.white
    static let textPrimary = Color.black.opacity(0.85)
    static let textSecondary = Color.black.opacity(0.55)

    static func titleFont(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }

    static func bodyFont(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
}
