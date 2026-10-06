//
//  BrewButtonFactory.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/BrewButtonStyle.swift.
//
//  SwiftUI expresses each appearance as a `ButtonStyle`; UIKit has no
//  equivalent that composes onto a plain `UIButton`, so these are plain
//  factory functions that configure a `UIButton` to match. Full width is left
//  to the caller's Auto Layout constraints (or a stack view's arrangement)
//  rather than baked in here.
//
//  Deliberately avoids `UIButton.Configuration` (iOS 15+) so this keeps
//  working back to this target's iOS 13.0 minimum — plain `UIButton`
//  properties instead.
//

import UIKit

enum BrewButtonFactory {

    /// Filled primary call to action. Minimum 52 pt height, 12 pt radius.
    static func makePrimaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(BrewColor.onDarkPrimary, for: .normal)
        button.titleLabel?.font = BrewTextStyle.cardTitle.font
        button.backgroundColor = BrewColor.primary
        button.layer.cornerRadius = BrewCorner.button
        button.layer.cornerCurve = .continuous
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: BrewSize.buttonHeight).isActive = true
        return button
    }

    /// Outlined secondary action. Minimum 52 pt height, 12 pt radius.
    static func makeSecondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(BrewColor.textPrimary, for: .normal)
        button.titleLabel?.font = BrewTextStyle.cardTitle.font
        button.backgroundColor = BrewColor.surface
        button.layer.cornerRadius = BrewCorner.button
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 1
        button.layer.borderColor = BrewColor.borderDefault.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: BrewSize.buttonHeight).isActive = true
        return button
    }

    /// Low-emphasis text action. No fill, no border.
    static func makeQuietButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(BrewColor.textSecondary, for: .normal)
        button.titleLabel?.font = BrewTextStyle.cardTitle.font
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: BrewSize.touchTarget).isActive = true
        return button
    }
}
