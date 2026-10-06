//
//  SectionHeaderView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/SectionHeader.swift.
//  A section title with an optional trailing text action.
//

import UIKit

final class SectionHeaderView: UIView {

    var action: (() -> Void)?

    init(title: String, actionLabel: String? = nil, action: (() -> Void)? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.action = action

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.apply(.cardTitle, color: BrewColor.textPrimary)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let actionLabel, action != nil {
            let button = UIButton(type: .system)
            button.setTitle(actionLabel, for: .normal)
            button.setTitleColor(BrewColor.link, for: .normal)
            button.titleLabel?.font = BrewTextStyle.captionMedium.font
            button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

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

    @objc private func actionTapped() {
        action?()
    }
}
