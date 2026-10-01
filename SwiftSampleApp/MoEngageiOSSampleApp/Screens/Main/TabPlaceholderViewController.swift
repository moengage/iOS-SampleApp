//
//  TabPlaceholderViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Main/TabPlaceholderView.swift.
//
//  Stands in for a tab's screen until that screen exists.
//
//  Temporary. Every use of this view controller is removed as its tab is built.
//

import UIKit

final class TabPlaceholderViewController: UIViewController {

    private let brewTab: BrewTab

    init(tab: BrewTab) {
        self.brewTab = tab
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground
        buildLayout()
    }

    private func buildLayout() {
        let icon = UIImageView(image: UIImage(systemName: brewTab.systemImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)))
        icon.tintColor = BrewColor.textTertiary
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = brewTab.title
        title.apply(.screenTitleSmall, color: BrewColor.textPrimary)

        let message = UILabel()
        message.text = "Coming next."
        message.apply(.caption, color: BrewColor.textSecondary)

        let stack = UIStackView(arrangedSubviews: [icon, title, message])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
