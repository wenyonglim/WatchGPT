import SwiftUI

/// OLED-optimized color palette for WatchGPT
/// Pure black background saves battery, high contrast for readability
enum Theme {
    // MARK: - Core Colors

    /// Pure black - OLED battery saver
    static let background = Color.black

    /// User message bubble - subtle dark gray
    static let userBubble = Color(hex: 0x1C1C1E)

    /// Primary accent - vibrant green for actions
    static let accent = Color(hex: 0x30D158)

    /// Primary text - pure white for maximum contrast
    static let primaryText = Color.white

    /// Secondary text - muted gray
    static let secondaryText = Color(hex: 0x8E8E93)

    /// Error state
    static let error = Color(hex: 0xFF453A)

    // MARK: - Semantic Colors

    static let sendButton = accent
    static let speakerIcon = secondaryText
    static let speakerIconActive = accent
    static let typingIndicator = secondaryText

    // MARK: - Typography

    /// SF Pro Rounded - optimized for Watch readability
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let body = rounded(15)
    static let bodyMedium = rounded(15, weight: .medium)
    static let caption = rounded(13)
    static let title = rounded(17, weight: .semibold)

    // MARK: - Spacing

    static let messagePadding: CGFloat = 10
    static let bubblePadding: CGFloat = 12
    static let bubbleCornerRadius: CGFloat = 16
    static let screenPadding: CGFloat = 8

    // MARK: - Animation

    static let messageAppear: Animation = .spring(response: 0.35, dampingFraction: 0.7)
    static let typingPulse: Animation = .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
