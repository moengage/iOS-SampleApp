//
//  SelectCardButton.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/SelectCard.swift.
//  A selectable card carrying a title and a supporting line — one of a set,
//  where exactly one is chosen (cup sizes, fulfilment options).
//

import UIKit

final class SelectCardButton: UIButton {

    private let titleLabelView = UILabel()
    private let subtitleLabelView = UILabel()

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = BrewCorner.input
        layer.cornerCurve = .continuous
        layer.borderWidth = 1

        titleLabelView.text = title
        titleLabelView.isUserInteractionEnabled = false
        subtitleLabelView.text = subtitle
        subtitleLabelView.apply(.micro, color: BrewColor.textSecondary)
        subtitleLabelView.isUserInteractionEnabled = false

        let stack = UIStackView(arrangedSubviews: [titleLabelView, subtitleLabelView])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])

        setSelected(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitleText(_ title: String, subtitle: String) {
        titleLabelView.text = title
        subtitleLabelView.text = subtitle
    }

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? BrewColor.primarySelectedTint : BrewColor.surface
        layer.borderColor = (selected ? BrewColor.primary : BrewColor.borderSubtle).cgColor
        titleLabelView.apply(selected ? .bodyMedium : .body, color: BrewColor.textPrimary)
        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}
