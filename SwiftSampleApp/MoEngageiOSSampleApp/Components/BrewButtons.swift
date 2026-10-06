//
//  BrewButtons.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/BrewButtonStyle.swift.
//  Filled primary and outlined secondary calls to action. Full width (pin
//  leading/trailing yourself), 52 pt minimum height, 12 pt radius.
//

import UIKit

final class BrewPrimaryButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.primary
        setTitleColor(BrewColor.onDarkPrimary, for: .normal)
        setTitleColor(BrewColor.onDarkPrimary.withAlphaComponent(0.6), for: .disabled)
        titleLabel?.font = BrewTextStyle.cardTitle.font
        titleLabel?.adjustsFontForContentSizeCategory = true
        layer.cornerRadius = BrewCorner.button
        layer.cornerCurve = .continuous
        heightAnchor.constraint(greaterThanOrEqualToConstant: BrewSize.buttonHeight).isActive = true
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.85 : 1 }
    }
}

final class BrewSecondaryButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.surface
        setTitleColor(BrewColor.textPrimary, for: .normal)
        titleLabel?.font = BrewTextStyle.cardTitle.font
        titleLabel?.adjustsFontForContentSizeCategory = true
        layer.cornerRadius = BrewCorner.button
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = BrewColor.borderDefault.cgColor
        heightAnchor.constraint(greaterThanOrEqualToConstant: BrewSize.buttonHeight).isActive = true
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.85 : 1 }
    }
}
