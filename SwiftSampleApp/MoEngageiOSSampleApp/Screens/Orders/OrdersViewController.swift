//
//  OrdersViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Orders/OrdersView.swift.
//
//  Order history, and the root of the Orders tab.
//
//  The filters here genuinely filter, unlike the menu's — which are
//  presentation only. Both match the Android sample.
//
//  MoEngage moments:
//  - The screen is a nudge campaign's target, so it asks for one on arrival.
//    A nudge anchors itself to a position rather than covering the screen, so
//    unlike the menu's modal it is asked for every visit rather than once a
//    session.
//

import UIKit

final class OrdersViewController: UIViewController {

    private let orders: [Order]
    private let onTrack: (Order) -> Void
    private let onReorder: (Order) -> Void
    private let onSubscribe: () -> Void

    private var activeFilter: String = OrderCatalogue.filters[0]

    private var visible: [Order] {
        switch activeFilter {
        case "Pickup": return orders.filter { $0.mode == .pickup }
        case "Delivery": return orders.filter { $0.mode == .delivery }
        default: return orders
        }
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var filterButtons: [PillButton] = []

    private static let orderCellID = "OrderCardCell"
    private static let nudgeCellID = "SubscriptionNudgeCell"

    init(
        orders: [Order],
        onTrack: @escaping (Order) -> Void,
        onReorder: @escaping (Order) -> Void,
        onSubscribe: @escaping () -> Void
    ) {
        self.orders = orders
        self.onTrack = onTrack
        self.onReorder = onReorder
        self.onSubscribe = onSubscribe
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground

        // No back control: this is a tab's root, not a pushed screen.
        let header = BrewAppBarView(title: "Your orders", subtitle: OrderCatalogue.headerMeta, showsBack: false)
        let filterBar = makeFilterBar()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderCardCell.self, forCellReuseIdentifier: Self.orderCellID)
        tableView.register(SubscriptionNudgeCell.self, forCellReuseIdentifier: Self.nudgeCellID)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 28, right: 0)

        view.addSubview(header)
        view.addSubview(filterBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            filterBar.topAnchor.constraint(equalTo: header.bottomAnchor),
            filterBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            filterBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            filterBar.heightAnchor.constraint(equalToConstant: 46),

            tableView.topAnchor.constraint(equalTo: filterBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MoEngageSDKHelper.setInAppContext(.orders)
        MoEngageSDKHelper.showNudge()
    }

    // MARK: - Filters

    private func makeFilterBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = BrewColor.surface

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        filterButtons = OrderCatalogue.filters.map { filter in
            let button = PillButton(kind: .filter, title: filter)
            button.setPillSelected(filter == activeFilter)
            button.addTapAction(for: .touchUpInside) { [weak self] in self?.select(filter: filter) }
            return button
        }
        filterButtons.forEach { stack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: BrewSize.screenPadding),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -BrewSize.screenPadding),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -12),
        ])

        return container
    }

    private func select(filter: String) {
        guard filter != activeFilter else { return }
        activeFilter = filter
        for button in filterButtons {
            button.setPillSelected(button.title(for: .normal) == filter)
        }
        tableView.reloadData()
    }
}

// MARK: - Table

extension OrdersViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // One row per visible order, plus the subscription nudge closing the list.
        visible.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < visible.count {
            let order = visible[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.orderCellID, for: indexPath) as! OrderCardCell
            cell.configure(order: order) { [weak self] in
                guard let self else { return }
                if order.active {
                    self.onTrack(order)
                } else {
                    self.onReorder(order)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.nudgeCellID, for: indexPath) as! SubscriptionNudgeCell
            cell.configure { [weak self] in self?.onSubscribe() }
            return cell
        }
    }
}

// MARK: - Order card cell

private final class OrderCardCell: UITableViewCell {

    private let stripe = UIView()
    private let idLabel = UILabel()
    private let statusPill = PillLabel(text: "Brewing", background: BrewColor.successTint, textColor: BrewColor.successText)
    private let itemsLabel = UILabel()
    private let amountLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    private var onAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let card = CardContainerView(uniformPadding: 0)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BrewSize.screenPadding),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BrewSize.screenPadding),
        ])

        stripe.backgroundColor = BrewColor.primary
        stripe.translatesAutoresizingMaskIntoConstraints = false

        idLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        itemsLabel.apply(.support, color: BrewColor.textSecondary)
        itemsLabel.numberOfLines = 0
        amountLabel.apply(.subtitleBold, color: BrewColor.textPrimary)

        let topRow = UIStackView(arrangedSubviews: [idLabel, statusPill])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center
        statusPill.setContentHuggingPriority(.required, for: .horizontal)

        actionButton.titleLabel?.font = BrewTextStyle.captionMedium.font
        actionButton.layer.cornerRadius = BrewCorner.chip
        actionButton.layer.cornerCurve = .continuous
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        let bottomRow = UIStackView(arrangedSubviews: [amountLabel, UIView(), actionButton])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 8
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)

        let content = UIStackView(arrangedSubviews: [topRow, itemsLabel, bottomRow])
        content.axis = .vertical
        content.spacing = 10
        content.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stripe)
        card.addSubview(content)

        NSLayoutConstraint.activate([
            stripe.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stripe.topAnchor.constraint(equalTo: card.topAnchor),
            stripe.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stripe.widthAnchor.constraint(equalToConstant: BrewSize.activeStripe),

            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(order: Order, onAction: @escaping () -> Void) {
        self.onAction = onAction
        idLabel.text = "#\(order.id) · \(order.placedAt)"
        idLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        itemsLabel.text = order.lines.map(\.name).joined(separator: ", ")
        itemsLabel.apply(.support, color: BrewColor.textSecondary)
        amountLabel.text = rupees(order.amount)
        amountLabel.apply(.subtitleBold, color: BrewColor.textPrimary)

        stripe.isHidden = !order.active
        statusPill.isHidden = !order.active

        if order.active {
            actionButton.setTitle("Track", for: .normal)
            actionButton.setTitleColor(BrewColor.textPrimary, for: .normal)
            actionButton.backgroundColor = BrewColor.surface
            actionButton.layer.borderWidth = 1
            actionButton.layer.borderColor = BrewColor.borderDefault.cgColor
        } else {
            actionButton.setTitle("Reorder", for: .normal)
            actionButton.setTitleColor(BrewColor.onDarkPrimary, for: .normal)
            actionButton.backgroundColor = BrewColor.primary
            actionButton.layer.borderWidth = 0
        }
    }

    @objc private func actionTapped() {
        onAction?()
    }
}

// MARK: - Small pill label

/// A read-only capsule label — the green "Brewing" status pill.
private final class PillLabel: UILabel {

    init(text: String, background: UIColor, textColor: UIColor) {
        super.init(frame: .zero)
        self.text = text
        apply(.microMedium, color: textColor)
        self.backgroundColor = background
        layer.cornerCurve = .continuous
        clipsToBounds = true
        textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 20, height: size.height + 8)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)))
    }
}

// MARK: - Subscription nudge cell

/// The dashed card closing the list. Dashed rather than solid to read as an
/// offer rather than as another order.
private final class SubscriptionNudgeCell: UITableViewCell {

    private let dashLayer = CAShapeLayer()
    private let container = UIView()
    private var onSetUp: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.addSublayer(dashLayer)
        dashLayer.strokeColor = BrewColor.borderDefault.cgColor
        dashLayer.fillColor = UIColor.clear.cgColor
        dashLayer.lineDashPattern = [12, 10]
        dashLayer.lineWidth = 1

        contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BrewSize.screenPadding),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BrewSize.screenPadding),
        ])

        let icon = IconTileView(systemImage: "cup.and.saucer", size: 40)

        let label = UILabel()
        label.text = OrderCatalogue.subscriptionNudge
        label.apply(.support, color: BrewColor.textSecondary)
        label.numberOfLines = 0

        let setUpButton = UIButton(type: .system)
        setUpButton.setTitle("Set up", for: .normal)
        setUpButton.titleLabel?.font = BrewTextStyle.captionMedium.font
        setUpButton.setTitleColor(BrewColor.link, for: .normal)
        setUpButton.addTarget(self, action: #selector(setUpTapped), for: .touchUpInside)
        setUpButton.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [icon, label, setUpButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = container.bounds
        dashLayer.frame = rect
        dashLayer.path = UIBezierPath(
            roundedRect: rect.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: BrewCorner.card
        ).cgPath
    }

    func configure(onSetUp: @escaping () -> Void) {
        self.onSetUp = onSetUp
    }

    @objc private func setUpTapped() {
        onSetUp?()
    }
}
