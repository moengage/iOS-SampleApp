//
//  FooterBarView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/FooterBar.swift.
//  The pinned action bar at the bottom of a screen: a rule, then content on a
//  white surface. Meant to be pinned outside a screen's scroll view so it
//  stays put while the content moves.
//

import UIKit

final class FooterBarView: UIView {

    /// Add the screen's action content into this container.
    let contentContainer = UIView()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.surface

        let divider = ThinDividerView()
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(divider)
        addSubview(contentContainer)

        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentContainer.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BrewSize.screenPadding),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BrewSize.screenPadding),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
