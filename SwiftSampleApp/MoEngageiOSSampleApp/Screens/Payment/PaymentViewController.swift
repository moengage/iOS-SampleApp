//
//  PaymentViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Payment/PaymentView.swift.
//
//  MoEngage moments:
//  - `setInAppContext(.payment)` + `trackCheckoutStarted(amount:fulfilment:
//    coupon:)` on arrival (`viewWillAppear`, mirroring `.onAppear`). No
//    in-app campaign is requested — interrupting a payment with a modal is
//    the one place it should not appear, matching PaymentView.swift.
//  - On "Pay", reproduces exactly what `MainTabView.swift`'s `.payment`
//    destination builder does (and, transitively, `MainTabBarController`'s
//    `makePayment()`): `orders.placeOrder(from: cart)` (which itself reports
//    `Order_Placed` from `OrderState`), then, iOS 18+, starts the
//    order-tracking Live Activity, then hands the order to `onOrderPlaced`.
//

import UIKit

final class PaymentViewController: UIViewController {

    private let cart: CartState
    private let orders: OrderState
    private let onBack: () -> Void
    private let onOrderPlaced: (Order) -> Void

    private var methodButtons: [String: UIControl] = [:]
    private var methodDots: [String: UIView] = [:]

    init(cart: CartState, orders: OrderState, onBack: @escaping () -> Void, onOrderPlaced: @escaping (Order) -> Void) {
        self.cart = cart
        self.orders = orders
        self.onBack = onBack
        self.onOrderPlaced = onOrderPlaced
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
        MoEngageSDKHelper.setInAppContext(.payment)
        let bill = cart.bill
        MoEngageSDKHelper.trackCheckoutStarted(amount: bill.toPay, fulfilment: cart.fulfilment, coupon: bill.couponCode)
    }

    // MARK: - Layout

    private func buildLayout() {
        let appBar = BrewAppBarView(title: "Payment")
        appBar.onBack = { [weak self] in self?.onBack() }

        let bill = cart.bill

        // Summary.
        let summaryCard = BrewCardView(background: BrewColor.pageBackground)
        let fulfilmentLabel = UILabel()
        fulfilmentLabel.text = "\(cart.fulfilment.label) · \(Store.summaryLine)"
        fulfilmentLabel.apply(.caption, color: BrewColor.textSecondary)
        let itemsLabel = UILabel()
        itemsLabel.text = "\(cart.lines.count) items · ready in \(cart.fulfilment.eta)"
        itemsLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        let summaryTextStack = UIStackView(arrangedSubviews: [fulfilmentLabel, itemsLabel])
        summaryTextStack.axis = .vertical
        summaryTextStack.spacing = 4
        summaryTextStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let summaryPriceLabel = UILabel()
        summaryPriceLabel.text = rupees(bill.toPay)
        summaryPriceLabel.apply(.titleBoldSmall, color: BrewColor.textPrimary)
        summaryPriceLabel.numberOfLines = 1
        summaryPriceLabel.setContentHuggingPriority(.required, for: .horizontal)

        let summaryRow = UIStackView(arrangedSubviews: [summaryTextStack, summaryPriceLabel])
        summaryRow.axis = .horizontal
        summaryRow.alignment = .center
        summaryRow.spacing = 12
        summaryRow.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.contentView.addSubview(summaryRow)
        NSLayoutConstraint.activate([
            summaryRow.topAnchor.constraint(equalTo: summaryCard.contentView.topAnchor, constant: 16),
            summaryRow.bottomAnchor.constraint(equalTo: summaryCard.contentView.bottomAnchor, constant: -16),
            summaryRow.leadingAnchor.constraint(equalTo: summaryCard.contentView.leadingAnchor, constant: 16),
            summaryRow.trailingAnchor.constraint(equalTo: summaryCard.contentView.trailingAnchor, constant: -16),
        ])

        // Methods.
        let methodsStack = UIStackView()
        methodsStack.axis = .vertical
        methodsStack.spacing = 12
        for method in OrderCatalogue.paymentMethods {
            methodsStack.addArrangedSubview(makeMethodRow(method))
        }

        var sections: [UIView] = [summaryCard, methodsStack]

        if let couponCode = bill.couponCode {
            sections.append(makeCouponBanner(code: couponCode, discount: bill.discount))
        }

        let contentStack = UIStackView(arrangedSubviews: sections)
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: BrewSize.screenPadding, left: BrewSize.screenPadding,
            bottom: BrewSize.screenPadding, right: BrewSize.screenPadding
        )
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        // Footer.
        let footer = FooterBarView()
        let payButton = BrewPrimaryButton()
        payButton.setTitle("Pay \(rupees(bill.toPay))", for: .normal)
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        footer.contentContainer.addSubview(payButton)
        NSLayoutConstraint.activate([
            payButton.topAnchor.constraint(equalTo: footer.contentContainer.topAnchor),
            payButton.bottomAnchor.constraint(equalTo: footer.contentContainer.bottomAnchor),
            payButton.leadingAnchor.constraint(equalTo: footer.contentContainer.leadingAnchor),
            payButton.trailingAnchor.constraint(equalTo: footer.contentContainer.trailingAnchor),
        ])

        let root = UIStackView(arrangedSubviews: [appBar, scrollView, footer])
        root.axis = .vertical
        root.spacing = 0
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func makeMethodRow(_ method: PaymentMethod) -> UIView {
        let control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.layer.cornerRadius = 9
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.isUserInteractionEnabled = false
        dot.widthAnchor.constraint(equalToConstant: 18).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let label = UILabel()
        label.text = "\(method.label) · \(method.detail)"
        label.apply(.body, color: BrewColor.textPrimary)
        label.isUserInteractionEnabled = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [dot, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        control.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: control.topAnchor, constant: 6),
            row.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -6),
            row.leadingAnchor.constraint(equalTo: control.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: control.trailingAnchor),
        ])

        control.addTapAction(for: .touchUpInside) { [weak self] in self?.selectMethod(method.id) }
        methodButtons[method.id] = control
        methodDots[method.id] = dot
        updateDot(dot, selected: method.id == orders.paymentMethodID)
        return control
    }

    private func makeCouponBanner(code: String, discount: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = BrewColor.primaryLightTint
        container.layer.cornerRadius = BrewCorner.button
        container.layer.cornerCurve = .continuous

        let icon = UIImageView(image: UIImage(systemName: "tag.fill"))
        icon.tintColor = BrewColor.primary
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = "\(code) applied — you saved \(rupees(discount))"
        label.apply(.body, color: BrewColor.textPrimary)
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        return container
    }

    private func updateDot(_ dot: UIView, selected: Bool) {
        dot.layer.borderWidth = selected ? 5 : 1
        dot.layer.borderColor = (selected ? BrewColor.primary : BrewColor.borderDefault).cgColor
        dot.backgroundColor = .clear
    }

    private func selectMethod(_ id: String) {
        orders.paymentMethodID = id
        for (methodID, dot) in methodDots {
            updateDot(dot, selected: methodID == id)
        }
    }

    // MARK: - Actions

    @objc private func payTapped() {
        let order = orders.placeOrder(from: cart)

        // Starts the order-tracking Live Activity the moment the order
        // exists, matching MainTabView.swift's `.payment` destination.
        if #available(iOS 18, *) {
            MoEngageSDKHelper.startOrderTracking(orderID: order.id, status: "Order Placed", etaMinutes: 12)
        }

        onOrderPlaced(order)
    }
}
