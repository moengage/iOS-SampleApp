//
//  DetailRowView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/DetailRow.swift.
//  A label on the left and a value on the right.
//

import UIKit

final class DetailRowView: UIView {

    private let labelView = UILabel()
    private let valueView = UILabel()

    init(
        label: String,
        value: String,
        labelStyle: BrewTextStyle = .body,
        labelColor: UIColor = BrewColor.textSecondary,
        valueStyle: BrewTextStyle = .bodyMedium,
        valueColor: UIColor = BrewColor.textPrimary
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        labelView.text = label
        labelView.apply(labelStyle, color: labelColor)
        labelView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        valueView.text = value
        valueView.apply(valueStyle, color: valueColor)
        valueView.textAlignment = .right
        valueView.numberOfLines = 1
        valueView.setContentHuggingPriority(.required, for: .horizontal)
        valueView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [labelView, valueView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .firstBaseline
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
