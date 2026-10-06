//
//  CartViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Cart/CartView.swift.
//
//  The order, before paying for it. Lines are shown, not edited — matching
//  the SwiftUI source, which offers no way to change a line, remove one or
//  empty the order.
//
//  MoEngage moment: `setInAppContext(.cart)` + `trackCartViewed(lines:amount:)`
//  on every arrival (`viewWillAppear`, mirroring `.onAppear`). `Add_To_Cart`
//  was already reported by the item screen; `Checkout_Started` belongs to
//  payment — so this screen reports arrival and nothing else, and asks for no
//  in-app campaign, exactly like CartView.swift.
//

import UIKit
import Combine

final class CartViewController: UIViewController {

    private let cart: CartState
    private let onBack: () -> Void
    private let onAddAnother: () -> Void
    private let onProceed: () -> Void

    private var cancellables = Set<AnyCancellable>()

    private let linesStack = UIStackView()
    private let billContainer = UIView()
    private var fulfilmentCards: [Fulfilment: SelectCardButton] = [:]
    private var cupPills: [CupPreference: PillButton] = [:]
    private let proceedButton = BrewPrimaryButton()

    init(cart: CartState, onBack: @escaping () -> Void, onAddAnother: @escaping () -> Void, onProceed: @escaping () -> Void) {
        self.cart = cart
        self.onBack = onBack
        self.onAddAnother = onAddAnother
        self.onProceed = onProceed
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground
        buildLayout()
        bind()
        refreshAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MoEngageSDKHelper.setInAppContext(.cart)
        MoEngageSDKHelper.trackCartViewed(lines: cart.lines, amount: cart.bill.toPay)
    }

    // MARK: - Binding

    private func bind() {
        cart.$lines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refreshLinesAndBill() }
            .store(in: &cancellables)

        cart.$fulfilment
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fulfilment in
                guard let self else { return }
                for (option, card) in self.fulfilmentCards {
                    card.setSelected(option == fulfilment)
                }
            }
            .store(in: &cancellables)

        cart.$cupPreference
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preference in
                guard let self else { return }
                for (option, pill) in self.cupPills {
                    pill.setPillSelected(option == preference)
                }
                self.refreshBill()
            }
            .store(in: &cancellables)
    }

    // MARK: - Layout

    private func buildLayout() {
        let appBar = BrewAppBarView(title: "Your order")
        appBar.onBack = { [weak self] in self?.onBack() }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Fulfilment.
        let fulfilmentRow = UIStackView()
        fulfilmentRow.axis = .horizontal
        fulfilmentRow.spacing = 12
        fulfilmentRow.distribution = .fillEqually
        for option in Fulfilment.allCases {
            let card = SelectCardButton(title: option.label, subtitle: option.eta)
            card.addTapAction(for: .touchUpInside) { [weak self] in self?.cart.fulfilment = option }
            fulfilmentCards[option] = card
            fulfilmentRow.addArrangedSubview(card)
        }

        // Lines.
        linesStack.axis = .vertical
        linesStack.spacing = 12

        let addAnotherButton = UIButton(type: .system)
        addAnotherButton.setTitle("+ Add another item", for: .normal)
        addAnotherButton.setTitleColor(BrewColor.link, for: .normal)
        addAnotherButton.titleLabel?.font = BrewTextStyle.supportMedium.font
        addAnotherButton.contentHorizontalAlignment = .leading
        addAnotherButton.addTarget(self, action: #selector(addAnotherTapped), for: .touchUpInside)

        let linesSection = UIStackView(arrangedSubviews: [linesStack, addAnotherButton])
        linesSection.axis = .vertical
        linesSection.spacing = 12

        billContainer.translatesAutoresizingMaskIntoConstraints = false

        // Cup preference.
        let cupScroll = UIScrollView()
        cupScroll.showsHorizontalScrollIndicator = false
        cupScroll.translatesAutoresizingMaskIntoConstraints = false
        let cupStack = UIStackView()
        cupStack.axis = .horizontal
        cupStack.spacing = 8
        cupStack.translatesAutoresizingMaskIntoConstraints = false
        for option in CupPreference.allCases {
            let label = option.discount > 0 ? "\(option.label) · −₹\(option.discount)" : option.label
            let pill = PillButton(kind: .select, title: label)
            pill.addTapAction(for: .touchUpInside) { [weak self] in self?.cart.cupPreference = option }
            cupPills[option] = pill
            cupStack.addArrangedSubview(pill)
        }
        cupScroll.addSubview(cupStack)
        NSLayoutConstraint.activate([
            cupStack.topAnchor.constraint(equalTo: cupScroll.contentLayoutGuide.topAnchor),
            cupStack.bottomAnchor.constraint(equalTo: cupScroll.contentLayoutGuide.bottomAnchor),
            cupStack.leadingAnchor.constraint(equalTo: cupScroll.contentLayoutGuide.leadingAnchor),
            cupStack.trailingAnchor.constraint(equalTo: cupScroll.contentLayoutGuide.trailingAnchor),
            cupStack.heightAnchor.constraint(equalTo: cupScroll.frameLayoutGuide.heightAnchor),
        ])

        let contentStack = UIStackView(arrangedSubviews: [fulfilmentRow, linesSection, billContainer, cupScroll])
        contentStack.axis = .vertical
        contentStack.spacing = 18
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

        // Footer.
        let footer = FooterBarView()
        proceedButton.addTarget(self, action: #selector(proceedTapped), for: .touchUpInside)
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        footer.contentContainer.addSubview(proceedButton)
        NSLayoutConstraint.activate([
            proceedButton.topAnchor.constraint(equalTo: footer.contentContainer.topAnchor),
            proceedButton.bottomAnchor.constraint(equalTo: footer.contentContainer.bottomAnchor),
            proceedButton.leadingAnchor.constraint(equalTo: footer.contentContainer.leadingAnchor),
            proceedButton.trailingAnchor.constraint(equalTo: footer.contentContainer.trailingAnchor),
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

    // MARK: - Refresh

    private func refreshAll() {
        for (option, card) in fulfilmentCards {
            card.setSelected(option == cart.fulfilment)
        }
        for (option, pill) in cupPills {
            pill.setPillSelected(option == cart.cupPreference)
        }
        refreshLinesAndBill()
    }

    private func refreshLinesAndBill() {
        linesStack.arrangedSubviews.forEach {
            linesStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for line in cart.lines {
            linesStack.addArrangedSubview(makeLineRow(line))
        }
        refreshBill()
        proceedButton.setTitle("Proceed to pay · \(rupees(cart.bill.toPay))", for: .normal)
    }

    private func refreshBill() {
        billContainer.subviews.forEach { $0.removeFromSuperview() }

        let bill = cart.bill
        let card = BrewCardView()
        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 10
        rowsStack.translatesAutoresizingMaskIntoConstraints = false

        rowsStack.addArrangedSubview(DetailRowView(label: "Item total", value: rupees(bill.itemTotal)))
        rowsStack.addArrangedSubview(DetailRowView(label: "Taxes", value: rupees(bill.taxes)))

        if let couponCode = bill.couponCode {
            rowsStack.addArrangedSubview(DetailRowView(
                label: "\(couponCode) discount",
                value: "−\(rupees(bill.discount))",
                valueColor: BrewColor.successText
            ))
        }

        if bill.cupDiscount > 0 {
            rowsStack.addArrangedSubview(DetailRowView(
                label: "Own cup",
                value: "−\(rupees(bill.cupDiscount))",
                valueColor: BrewColor.successText
            ))
        }

        rowsStack.addArrangedSubview(ThinDividerView())

        rowsStack.addArrangedSubview(DetailRowView(
            label: "To pay",
            value: rupees(bill.toPay),
            labelStyle: .cardTitle,
            labelColor: BrewColor.textPrimary,
            valueStyle: .cardTitleBold
        ))

        card.contentView.addSubview(rowsStack)
        NSLayoutConstraint.activate([
            rowsStack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 16),
            rowsStack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -16),
            rowsStack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 16),
            rowsStack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -16),
        ])

        billContainer.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: billContainer.topAnchor),
            card.bottomAnchor.constraint(equalTo: billContainer.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: billContainer.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: billContainer.trailingAnchor),
        ])

        proceedButton.setTitle("Proceed to pay · \(rupees(bill.toPay))", for: .normal)
    }

    private func makeLineRow(_ line: CartLine) -> UIView {
        let imageView = UIImageView(image: UIImage(named: line.image))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = BrewColor.neutralFill
        imageView.layer.cornerRadius = BrewCorner.input
        imageView.layer.cornerCurve = .continuous
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: BrewSize.cartThumb).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: BrewSize.cartThumb).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = line.name
        nameLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        let optionsLabel = UILabel()
        optionsLabel.text = line.options
        optionsLabel.apply(.caption, color: BrewColor.textSecondary)
        optionsLabel.numberOfLines = 0
        let textStack = UIStackView(arrangedSubviews: [nameLabel, optionsLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let amountLabel = UILabel()
        amountLabel.text = rupees(line.amount * line.quantity)
        amountLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        amountLabel.numberOfLines = 1
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [imageView, textStack, amountLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    // MARK: - Actions

    @objc private func addAnotherTapped() {
        onAddAnother()
    }

    @objc private func proceedTapped() {
        onProceed()
    }
}
