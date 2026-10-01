//
//  IconTileView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/IconTile.swift.
//  A rounded square holding a single SF Symbol.
//

import UIKit

final class IconTileView: UIView {

    private let imageView = UIImageView()

    init(
        systemImage: String,
        size: CGFloat = BrewSize.iconTile,
        symbolSize: CGFloat = 20,
        background: UIColor = BrewColor.primaryLightTint,
        tint: UIColor = BrewColor.primary
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = background
        layer.cornerRadius = BrewCorner.input
        layer.cornerCurve = .continuous
        clipsToBounds = true
        isAccessibilityElement = false

        imageView.image = UIImage(
            systemName: systemImage,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: symbolSize, weight: .regular)
        )
        imageView.tintColor = tint
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
