//
//  BrewTypography.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/DesignSystem/BrewTypography.swift.
//  Same entries, `UIFont` instead of `Font`; supports Dynamic Type via
//  `UIFontMetrics` instead of `@ScaledMetric`.
//

import UIKit

/// A single entry of the application type ramp.
enum BrewTextStyle {

    /// 38 pt bold — the splash wordmark.
    case display

    /// 26 pt bold — screen titles.
    case screenTitle

    /// 24 pt bold — the headline of a full-screen message.
    case screenTitleSmall

    /// 22 pt bold — the item name on its detail screen.
    case heroHeader

    /// 20 pt bold — the greeting name.
    case titleBold

    /// 18 pt bold — an amount due, and the profile name.
    case titleBoldSmall

    /// 19 pt bold — the initials in an avatar.
    case initials

    /// 16 pt medium — navigation bars, card titles, section headers and primary
    /// button labels.
    case cardTitle

    /// 16 pt bold — a bill's total.
    case cardTitleBold

    /// 15 pt regular — value propositions and supporting copy.
    case subtitle

    /// 15 pt medium — a progress step's title.
    case subtitleMedium

    /// 15 pt bold — the price on a list row.
    case subtitleBold

    /// 14 pt regular — body copy.
    case body

    /// 14 pt medium — item names and list titles.
    case bodyMedium

    /// 14 pt bold — the price on a featured card.
    case bodyBold

    /// 13 pt regular — supporting copy.
    case support

    /// 13 pt medium — inline text actions such as "Reorder".
    case supportMedium

    /// 12 pt regular — metadata, hints and timestamps.
    case caption

    /// 12 pt medium — field labels and inline actions.
    case captionMedium

    /// 11 pt regular — micro copy beneath a block.
    case micro

    /// 11 pt medium — pill and badge labels.
    case microMedium

    /// 11 pt medium, uppercased by the call site and letter-spaced — a list's
    /// group header.
    case label

    /// 17 pt medium — one-time-code digits.
    case otpDigit

    var size: CGFloat {
        switch self {
        case .display: return 38
        case .screenTitle: return 26
        case .screenTitleSmall: return 24
        case .heroHeader: return 22
        case .titleBold: return 20
        case .titleBoldSmall: return 18
        case .initials: return 19
        case .otpDigit: return 17
        case .cardTitle, .cardTitleBold: return 16
        case .subtitle, .subtitleBold, .subtitleMedium: return 15
        case .body, .bodyMedium, .bodyBold: return 14
        case .support, .supportMedium: return 13
        case .caption, .captionMedium: return 12
        case .micro, .microMedium, .label: return 11
        }
    }

    var weight: UIFont.Weight {
        switch self {
        case .display, .screenTitle, .screenTitleSmall, .heroHeader, .titleBold, .bodyBold,
             .subtitleBold, .cardTitleBold, .titleBoldSmall, .initials:
            return .bold
        case .cardTitle, .captionMedium, .otpDigit, .bodyMedium, .supportMedium, .microMedium,
             .subtitleMedium, .label:
            return .medium
        case .subtitle, .body, .caption, .micro, .support: return .regular
        }
    }

    /// Specified line height.
    var lineHeight: CGFloat {
        switch self {
        case .display: return 40
        case .screenTitle: return 32
        case .screenTitleSmall: return 30
        case .heroHeader: return 28
        case .titleBold: return 26
        case .titleBoldSmall, .initials: return 24
        case .otpDigit: return 22
        case .cardTitle, .cardTitleBold: return 22
        case .subtitle: return 21
        case .subtitleBold, .subtitleMedium: return 20
        case .body, .bodyMedium, .bodyBold: return 19
        case .support: return 18
        case .supportMedium: return 18
        case .caption, .captionMedium: return 16
        case .micro, .microMedium, .label: return 15
        }
    }

    /// The Dynamic Type text style this entry scales along.
    var dynamicTypeStyle: UIFont.TextStyle {
        switch self {
        case .display: return .largeTitle
        case .screenTitle: return .title1
        case .screenTitleSmall: return .title1
        case .heroHeader: return .title2
        case .titleBold, .titleBoldSmall, .initials: return .title3
        case .otpDigit: return .body
        case .cardTitle, .cardTitleBold: return .callout
        case .subtitle, .subtitleBold, .subtitleMedium: return .subheadline
        case .body, .bodyMedium, .bodyBold: return .subheadline
        case .support, .supportMedium: return .footnote
        case .caption, .captionMedium: return .caption1
        case .micro, .microMedium, .label: return .caption2
        }
    }

    /// Additional space between lines, beyond the font's natural leading.
    var lineSpacing: CGFloat {
        max(0, lineHeight - size * 1.2)
    }

    /// Extra space between characters. Only the uppercased group header has
    /// any; uppercase text set tight reads as a block.
    var tracking: CGFloat {
        self == .label ? size * 0.07 : 0
    }

    /// The scaled font for this entry, honouring Dynamic Type.
    var font: UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: dynamicTypeStyle).scaledFont(for: base)
    }
}

extension UILabel {

    /// Applies an entry of the type ramp, including its Dynamic Type scaling,
    /// line spacing and tracking.
    func apply(_ style: BrewTextStyle, color: UIColor = BrewColor.textPrimary) {
        font = style.font
        textColor = color
        adjustsFontForContentSizeCategory = true

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing
        paragraphStyle.alignment = textAlignment

        let text = self.text ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .kern: style.tracking,
        ]
        attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
