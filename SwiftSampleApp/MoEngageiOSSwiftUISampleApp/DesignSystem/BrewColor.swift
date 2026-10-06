//
//  BrewColor.swift
//  MoEngageiOSSwiftUISampleApp
//

import SwiftUI

enum BrewColor {

    // MARK: - Brand

    /// Primary actions, active tabs, selected states and progress indicators.
    static let primary = Color(hex: 0x06A6B7)

    /// Dark brand surface used by the splash and other full-bleed brand areas.
    static let primaryDarkSurface = Color(hex: 0x06333A)

    /// Pale brand tint used behind banners and confirmation headers.
    static let primaryLightTint = Color(hex: 0xDFF4F5)

    /// Fill of a selected option. Paler than `primaryLightTint`, so a selected
    /// control reads as chosen without competing with the brand areas.
    static let primarySelectedTint = Color(hex: 0xEEFAFB)

    // MARK: - Surfaces

    /// The screen background.
    static let pageBackground = Color(hex: 0xF8F6F3)

    /// Cards, sheets, navigation bars and form backgrounds.
    static let surface = Color(hex: 0xFFFFFF)

    /// Warm fill behind an inset strip on a white surface.
    static let neutralFill = Color(hex: 0xF1EFEC)

    /// Grey fill of an unfocused control — the search field, the bell button.
    static let componentFill = Color(hex: 0xE5E5E5)

    // MARK: - Text

    /// Headings and values.
    static let textPrimary = Color(hex: 0x1E1E1E)

    /// Supporting copy.
    static let textSecondary = Color(hex: 0x485771)

    /// Timestamps, hints and least-prominent copy.
    static let textTertiary = Color(hex: 0x8492AB)

    /// Inline text actions — "Change", "Full menu", "Reorder".
    static let link = primary

    // MARK: - Status

    /// The unread count on the notification bell.
    static let unreadBadge = Color(hex: 0xD3453F)

    /// A saving on a bill — a discount line, a reduction.
    static let successText = Color(hex: 0x1F7A4D)

    /// Behind a status pill, under `successText`.
    static let successTint = Color(hex: 0xE3F6E8)

    /// Behind a warm accent icon — a star, a reward.
    static let warmTint = Color(hex: 0xFFF3DD)

    /// That icon itself.
    static let warmIcon = Color(hex: 0xA86A12)

    /// The simulated notification shade — cooler than `surface`, so it reads
    /// as system chrome laid over the app rather than as part of it.
    static let notificationSurface = Color(hex: 0xEEF4F6)

    // MARK: - Borders

    /// Card borders and dividers.
    static let borderSubtle = Color(hex: 0xECEFF6)

    /// Inputs and outlined controls.
    static let borderDefault = Color(hex: 0xD9DFED)

    // MARK: - Content on dark surfaces

    /// Headings and primary content.
    static let onDarkPrimary = Color.white

    /// Supporting copy.
    static let onDarkSecondary = Color.white.opacity(0.78)

    /// Footnotes and least-prominent copy.
    static let onDarkFootnote = Color.white.opacity(0.55)
}

// MARK: - Hex convenience

private extension Color {

    /// Creates a colour from a 24-bit RGB value.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
