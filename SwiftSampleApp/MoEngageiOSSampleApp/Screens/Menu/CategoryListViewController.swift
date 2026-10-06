//
//  CategoryListViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Menu/CategoryListView.swift
//  + MenuRow.swift.
//
//  The full list for one part of the menu. On arrival it moves the shared
//  menu state to `category`, which is what reports `Category_Browsed` (from
//  `MenuState.select(_:)`) — this screen does not report anything itself,
//  matching CategoryListView.swift exactly: it relies on `MenuState` and does
//  not duplicate the event.
//
//  The filter pills are presentation only, matching the SwiftUI source: they
//  show a selection but the list is the whole category either way.
//

import UIKit

final class CategoryListViewController: UIViewController {

    private let category: MenuCategory
    private let menuState: MenuState
    private let onBack: () -> Void
    private let onItemSelected: (MenuItem) -> Void
    private let onAdd: (MenuItem) -> Void

    private let items: [MenuItem]
    private var filterPills: [PillButton] = []
    private var activeFilter: String = MenuCatalogue.filters[0]

    private let tableView = UITableView(frame: .zero, style: .plain)

    init(
        category: MenuCategory,
        menuState: MenuState,
        onBack: @escaping () -> Void,
        onItemSelected: @escaping (MenuItem) -> Void,
        onAdd: @escaping (MenuItem) -> Void
    ) {
        self.category = category
        self.menuState = menuState
        self.onBack = onBack
        self.onItemSelected = onItemSelected
        self.onAdd = onAdd
        self.items = MenuCatalogue.byCategory(category)
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
        MoEngageSDKHelper.setInAppContext(.category)
        // Moves the shared menu state to this category, reporting
        // `Category_Browsed` when it is actually a change — see `MenuState`.
        menuState.select(category)
    }

    // MARK: - Layout

    private func buildLayout() {
        let appBar = BrewAppBarView(title: category.sectionTitle, subtitle: Store.pickupLine)
        appBar.onBack = { [weak self] in self?.onBack() }

        let filtersScroll = UIScrollView()
        filtersScroll.showsHorizontalScrollIndicator = false
        filtersScroll.backgroundColor = BrewColor.surface
        filtersScroll.translatesAutoresizingMaskIntoConstraints = false

        let filtersStack = UIStackView()
        filtersStack.axis = .horizontal
        filtersStack.spacing = 8
        filtersStack.isLayoutMarginsRelativeArrangement = true
        filtersStack.layoutMargins = UIEdgeInsets(top: 12, left: BrewSize.screenPadding, bottom: 12, right: BrewSize.screenPadding)
        filtersStack.translatesAutoresizingMaskIntoConstraints = false

        for filter in MenuCatalogue.filters {
            let pill = PillButton(kind: .filter, title: filter)
            pill.setPillSelected(filter == activeFilter)
            pill.addTapAction(for: .touchUpInside) { [weak self] in self?.select(filter: filter) }
            filterPills.append(pill)
            filtersStack.addArrangedSubview(pill)
        }

        filtersScroll.addSubview(filtersStack)
        NSLayoutConstraint.activate([
            filtersStack.topAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.topAnchor),
            filtersStack.bottomAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.bottomAnchor),
            filtersStack.leadingAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.leadingAnchor),
            filtersStack.trailingAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.trailingAnchor),
            filtersStack.heightAnchor.constraint(equalTo: filtersScroll.frameLayoutGuide.heightAnchor),
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = BrewSize.listRowHeight + 12
        tableView.register(MenuRowCell.self, forCellReuseIdentifier: MenuRowCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 28, right: 0)

        let stack = UIStackView(arrangedSubviews: [appBar, filtersScroll, tableView])
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func select(filter: String) {
        activeFilter = filter
        for pill in filterPills {
            pill.setPillSelected(pill.title(for: .normal) == filter)
        }
    }
}

// MARK: - Table view

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuRowCell.reuseIdentifier, for: indexPath) as! MenuRowCell
        let item = items[indexPath.row]
        cell.configure(item: item) { [weak self] in
            self?.onAdd(item)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onItemSelected(items[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        BrewSize.listRowHeight + 12
    }
}

// MARK: - Row cell

/// UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Menu/MenuRow.swift.
private final class MenuRowCell: UITableViewCell {

    static let reuseIdentifier = "MenuRowCell"

    private let card = UIView()
    private let thumbImageView = UIImageView()
    private let nameLabel = UILabel()
    private let noteLabel = UILabel()
    private let priceLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private var onAdd: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        buildLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildLayout() {
        card.backgroundColor = BrewColor.surface
        card.layer.cornerRadius = BrewCorner.card
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = BrewColor.borderSubtle.cgColor
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true

        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.backgroundColor = BrewColor.neutralFill
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.numberOfLines = 1
        noteLabel.numberOfLines = 2
        priceLabel.numberOfLines = 1
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, noteLabel])
        textStack.axis = .vertical
        textStack.spacing = 6

        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(BrewColor.primary, for: .normal)
        addButton.titleLabel?.font = BrewTextStyle.captionMedium.font
        addButton.layer.cornerRadius = BrewCorner.chip
        addButton.layer.cornerCurve = .continuous
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = BrewColor.borderDefault.cgColor
        addButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.setContentHuggingPriority(.required, for: .horizontal)

        let priceRow = UIStackView(arrangedSubviews: [priceLabel, UIView(), addButton])
        priceRow.axis = .horizontal
        priceRow.alignment = .center

        let detailStack = UIStackView(arrangedSubviews: [textStack, UIView(), priceRow])
        detailStack.axis = .vertical
        detailStack.spacing = 8
        detailStack.isLayoutMarginsRelativeArrangement = true
        detailStack.layoutMargins = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        detailStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(thumbImageView)
        card.addSubview(detailStack)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BrewSize.screenPadding),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BrewSize.screenPadding),
            card.heightAnchor.constraint(equalToConstant: BrewSize.listRowHeight),

            thumbImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            thumbImageView.topAnchor.constraint(equalTo: card.topAnchor),
            thumbImageView.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: BrewSize.listRowImageWidth),

            detailStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor),
            detailStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            detailStack.topAnchor.constraint(equalTo: card.topAnchor),
            detailStack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])
    }

    func configure(item: MenuItem, onAdd: @escaping () -> Void) {
        self.onAdd = onAdd
        thumbImageView.image = UIImage(named: item.image)
        nameLabel.text = item.name
        nameLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        noteLabel.text = item.note
        noteLabel.apply(.caption, color: BrewColor.textSecondary)
        priceLabel.text = rupees(item.price)
        priceLabel.apply(.subtitleBold, color: BrewColor.textPrimary)
    }

    @objc private func addTapped() {
        onAdd?()
    }
}
