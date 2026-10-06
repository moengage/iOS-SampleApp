//
//  OrderStatusViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/OrderStatus/OrderStatusView.swift.
//
//  MoEngage moment: `setInAppContext(.orderStatus)` on arrival — the same
//  timing as the SwiftUI source's `.inAppContext(.orderStatus)`. No event is
//  reported here; `Order_Placed` was already reported by `OrderState.placeOrder`.
//

import UIKit

final class OrderStatusViewController: UIViewController {

    private let order: Order
    private let onMyOrders: () -> Void
    private let onBackToMenu: () -> Void

    init(order: Order, onMyOrders: @escaping () -> Void, onBackToMenu: @escaping () -> Void) {
        self.order = order
        self.onMyOrders = onMyOrders
        self.onBackToMenu = onBackToMenu
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MoEngageSDKHelper.setInAppContext(.orderStatus)
    }

    // MARK: - Layout

    private func buildLayout() {
        let header = makeHeader()

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let contentStack = UIStackView(arrangedSubviews: [makeProgressCard(), makeItemsCard()])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: BrewSize.screenPadding, left: BrewSize.screenPadding,
            bottom: BrewSize.screenPadding, right: BrewSize.screenPadding
        )
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        let footer = FooterBarView()
        let myOrdersButton = BrewSecondaryButton()
        myOrdersButton.setTitle("My orders", for: .normal)
        myOrdersButton.addTarget(self, action: #selector(myOrdersTapped), for: .touchUpInside)
        let backToMenuButton = BrewPrimaryButton()
        backToMenuButton.setTitle("Back to menu", for: .normal)
        backToMenuButton.addTarget(self, action: #selector(backToMenuTapped), for: .touchUpInside)

        let footerRow = UIStackView(arrangedSubviews: [myOrdersButton, backToMenuButton])
        footerRow.axis = .horizontal
        footerRow.spacing = 12
        footerRow.distribution = .fillEqually
        footerRow.translatesAutoresizingMaskIntoConstraints = false
        footer.contentContainer.addSubview(footerRow)
        NSLayoutConstraint.activate([
            footerRow.topAnchor.constraint(equalTo: footer.contentContainer.topAnchor),
            footerRow.bottomAnchor.constraint(equalTo: footer.contentContainer.bottomAnchor),
            footerRow.leadingAnchor.constraint(equalTo: footer.contentContainer.leadingAnchor),
            footerRow.trailingAnchor.constraint(equalTo: footer.contentContainer.trailingAnchor),
        ])

        let root = UIStackView(arrangedSubviews: [header, scrollView, footer])
        root.axis = .vertical
        root.spacing = 0
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func makeHeader() -> UIView {
        let container = UIView()
        container.backgroundColor = BrewColor.primaryLightTint

        let circle = UIView()
        circle.backgroundColor = BrewColor.primary
        circle.layer.cornerRadius = BrewSize.statusCircle / 2
        circle.translatesAutoresizingMaskIntoConstraints = false
        let checkImage = UIImageView(image: UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        ))
        checkImage.tintColor = BrewColor.onDarkPrimary
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(checkImage)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: BrewSize.statusCircle),
            circle.heightAnchor.constraint(equalToConstant: BrewSize.statusCircle),
            checkImage.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Order placed"
        titleLabel.apply(.heroHeader, color: BrewColor.textPrimary)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "#\(order.id) · show this at the bar"
        subtitleLabel.apply(.support, color: BrewColor.textSecondary)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [circle, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 32, left: BrewSize.screenPadding, bottom: 20, right: BrewSize.screenPadding)
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        return container
    }

    private func makeProgressCard() -> UIView {
        let card = BrewCardView()

        let icon = UIImageView(image: UIImage(systemName: "timer"))
        icon.tintColor = BrewColor.primary
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = "Grinding & brewing"
        titleLabel.apply(.subtitleMedium, color: BrewColor.textPrimary)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let etaLabel = UILabel()
        etaLabel.text = order.readyAt
        etaLabel.apply(.caption, color: BrewColor.textSecondary)
        etaLabel.setContentHuggingPriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [icon, titleLabel, etaLabel])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 10

        let progress = makeProgressSteps()

        let stack = UIStackView(arrangedSubviews: [titleRow, progress])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -16),
        ])
        return card
    }

    private func makeProgressSteps() -> UIView {
        let reached = OrderStage.allCases.firstIndex(of: order.stage) ?? 0

        let segmentsRow = UIStackView()
        segmentsRow.axis = .horizontal
        segmentsRow.spacing = 6
        segmentsRow.distribution = .fillEqually
        for (index, _) in OrderStage.allCases.enumerated() {
            let segment = UIView()
            segment.backgroundColor = index <= reached ? BrewColor.primary : BrewColor.neutralFill
            segment.layer.cornerRadius = BrewCorner.track
            segment.layer.cornerCurve = .continuous
            segment.translatesAutoresizingMaskIntoConstraints = false
            segment.heightAnchor.constraint(equalToConstant: BrewSize.progressSegmentHeight).isActive = true
            segmentsRow.addArrangedSubview(segment)
        }

        let labelsRow = UIStackView()
        labelsRow.axis = .horizontal
        labelsRow.spacing = 6
        labelsRow.distribution = .fillEqually
        for stage in OrderStage.allCases {
            let label = UILabel()
            label.text = stage.label
            label.apply(.micro, color: stage == order.stage ? BrewColor.textPrimary : BrewColor.textTertiary)
            labelsRow.addArrangedSubview(label)
        }

        let stack = UIStackView(arrangedSubviews: [segmentsRow, labelsRow])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func makeItemsCard() -> UIView {
        let card = BrewCardView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        for (index, line) in order.lines.enumerated() {
            if index > 0 {
                stack.addArrangedSubview(ThinDividerView())
            }
            let row = DetailRowView(label: line.name, value: rupees(line.amount), labelColor: BrewColor.textPrimary)
            let padded = UIView()
            padded.translatesAutoresizingMaskIntoConstraints = false
            row.translatesAutoresizingMaskIntoConstraints = false
            padded.addSubview(row)
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: padded.topAnchor, constant: 14),
                row.bottomAnchor.constraint(equalTo: padded.bottomAnchor, constant: -14),
                row.leadingAnchor.constraint(equalTo: padded.leadingAnchor, constant: 16),
                row.trailingAnchor.constraint(equalTo: padded.trailingAnchor, constant: -16),
            ])
            stack.addArrangedSubview(padded)
        }

        stack.addArrangedSubview(ThinDividerView())

        let paidLabel = UILabel()
        paidLabel.text = order.paidVia
        paidLabel.apply(.body, color: BrewColor.textSecondary)
        paidLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let amountLabel = UILabel()
        amountLabel.text = rupees(order.amount)
        amountLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)

        let totalRow = UIStackView(arrangedSubviews: [paidLabel, amountLabel])
        totalRow.axis = .horizontal
        totalRow.spacing = 12
        totalRow.backgroundColor = BrewColor.pageBackground
        totalRow.isLayoutMarginsRelativeArrangement = true
        totalRow.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        stack.addArrangedSubview(totalRow)

        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
        ])
        return card
    }

    // MARK: - Actions

    @objc private func myOrdersTapped() {
        onMyOrders()
    }

    @objc private func backToMenuTapped() {
        onBackToMenu()
    }
}
