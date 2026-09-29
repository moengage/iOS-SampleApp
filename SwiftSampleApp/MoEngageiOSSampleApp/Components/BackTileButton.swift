//
//  BackTileButton.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/BackTile.swift.
//  The outlined square back control, 36 pt with a 10 pt radius, inside a
//  44 pt tappable area.
//

import UIKit

final class BackTileButton: UIButton {

    private let borderView = UIView()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setImage(
            UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)),
            for: .normal
        )
        tintColor = BrewColor.textPrimary
        accessibilityLabel = "Back"

        borderView.isUserInteractionEnabled = false
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = BrewColor.borderDefault.cgColor
        borderView.layer.cornerRadius = BrewCorner.input
        borderView.layer.cornerCurve = .continuous
        borderView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(borderView, at: 0)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: BrewSize.touchTarget),
            heightAnchor.constraint(equalToConstant: BrewSize.touchTarget),
            borderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: BrewSize.backTile),
            borderView.heightAnchor.constraint(equalToConstant: BrewSize.backTile),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
