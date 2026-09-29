//
//  MenuHomeViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Menu/MenuHomeView.swift +
//  MenuHeader.swift + MenuRow.swift + SelfHandledPromoCard.swift.
//
//  The menu tab's home: the header, the self-handled promo card, the featured
//  grid and the user's usual order. One scroll view, header included — the
//  header scrolls away with the rest, matching the SwiftUI source.
//
//  MoEngage moments, matching MenuHomeView.swift's timing exactly:
//  - `setInAppContext(.menu)` + `trackMenuViewed(_:)` on every arrival
//    (`viewWillAppear`, mirroring `.onAppear`).
//  - `requestSelfHandledPromoOnce()` on every arrival, `stopListeningFor...`
//    on every departure (`viewWillAppear`/`viewWillDisappear`, mirroring
//    `.onAppear`/`.onDisappear`).
//  - `requestNativeInAppOnce()` — async, once per session — is asked for after
//    `setInAppContext` has scoped eligibility, exactly as the SwiftUI source's
//    comment specifies, wrapped in a `Task`.
//  - `inbox.refreshUnreadCount()` on every arrival, per the MainTabView
//    wiring ("re-read whenever the menu is returned to").
//

import UIKit
import Combine

final class MenuHomeViewController: UIViewController {

    private let menuState: MenuState
    private let inbox: InboxState
    private let onItemSelected: (MenuItem) -> Void
    private let onFullMenu: (MenuCategory) -> Void
    private let onReorderUsual: () -> Void
    private let onInboxTapped: () -> Void
    private let onPromoOpened: (URL) -> Void

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let greetingLabel = UILabel()
    private let nameLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let bellBadgeLabel = UILabel()

    private let searchPlaceholderLabel = UILabel()
    private let searchMetaLabel = UILabel()

    private let categoryPillsStack = UIStackView()
    private var categoryPills: [MenuCategory: PillButton] = [:]

    private let promoContainer = UIView()
    private var promoCardView: SelfHandledPromoCardView?

    private let sectionHeaderContainer = UIView()
    private var sectionHeader: SectionHeaderView?

    private let featuredGrid = UIStackView()

    private let usualSummaryLabel = UILabel()
    private let usualDetailLabel = UILabel()

    init(
        menuState: MenuState,
        inbox: InboxState,
        onItemSelected: @escaping (MenuItem) -> Void,
        onFullMenu: @escaping (MenuCategory) -> Void,
        onReorderUsual: @escaping () -> Void,
        onInboxTapped: @escaping () -> Void,
        onPromoOpened: @escaping (URL) -> Void
    ) {
        self.menuState = menuState
        self.inbox = inbox
        self.onItemSelected = onItemSelected
        self.onFullMenu = onFullMenu
        self.onReorderUsual = onReorderUsual
        self.onInboxTapped = onInboxTapped
        self.onPromoOpened = onPromoOpened
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground
        buildLayout()
        bind()
        refreshCategoryPills()
        refreshPromo()
        refreshSection()
        refreshFeatured()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inbox.refreshUnreadCount()

        MoEngageSDKHelper.setInAppContext(.menu)
        MoEngageSDKHelper.trackMenuViewed(menuState.category)
        menuState.requestSelfHandledPromoOnce()

        // Runs after `setInAppContext` has scoped eligibility to the menu, so
        // the campaign asked for below is matched against the right context.
        Task { await menuState.requestNativeInAppOnce() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        menuState.stopListeningForSelfHandledPromo()
    }

    // MARK: - Binding

    private func bind() {
        inbox.$unreadCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.updateBadge(count)
            }
            .store(in: &cancellables)

        menuState.$category
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.refreshCategoryPills()
                self.refreshSection()
                self.refreshFeatured()
            }
            .store(in: &cancellables)

        menuState.$promo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshPromo()
            }
            .store(in: &cancellables)
    }

    // MARK: - Layout

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

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

        contentStack.addArrangedSubview(makeHeader())

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 22
        body.isLayoutMarginsRelativeArrangement = true
        body.layoutMargins = UIEdgeInsets(top: 18, left: BrewSize.screenPadding, bottom: 24, right: BrewSize.screenPadding)

        body.addArrangedSubview(promoContainer)
        body.addArrangedSubview(sectionHeaderContainer)

        featuredGrid.axis = .vertical
        featuredGrid.spacing = 12
        body.addArrangedSubview(featuredGrid)

        body.addArrangedSubview(makeUsualCard())

        contentStack.addArrangedSubview(body)
    }

    // MARK: - Header

    private func makeHeader() -> UIView {
        let container = UIView()
        container.backgroundColor = BrewColor.surface

        greetingLabel.text = "Good morning,"
        greetingLabel.apply(.caption, color: BrewColor.textSecondary)

        nameLabel.text = DemoUser.name
        nameLabel.apply(.titleBold, color: BrewColor.textPrimary)

        let greetingStack = UIStackView(arrangedSubviews: [greetingLabel, nameLabel])
        greetingStack.axis = .vertical
        greetingStack.spacing = 2
        greetingStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        bellButton.setImage(
            UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)),
            for: .normal
        )
        bellButton.tintColor = BrewColor.textPrimary
        bellButton.backgroundColor = BrewColor.componentFill
        bellButton.layer.cornerRadius = BrewSize.bellButton / 2
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        bellButton.accessibilityLabel = "Notifications"

        bellBadgeLabel.apply(.microMedium, color: BrewColor.onDarkPrimary)
        bellBadgeLabel.textAlignment = .center
        bellBadgeLabel.backgroundColor = BrewColor.unreadBadge
        bellBadgeLabel.layer.cornerRadius = BrewSize.badge / 2
        bellBadgeLabel.clipsToBounds = true
        bellBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        bellBadgeLabel.isHidden = true

        let bellContainer = UIView()
        bellContainer.translatesAutoresizingMaskIntoConstraints = false
        bellContainer.addSubview(bellButton)
        bellContainer.addSubview(bellBadgeLabel)
        NSLayoutConstraint.activate([
            bellButton.topAnchor.constraint(equalTo: bellContainer.topAnchor),
            bellButton.leadingAnchor.constraint(equalTo: bellContainer.leadingAnchor),
            bellButton.trailingAnchor.constraint(equalTo: bellContainer.trailingAnchor),
            bellButton.bottomAnchor.constraint(equalTo: bellContainer.bottomAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: BrewSize.bellButton),
            bellButton.heightAnchor.constraint(equalToConstant: BrewSize.bellButton),

            bellBadgeLabel.widthAnchor.constraint(equalToConstant: BrewSize.badge),
            bellBadgeLabel.heightAnchor.constraint(equalToConstant: BrewSize.badge),
            bellBadgeLabel.centerXAnchor.constraint(equalTo: bellButton.trailingAnchor, constant: -3),
            bellBadgeLabel.centerYAnchor.constraint(equalTo: bellButton.topAnchor, constant: 3),
        ])

        let greetingRow = UIStackView(arrangedSubviews: [greetingStack, bellContainer])
        greetingRow.axis = .horizontal
        greetingRow.alignment = .center
        greetingRow.spacing = 12

        // Store strip.
        let storeIcon = UIImageView(image: UIImage(systemName: "building.2"))
        storeIcon.tintColor = BrewColor.primary
        storeIcon.setContentHuggingPriority(.required, for: .horizontal)

        let addressLabel = UILabel()
        addressLabel.text = Store.address
        addressLabel.apply(.supportMedium, color: BrewColor.textPrimary)
        let hoursLabel = UILabel()
        hoursLabel.text = Store.hours
        hoursLabel.apply(.micro, color: BrewColor.textSecondary)
        let storeTextStack = UIStackView(arrangedSubviews: [addressLabel, hoursLabel])
        storeTextStack.axis = .vertical
        storeTextStack.spacing = 2
        storeTextStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let changeLabel = UILabel()
        changeLabel.text = "Change"
        changeLabel.apply(.captionMedium, color: BrewColor.link)
        changeLabel.setContentHuggingPriority(.required, for: .horizontal)

        let storeStrip = UIStackView(arrangedSubviews: [storeIcon, storeTextStack, changeLabel])
        storeStrip.axis = .horizontal
        storeStrip.alignment = .center
        storeStrip.spacing = 10
        storeStrip.isLayoutMarginsRelativeArrangement = true
        storeStrip.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        storeStrip.backgroundColor = BrewColor.neutralFill
        storeStrip.layer.cornerRadius = BrewCorner.button
        storeStrip.layer.cornerCurve = .continuous
        storeStrip.clipsToBounds = true

        // Search field (presentation only).
        searchPlaceholderLabel.apply(.body, color: BrewColor.textTertiary)
        searchMetaLabel.apply(.caption, color: BrewColor.textSecondary)
        searchMetaLabel.setContentHuggingPriority(.required, for: .horizontal)
        let searchRow = UIStackView(arrangedSubviews: [searchPlaceholderLabel, searchMetaLabel])
        searchRow.axis = .horizontal
        searchRow.alignment = .center
        searchRow.isLayoutMarginsRelativeArrangement = true
        searchRow.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        searchRow.backgroundColor = BrewColor.componentFill
        searchRow.layer.cornerRadius = BrewCorner.button
        searchRow.layer.cornerCurve = .continuous
        searchRow.clipsToBounds = true
        searchRow.heightAnchor.constraint(equalToConstant: BrewSize.searchHeight).isActive = true

        // Category pills.
        categoryPillsStack.axis = .horizontal
        categoryPillsStack.spacing = 8
        let pillsScroll = UIScrollView()
        pillsScroll.showsHorizontalScrollIndicator = false
        pillsScroll.translatesAutoresizingMaskIntoConstraints = false
        categoryPillsStack.translatesAutoresizingMaskIntoConstraints = false
        pillsScroll.addSubview(categoryPillsStack)
        NSLayoutConstraint.activate([
            categoryPillsStack.topAnchor.constraint(equalTo: pillsScroll.contentLayoutGuide.topAnchor),
            categoryPillsStack.bottomAnchor.constraint(equalTo: pillsScroll.contentLayoutGuide.bottomAnchor),
            categoryPillsStack.leadingAnchor.constraint(equalTo: pillsScroll.contentLayoutGuide.leadingAnchor),
            categoryPillsStack.trailingAnchor.constraint(equalTo: pillsScroll.contentLayoutGuide.trailingAnchor),
            categoryPillsStack.heightAnchor.constraint(equalTo: pillsScroll.frameLayoutGuide.heightAnchor),
        ])
        for category in MenuCategory.allCases {
            let pill = PillButton(kind: .tab, title: category.label)
            pill.addTapAction(for: .touchUpInside) { [weak self] in self?.menuState.select(category) }
            categoryPills[category] = pill
            categoryPillsStack.addArrangedSubview(pill)
        }

        let headerStack = UIStackView(arrangedSubviews: [greetingRow, storeStrip, searchRow, pillsScroll])
        headerStack.axis = .vertical
        headerStack.spacing = 14
        headerStack.isLayoutMarginsRelativeArrangement = true
        headerStack.layoutMargins = UIEdgeInsets(top: 18, left: BrewSize.screenPadding, bottom: 14, right: BrewSize.screenPadding)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let divider = ThinDividerView()

        container.addSubview(headerStack)
        container.addSubview(divider)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: container.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: divider.topAnchor),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    private func makeUsualCard() -> UIView {
        let card = BrewCardView()

        let icon = IconTileView(systemImage: "cup.and.saucer.fill")

        usualSummaryLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        usualDetailLabel.apply(.caption, color: BrewColor.textSecondary)
        let textStack = UIStackView(arrangedSubviews: [usualSummaryLabel, usualDetailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let reorderButton = UIButton(type: .system)
        reorderButton.setTitle("Reorder", for: .normal)
        reorderButton.setTitleColor(BrewColor.link, for: .normal)
        reorderButton.titleLabel?.font = BrewTextStyle.supportMedium.font
        reorderButton.addTarget(self, action: #selector(reorderTapped), for: .touchUpInside)
        reorderButton.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [icon, textStack, reorderButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false

        card.contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -14),
        ])

        usualSummaryLabel.text = MenuCatalogue.usual.summary
        usualSummaryLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        usualDetailLabel.text = MenuCatalogue.usual.detail
        usualDetailLabel.apply(.caption, color: BrewColor.textSecondary)

        return card
    }

    // MARK: - Refresh

    private func updateBadge(_ count: Int) {
        bellBadgeLabel.isHidden = count <= 0
        bellBadgeLabel.text = "\(count)"
        bellBadgeLabel.apply(.microMedium, color: BrewColor.onDarkPrimary)
        bellButton.accessibilityValue = count > 0 ? "\(count) unread" : "No unread messages"
    }

    private func refreshCategoryPills() {
        for (category, pill) in categoryPills {
            pill.setPillSelected(category == menuState.category)
        }
        searchPlaceholderLabel.text = menuState.category.searchPlaceholder
        searchMetaLabel.text = menuState.category.searchMeta
    }

    private func refreshSection() {
        sectionHeaderContainer.subviews.forEach { $0.removeFromSuperview() }
        let header = SectionHeaderView(
            title: menuState.category.sectionTitle,
            actionLabel: "Full menu",
            action: { [weak self] in
                guard let self else { return }
                self.onFullMenu(self.menuState.category)
            }
        )
        sectionHeader = header
        sectionHeaderContainer.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: sectionHeaderContainer.topAnchor),
            header.bottomAnchor.constraint(equalTo: sectionHeaderContainer.bottomAnchor),
            header.leadingAnchor.constraint(equalTo: sectionHeaderContainer.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: sectionHeaderContainer.trailingAnchor),
        ])
    }

    private func refreshFeatured() {
        featuredGrid.arrangedSubviews.forEach {
            featuredGrid.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let items = MenuCatalogue.featured(menuState.category)
        // Two-up rows, matching the adaptive grid's usual result on a phone.
        var index = 0
        while index < items.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually

            let first = items[index]
            let firstCard = FeaturedCardView(item: first)
            firstCard.addTapAction(for: .touchUpInside) { [weak self] in self?.onItemSelected(first) }
            rowStack.addArrangedSubview(firstCard)

            if index + 1 < items.count {
                let second = items[index + 1]
                let secondCard = FeaturedCardView(item: second)
                secondCard.addTapAction(for: .touchUpInside) { [weak self] in self?.onItemSelected(second) }
                rowStack.addArrangedSubview(secondCard)
            } else {
                let spacer = UIView()
                rowStack.addArrangedSubview(spacer)
            }

            featuredGrid.addArrangedSubview(rowStack)
            index += 2
        }
    }

    private func refreshPromo() {
        promoContainer.subviews.forEach { $0.removeFromSuperview() }
        promoCardView = nil

        guard let promo = menuState.promo else {
            promoContainer.isHidden = true
            return
        }

        promoContainer.isHidden = false
        let card = SelfHandledPromoCardView(payload: promo.payload)
        card.addTapAction { [weak self] in
            guard let self, let url = self.menuState.promoTapped() else { return }
            self.onPromoOpened(url)
        }
        card.onDismiss = { [weak self] in
            self?.menuState.dismissPromo()
        }
        promoCardView = card
        promoContainer.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: promoContainer.topAnchor),
            card.bottomAnchor.constraint(equalTo: promoContainer.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: promoContainer.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: promoContainer.trailingAnchor),
        ])

        // Reports the impression the moment the card is actually drawn, not
        // when the campaign was merely fetched, matching
        // SelfHandledPromoCard.swift's `.onAppear`.
        MoEngageSDKHelper.trackSelfHandledShown(promo)
    }

    // MARK: - Actions

    @objc private func bellTapped() {
        onInboxTapped()
    }

    @objc private func reorderTapped() {
        onReorderUsual()
    }
}
