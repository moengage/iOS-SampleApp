//
//  BrewCardView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/BrewCard.swift.
//  The house card: white, 14 pt radius, a 1 pt border and no shadow. Add
//  content into `contentView`, pinned to it with your own padding.
//

import UIKit

final class BrewCardView: UIView {

    let contentView = UIView()

    init(
        cornerRadius: CGFloat = BrewCorner.card,
        background: UIColor = BrewColor.surface,
        borderColor: UIColor = BrewColor.borderSubtle
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = background
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        clipsToBounds = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
