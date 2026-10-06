//
//  BrewAppBarView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/BrewAppBar.swift.
//  The app bar used by every pushed screen: a back tile, a title with an
//  optional subtitle, an optional trailing control, and a bottom rule.
//
//  Ordinary content rather than a system navigation bar — the tab bar hides
//  the navigation bar throughout the app, matching the SwiftUI app's
//  `hidesNavigationBar()`.
//

import UIKit

final class BrewAppBarView: UIView {

    var onBack: (() -> Void)?

    private let backButton = BackTileButton()

    /// Add a trailing control (e.g. "Mark all read") into this container.
    let trailingContainer = UIView()

    init(title: String, subtitle: String? = nil, showsBack: Bool = true) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.surface

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.apply(.cardTitle, color: BrewColor.textPrimary)

        let textStack = UIStackView(arrangedSubviews: [titleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        if let subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.apply(.caption, color: BrewColor.textSecondary)
            textStack.addArrangedSubview(subtitleLabel)
        }
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.isHidden = !showsBack

        trailingContainer.translatesAutoresizingMaskIntoConstraints = false
        trailingContainer.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [backButton, textStack, trailingContainer])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        let divider = ThinDividerView()

        addSubview(row)
        addSubview(divider)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: BrewSize.screenPadding),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BrewSize.screenPadding),
            row.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -14),

            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func backTapped() {
        onBack?()
    }
}
