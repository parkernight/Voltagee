import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
    static let vBackground = Color(hex: 0x050810)
    static let vCard = Color(hex: 0x0B1220)
    static let vBorder = Color(hex: 0x1A2A44)
    static let vAccent = Color(hex: 0x00B4D8)
    static let vMuted = Color(hex: 0x8A94A6)
}

extension Font {
    // Bebas Neue: the display font from watchvoltage.com
    static func vTitle(_ size: CGFloat) -> Font {
        .custom("BebasNeue-Regular", size: size)
    }
    // Outfit: the body font from watchvoltage.com
    static func outfit(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("Outfit", size: size).weight(weight)
    }
}
