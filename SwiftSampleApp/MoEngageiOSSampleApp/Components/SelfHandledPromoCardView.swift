//
//  SelfHandledPromoCardView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Menu/SelfHandledPromoCard.swift.
//
//  A self-handled in-app campaign, drawn by the app rather than the SDK. Dark,
//  single-row card above the menu's section header, dismissible without being
//  tapped.
//
//  MoEngage moments (shown/clicked/dismissed) are reported by the caller, not
//  by this view — same split as the SwiftUI source.
//
//  Built from subviews added directly to this `UIControl` (rather than a
//  wrapping `UIStackView` "row") so nothing but the dismiss button sits between
//  the card's own touch tracking and the user's finger: an intermediate plain
//  `UIView`/`UIStackView` would otherwise be returned by hit-testing and
//  silently swallow the tap before it reached this control's `.touchUpInside`.
//

import UIKit

final class SelfHandledPromoCardView: UIControl {

    var onDismiss: (() -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(payload: PromoPayload) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.primaryDarkSurface
        layer.cornerRadius = BrewCorner.card
        layer.cornerCurve = .continuous
        clipsToBounds = true

        let icon = IconTileView(
            systemImage: "tag.fill",
            background: BrewColor.onDarkSecondary.withAlphaComponent(0.16),
            tint: BrewColor.onDarkPrimary
        )
        icon.isUserInteractionEnabled = false

        titleLabel.text = payload.title
        titleLabel.apply(.bodyMedium, color: BrewColor.onDarkPrimary)
        subtitleLabel.text = payload.subtitle
        subtitleLabel.apply(.caption, color: BrewColor.onDarkSecondary)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(
            UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)),
            for: .normal
        )
        dismissButton.tintColor = BrewColor.onDarkSecondary
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.accessibilityLabel = "Dismiss"

        addSubview(icon)
        addSubview(textStack)
        addSubview(dismissButton)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 14),

            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            dismissButton.widthAnchor.constraint(equalToConstant: 28),
            dismissButton.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: dismissButton.leadingAnchor, constant: -8),
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14),
            bottomAnchor.constraint(greaterThanOrEqualTo: icon.bottomAnchor, constant: 14),
            bottomAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor, constant: 14),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dismissTapped() {
        onDismiss?()
    }
}
