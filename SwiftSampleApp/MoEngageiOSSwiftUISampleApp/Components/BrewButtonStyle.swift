//
//  BrewButtonStyle.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Button appearances for the application.
//
//  These are implemented as `ButtonStyle` values rather than wrapper views so
//  that call sites use a standard `Button` and retain its built-in behaviour:
//  accessibility traits, disabled state, focus handling and localized labels.
//
//      Button("Get started", action: onGetStarted)
//          .buttonStyle(.brewPrimary)
//

import SwiftUI

/// Filled primary call to action. Full width, 52 pt minimum height, 12 pt radius.
struct BrewPrimaryButtonStyle: ButtonStyle {

    /// Reflects `disabled(_:)` from the environment so the style can dim itself.
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brewTextStyle(.cardTitle)
            .foregroundColor(BrewColor.onDarkPrimary)
            .frame(maxWidth: .infinity)
            // A minimum rather than a fixed height, so the label is not clipped
            // at larger content-size categories.
            .frame(minHeight: BrewSize.buttonHeight)
            .background(BrewColor.primary)
            .clipShape(
                RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
            )
            .opacity(opacity(isPressed: configuration.isPressed))
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    /// Dimmed while pressed, and further dimmed when disabled.
    ///
    /// The disabled state is not conveyed by opacity alone: `disabled(_:)` also
    /// applies the corresponding accessibility trait, so assistive technologies
    /// announce it.
    private func opacity(isPressed: Bool) -> Double {
        if !isEnabled { return 0.4 }
        return isPressed ? 0.85 : 1
    }
}

/// Outlined secondary action. Full width, 52 pt minimum height, 12 pt radius.
struct BrewSecondaryButtonStyle: ButtonStyle {

    /// Reflects `disabled(_:)` from the environment so the style can dim itself.
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brewTextStyle(.cardTitle)
            .foregroundColor(BrewColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: BrewSize.buttonHeight)
            .background(BrewColor.surface)
            .clipShape(
                RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
                    .stroke(BrewColor.borderDefault, lineWidth: 1)
            )
            .opacity(opacity(isPressed: configuration.isPressed))
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func opacity(isPressed: Bool) -> Double {
        if !isEnabled { return 0.4 }
        return isPressed ? 0.85 : 1
    }
}

/// Low-emphasis text action. Full width, no fill and no border.
struct BrewQuietButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brewTextStyle(.cardTitle)
            .foregroundColor(BrewColor.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: BrewSize.touchTarget)
            // No fill, so the label alone would be the only tappable area.
            .contentShape(Rectangle())
            .opacity(opacity(isPressed: configuration.isPressed))
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func opacity(isPressed: Bool) -> Double {
        if !isEnabled { return 0.4 }
        return isPressed ? 0.6 : 1
    }
}

extension ButtonStyle where Self == BrewPrimaryButtonStyle {

    /// The filled primary call to action.
    static var brewPrimary: BrewPrimaryButtonStyle { BrewPrimaryButtonStyle() }
}

extension ButtonStyle where Self == BrewSecondaryButtonStyle {

    /// The outlined secondary action.
    static var brewSecondary: BrewSecondaryButtonStyle { BrewSecondaryButtonStyle() }
}

extension ButtonStyle where Self == BrewQuietButtonStyle {

    /// The low-emphasis text action.
    static var brewQuiet: BrewQuietButtonStyle { BrewQuietButtonStyle() }
}
