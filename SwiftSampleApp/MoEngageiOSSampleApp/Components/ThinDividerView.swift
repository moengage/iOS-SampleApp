//
//  ThinDividerView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/ThinDivider.swift.
//  A one-point rule.
//

import UIKit

final class ThinDividerView: UIView {

    init(color: UIColor = BrewColor.borderSubtle) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
