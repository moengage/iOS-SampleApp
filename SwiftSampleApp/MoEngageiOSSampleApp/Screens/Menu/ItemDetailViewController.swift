//
//  ItemDetailViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Menu/ItemDetailView.swift.
//
//  One item, configured and added to the order. Price is derived, never
//  stored — every control recomputes the footer's total.
//
//  MoEngage moments, matching ItemDetailView.swift's timing exactly:
//  - `setInAppContext(.item)` + `trackItemViewed(_:)` + `showInApp()` on
//    every arrival (`viewWillAppear`, mirroring `.onAppear`). Unlike the menu,
//    which asks once per session, an item asks every time.
//  - `Add_To_Cart` is deliberately NOT reported here: ItemDetailView.swift
//    itself never calls `trackAddToCart` — it only hands the configured
//    `ItemSelection` to `onAdd`. `MainTabBarController`'s destination builder
//    (matching `MainTabView.swift`'s `.item` case) is what calls
//    `MoEngageSDKHelper.trackAddToCart(item:selection:)`, immediately before
//    putting the line in the cart. Reporting it again here would double-count
//    every add.
//

import UIKit

final class ItemDetailViewController: UIViewController {

    private let item: MenuItem
    private let onBack: () -> Void
    private let onAdd: (ItemSelection) -> Void

    private var sizeIndex = 1
    private var milkIndex = 1
    private var quantity = 1
    private var selectedAddOnIDs: Set<String> = []

    private var sizeCards: [SelectCardButton] = []
    private var milkPills: [PillButton] = []
    private var addOnRows: [AddOnRowView] = []

    private let quantityLabel = UILabel()
    private let addButton = BrewPrimaryButton()

    private var size: SizeOption { MenuCatalogue.sizes[sizeIndex] }
    private var milk: MilkOption { MenuCatalogue.milks[milkIndex] }
    private var chosenAddOns: [AddOn] {
        MenuCatalogue.addOns.filter { selectedAddOnIDs.contains($0.itemID) }
    }
    private var total: Int {
        let unit = item.price + size.surcharge + milk.surcharge
        let addOns = chosenAddOns.reduce(0) { $0 + $1.price }
        return (unit + addOns) * quantity
    }

    init(item: MenuItem, onBack: @escaping () -> Void, onAdd: @escaping (ItemSelection) -> Void) {
        self.item = item
        self.onBack = onBack
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground
        buildLayout()
        refreshTotal()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MoEngageSDKHelper.setInAppContext(.item)
        MoEngageSDKHelper.trackItemViewed(item)
        // Asked for on every arrival — an item is a deliberate, specific
        // choice, unlike the menu's once-per-session rule.
        MoEngageSDKHelper.showInApp()
    }

    // MARK: - Layout

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Hero.
        let heroImage = UIImageView(image: UIImage(named: item.image))
        heroImage.contentMode = .scaleAspectFill
        heroImage.clipsToBounds = true
        heroImage.backgroundColor = BrewColor.neutralFill
        heroImage.translatesAutoresizingMaskIntoConstraints = false
        heroImage.heightAnchor.constraint(equalToConstant: BrewSize.heroImageHeight).isActive = true

        let backButton = UIButton(type: .system)
        backButton.setImage(
            UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)),
            for: .normal
        )
        backButton.tintColor = BrewColor.textPrimary
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        backButton.layer.cornerRadius = BrewSize.heroBackButton / 2
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.accessibilityLabel = "Back"

        heroImage.isUserInteractionEnabled = true
        heroImage.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: BrewSize.heroBackButton),
            backButton.heightAnchor.constraint(equalToConstant: BrewSize.heroBackButton),
            backButton.topAnchor.constraint(equalTo: heroImage.topAnchor, constant: 14),
            backButton.leadingAnchor.constraint(equalTo: heroImage.leadingAnchor, constant: 14),
        ])

        // Name + price + note.
        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.apply(.heroHeader, color: BrewColor.textPrimary)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let priceLabel = UILabel()
        priceLabel.text = rupees(item.price)
        priceLabel.apply(.titleBold, color: BrewColor.textPrimary)
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)

        let nameRow = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        nameRow.axis = .horizontal
        nameRow.alignment = .firstBaseline
        nameRow.spacing = 12

        let noteLabel = UILabel()
        noteLabel.text = item.note
        noteLabel.apply(.support, color: BrewColor.textSecondary)
        noteLabel.numberOfLines = 0

        let headerStack = UIStackView(arrangedSubviews: [nameRow, noteLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8

        // Size.
        let sizeRow = UIStackView()
        sizeRow.axis = .horizontal
        sizeRow.spacing = 8
        sizeRow.distribution = .fillEqually
        for (index, option) in MenuCatalogue.sizes.enumerated() {
            let card = SelectCardButton(title: option.label, subtitle: option.volume + surcharge(option.surcharge))
            card.setSelected(index == sizeIndex)
            card.addTapAction(for: .touchUpInside) { [weak self] in self?.selectSize(index) }
            sizeCards.append(card)
            sizeRow.addArrangedSubview(card)
        }
        let sizeSection = makeOptionSection(title: "Size", content: sizeRow)

        // Milk.
        let milkScroll = UIScrollView()
        milkScroll.showsHorizontalScrollIndicator = false
        milkScroll.translatesAutoresizingMaskIntoConstraints = false
        let milkStack = UIStackView()
        milkStack.axis = .horizontal
        milkStack.spacing = 8
        milkStack.translatesAutoresizingMaskIntoConstraints = false
        for (index, option) in MenuCatalogue.milks.enumerated() {
            let pill = PillButton(kind: .select, title: option.label + surcharge(option.surcharge))
            pill.setPillSelected(index == milkIndex)
            pill.addTapAction(for: .touchUpInside) { [weak self] in self?.selectMilk(index) }
            milkPills.append(pill)
            milkStack.addArrangedSubview(pill)
        }
        milkScroll.addSubview(milkStack)
        NSLayoutConstraint.activate([
            milkStack.topAnchor.constraint(equalTo: milkScroll.contentLayoutGuide.topAnchor),
            milkStack.bottomAnchor.constraint(equalTo: milkScroll.contentLayoutGuide.bottomAnchor),
            milkStack.leadingAnchor.constraint(equalTo: milkScroll.contentLayoutGuide.leadingAnchor),
            milkStack.trailingAnchor.constraint(equalTo: milkScroll.contentLayoutGuide.trailingAnchor),
            milkStack.heightAnchor.constraint(equalTo: milkScroll.frameLayoutGuide.heightAnchor),
        ])
        let milkSection = makeOptionSection(title: "Milk", content: milkScroll)

        // Add-ons.
        let addOnsStack = UIStackView()
        addOnsStack.axis = .vertical
        addOnsStack.spacing = 8
        for addOn in MenuCatalogue.addOns {
            let row = AddOnRowView(addOn: addOn)
            row.onToggle = { [weak self] in self?.toggle(addOn) }
            addOnRows.append(row)
            addOnsStack.addArrangedSubview(row)
        }
        let addOnsSection = makeOptionSection(title: "Make it a meal", content: addOnsStack)

        let detailsStack = UIStackView(arrangedSubviews: [headerStack, sizeSection, milkSection, addOnsSection])
        detailsStack.axis = .vertical
        detailsStack.spacing = 18
        detailsStack.isLayoutMarginsRelativeArrangement = true
        detailsStack.layoutMargins = UIEdgeInsets(
            top: BrewSize.screenPadding, left: BrewSize.screenPadding,
            bottom: BrewSize.screenPadding, right: BrewSize.screenPadding
        )
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [heroImage, detailsStack])
        contentStack.axis = .vertical
        contentStack.spacing = 0
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

        let decrementButton = UIButton(type: .system)
        decrementButton.setTitle("−", for: .normal)
        decrementButton.titleLabel?.font = BrewTextStyle.cardTitle.font
        decrementButton.setTitleColor(BrewColor.textPrimary, for: .normal)
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        decrementButton.widthAnchor.constraint(equalToConstant: BrewSize.touchTarget).isActive = true
        decrementButton.accessibilityLabel = "Decrease quantity"

        let incrementButton = UIButton(type: .system)
        incrementButton.setTitle("+", for: .normal)
        incrementButton.titleLabel?.font = BrewTextStyle.cardTitle.font
        incrementButton.setTitleColor(BrewColor.textPrimary, for: .normal)
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        incrementButton.widthAnchor.constraint(equalToConstant: BrewSize.touchTarget).isActive = true
        incrementButton.accessibilityLabel = "Increase quantity"

        quantityLabel.textAlignment = .center
        quantityLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stepperStack = UIStackView(arrangedSubviews: [decrementButton, quantityLabel, incrementButton])
        stepperStack.axis = .horizontal
        stepperStack.alignment = .center
        stepperStack.layer.borderWidth = 1
        stepperStack.layer.borderColor = BrewColor.borderDefault.cgColor
        stepperStack.layer.cornerRadius = BrewCorner.input
        stepperStack.layer.cornerCurve = .continuous
        stepperStack.heightAnchor.constraint(equalToConstant: BrewSize.buttonHeight).isActive = true

        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let footerRow = UIStackView(arrangedSubviews: [stepperStack, addButton])
        footerRow.axis = .horizontal
        footerRow.spacing = 12
        footerRow.alignment = .center
        footerRow.translatesAutoresizingMaskIntoConstraints = false

        footer.contentContainer.addSubview(footerRow)
        NSLayoutConstraint.activate([
            footerRow.topAnchor.constraint(equalTo: footer.contentContainer.topAnchor),
            footerRow.bottomAnchor.constraint(equalTo: footer.contentContainer.bottomAnchor),
            footerRow.leadingAnchor.constraint(equalTo: footer.contentContainer.leadingAnchor),
            footerRow.trailingAnchor.constraint(equalTo: footer.contentContainer.trailingAnchor),
        ])

        let root = UIStackView(arrangedSubviews: [scrollView, footer])
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

    private func makeOptionSection(title: String, content: UIView) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.apply(.cardTitle, color: BrewColor.textPrimary)

        let stack = UIStackView(arrangedSubviews: [titleLabel, content])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    // MARK: - Actions

    @objc private func backTapped() {
        onBack()
    }

    private func selectSize(_ index: Int) {
        sizeIndex = index
        for (i, card) in sizeCards.enumerated() {
            card.setSelected(i == index)
        }
        refreshTotal()
    }

    private func selectMilk(_ index: Int) {
        milkIndex = index
        for (i, pill) in milkPills.enumerated() {
            pill.setPillSelected(i == index)
        }
        refreshTotal()
    }

    private func toggle(_ addOn: AddOn) {
        if selectedAddOnIDs.contains(addOn.itemID) {
            selectedAddOnIDs.remove(addOn.itemID)
        } else {
            selectedAddOnIDs.insert(addOn.itemID)
        }
        if let row = addOnRows.first(where: { $0.addOnID == addOn.itemID }) {
            row.setChecked(selectedAddOnIDs.contains(addOn.itemID))
        }
        refreshTotal()
    }

    @objc private func decrementTapped() {
        quantity = max(1, quantity - 1)
        refreshTotal()
    }

    @objc private func incrementTapped() {
        quantity += 1
        refreshTotal()
    }

    private func refreshTotal() {
        quantityLabel.text = "\(quantity)"
        quantityLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        addButton.setTitle("Add · \(rupees(total))", for: .normal)
    }

    @objc private func addTapped() {
        onAdd(
            ItemSelection(
                size: size.label,
                milk: milk.label,
                addOns: chosenAddOns.map(\.label),
                quantity: quantity,
                amount: total
            )
        )
    }
}

// MARK: - Add-on row

private final class AddOnRowView: UIControl {

    let addOnID: String
    var onToggle: (() -> Void)?

    private let checkbox = UIView()
    private let checkImage = UIImageView()
    private let label = UILabel()
    private let priceLabel = UILabel()

    init(addOn: AddOn) {
        self.addOnID = addOn.itemID
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.surface
        layer.cornerRadius = BrewCorner.button
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = BrewColor.borderSubtle.cgColor

        checkbox.layer.cornerRadius = BrewCorner.checkbox
        checkbox.layer.cornerCurve = .continuous
        checkbox.layer.borderWidth = 1
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.isUserInteractionEnabled = false

        checkImage.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        checkImage.tintColor = BrewColor.onDarkPrimary
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        checkImage.isUserInteractionEnabled = false
        checkbox.addSubview(checkImage)
        NSLayoutConstraint.activate([
            checkbox.widthAnchor.constraint(equalToConstant: BrewSize.checkbox),
            checkbox.heightAnchor.constraint(equalToConstant: BrewSize.checkbox),
            checkImage.centerXAnchor.constraint(equalTo: checkbox.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),
        ])

        label.text = addOn.label
        label.apply(.body, color: BrewColor.textPrimary)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        priceLabel.text = rupees(addOn.price)
        priceLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        priceLabel.numberOfLines = 1
        priceLabel.isUserInteractionEnabled = false
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [checkbox, label, priceLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        setChecked(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(_ checked: Bool) {
        checkbox.backgroundColor = checked ? BrewColor.primary : .clear
        checkbox.layer.borderColor = (checked ? BrewColor.primary : BrewColor.borderDefault).cgColor
        checkImage.isHidden = !checked
        accessibilityTraits = checked ? [.button, .selected] : .button
    }

    @objc private func tapped() {
        onToggle?()
    }
}
