//
//  CardContainerView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/BrewCard.swift.
//
//  The house card: white, 14 pt radius, a 1 pt border and no shadow. Content is
//  arranged by the exposed `stackView` rather than by subclassing, so any
//  screen can drop its own rows in without a dedicated card type per screen.
//

import UIKit

final class CardContainerView: UIView {

    let stackView = UIStackView()

    init(
        padding: UIEdgeInsets = .zero,
        cornerRadius: CGFloat = BrewCorner.card,
        backgroundColor bg: UIColor = BrewColor.surface,
        borderColor: UIColor = BrewColor.borderSubtle
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = bg
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        clipsToBounds = true

        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(uniformPadding: CGFloat, cornerRadius: CGFloat = BrewCorner.card) {
        self.init(
            padding: UIEdgeInsets(top: uniformPadding, left: uniformPadding, bottom: uniformPadding, right: uniformPadding),
            cornerRadius: cornerRadius
        )
    }
}
