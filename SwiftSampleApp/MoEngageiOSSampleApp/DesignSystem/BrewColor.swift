//
//  BrewColor.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/DesignSystem/BrewColor.swift.
//  Same names/semantics, `UIColor` instead of `Color`.
//

import UIKit

enum BrewColor {

    // MARK: - Brand

    /// Primary actions, active tabs, selected states and progress indicators.
    static let primary = UIColor(hex: 0x06A6B7)

    /// Dark brand surface used by the splash and other full-bleed brand areas.
    static let primaryDarkSurface = UIColor(hex: 0x06333A)

    /// Pale brand tint used behind banners and confirmation headers.
    static let primaryLightTint = UIColor(hex: 0xDFF4F5)

    /// Fill of a selected option. Paler than `primaryLightTint`, so a selected
    /// control reads as chosen without competing with the brand areas.
    static let primarySelectedTint = UIColor(hex: 0xEEFAFB)

    // MARK: - Surfaces

    /// The screen background.
    static let pageBackground = UIColor(hex: 0xF8F6F3)

    /// Cards, sheets, navigation bars and form backgrounds.
    static let surface = UIColor(hex: 0xFFFFFF)

    /// Warm fill behind an inset strip on a white surface.
    static let neutralFill = UIColor(hex: 0xF1EFEC)

    /// Grey fill of an unfocused control — the search field, the bell button.
    static let componentFill = UIColor(hex: 0xE5E5E5)

    // MARK: - Text

    /// Headings and values.
    static let textPrimary = UIColor(hex: 0x1E1E1E)

    /// Supporting copy.
    static let textSecondary = UIColor(hex: 0x485771)

    /// Timestamps, hints and least-prominent copy.
    static let textTertiary = UIColor(hex: 0x8492AB)

    /// Inline text actions — "Change", "Full menu", "Reorder".
    static let link = primary

    // MARK: - Status

    /// The unread count on the notification bell.
    static let unreadBadge = UIColor(hex: 0xD3453F)

    /// A saving on a bill — a discount line, a reduction.
    static let successText = UIColor(hex: 0x1F7A4D)

    /// Behind a status pill, under `successText`.
    static let successTint = UIColor(hex: 0xE3F6E8)

    /// Behind a warm accent icon — a star, a reward.
    static let warmTint = UIColor(hex: 0xFFF3DD)

    /// That icon itself.
    static let warmIcon = UIColor(hex: 0xA86A12)

    /// The simulated notification shade — cooler than `surface`, so it reads
    /// as system chrome laid over the app rather than as part of it.
    static let notificationSurface = UIColor(hex: 0xEEF4F6)

    // MARK: - Borders

    /// Card borders and dividers.
    static let borderSubtle = UIColor(hex: 0xECEFF6)

    /// Inputs and outlined controls.
    static let borderDefault = UIColor(hex: 0xD9DFED)

    // MARK: - Content on dark surfaces

    /// Headings and primary content.
    static let onDarkPrimary = UIColor.white

    /// Supporting copy.
    static let onDarkSecondary = UIColor.white.withAlphaComponent(0.78)

    /// Footnotes and least-prominent copy.
    static let onDarkFootnote = UIColor.white.withAlphaComponent(0.55)
}

// MARK: - Hex convenience

extension UIColor {

    /// Creates a colour from a 24-bit RGB value.
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
