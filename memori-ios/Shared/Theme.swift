import SwiftUI
import UIKit

// Aluminum, walnut, ink. Same tokens as the landing pages.
extension Color {
    static let mBackground = Color(light: 0xF3F2EF, dark: 0x121211)
    static let mSurface = Color(light: 0xFBFAF8, dark: 0x1A1A18)
    static let mInk = Color(light: 0x1B1B19, dark: 0xECEBE7)
    static let mMuted = Color(light: 0x6C6A65, dark: 0x9A978F)
    static let mLine = Color(light: 0xDCD9D2, dark: 0x2E2D2A)
    /// Remaining time: the warm, living color.
    static let mWalnut = Color(light: 0xA07B5F, dark: 0xB08B6A)
    /// Small labels that need contrast against the background.
    static let mWalnutDeep = Color(light: 0x6B4630, dark: 0xC19A78)

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Font {
    static func mNumber(_ size: CGFloat) -> Font { .system(size: size, weight: .regular, design: .serif) }
    static let mTitle = Font.system(size: 26, weight: .medium, design: .serif)
    static let mHeadline = Font.system(size: 17, weight: .medium)
    static let mBody = Font.system(size: 15)
    static let mCaption = Font.system(size: 13)
}

extension View {
    /// Small uppercase label above a section: "MEMENTO MORI", "사람", "돈".
    func eyebrow() -> some View {
        font(.system(size: 11, weight: .medium))
            .tracking(2.4)
            .textCase(.uppercase)
            .foregroundStyle(Color.mWalnutDeep)
    }

    func muted() -> some View {
        font(.mCaption).foregroundStyle(Color.mMuted)
    }

    func card() -> some View {
        padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mSurface)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.mLine, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
