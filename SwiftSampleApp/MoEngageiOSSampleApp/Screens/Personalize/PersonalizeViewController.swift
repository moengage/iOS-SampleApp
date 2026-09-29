//
//  PersonalizeViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Personalize/PersonalizeView.swift.
//
//  Personalized offers, picked by MoEngage and drawn by the app.
//
//  A fetch answers in one of two shapes and this screen renders both: a
//  campaign whose payload carries offerings, drawn as cards, or one that
//  carries none — nothing configured, no eligible campaign, a user outside the
//  segment, or a campaign deliberately built without any — which falls back to
//  a panel written from the campaign's own copy rather than a blank screen.
//
//  MoEngage moments (all inside `PersonalizeState`, not repeated here): an
//  experience impression once per answer, an offering impression once per card
//  drawn, and an offering click on tap.
//
//  This screen sets no `MoEngageInAppContext` — `PersonalizeView.swift` itself
//  applies no `.inAppContext(_:)` modifier, and `MoEngageInAppContext` carries
//  no dedicated case for it either, so none is invented here.
//

import UIKit
import Combine

final class PersonalizeViewController: UIViewController {

    private let state: PersonalizeState
    private let onBack: () -> Void
    private let onFollow: (URL) -> Void

    private var cancellables = Set<AnyCancellable>()
    private var hasCalledOnAppear = false

    private var tabButtons: [(state: OfferDemoState, button: PillButton)] = []
    private let contentStack = UIStackView()

    init(state: PersonalizeState, onBack: @escaping () -> Void, onFollow: @escaping (URL) -> Void) {
        self.state = state
        self.onBack = onBack
        self.onFollow = onFollow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground

        let header = makeHeader()

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        view.addSubview(header)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: BrewSize.screenPadding),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -BrewSize.screenPadding),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -BrewSize.screenPadding * 2),
        ])

        bindState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Matches the SwiftUI `.task { state.onAppear() }`, which runs once
        // per view identity — here, once per pushed instance of this screen.
        guard !hasCalledOnAppear else { return }
        hasCalledOnAppear = true
        state.onAppear()
    }

    // MARK: - Binding

    private func bindState() {
        Publishers.CombineLatest(
            Publishers.CombineLatest3(state.$demoState, state.$offers, state.$fallbackCopy),
            Publishers.CombineLatest(state.$isLoading, state.$hasFetched)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] first, second in
            let (demoState, offers, fallbackCopy) = first
            let (isLoading, hasFetched) = second
            self?.render(demoState: demoState, offers: offers, fallbackCopy: fallbackCopy, isLoading: isLoading, hasFetched: hasFetched)
        }
        .store(in: &cancellables)
    }

    private func render(
        demoState: OfferDemoState,
        offers: [PersonalizedOffer],
        fallbackCopy: ExperienceCopy,
        isLoading: Bool,
        hasFetched: Bool
    ) {
        for entry in tabButtons {
            entry.button.setPillSelected(entry.state == demoState)
        }

        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if isLoading && !hasFetched {
            // Only before the first answer. A tab switch keeps the previous
            // cards in place rather than flashing a spinner between them.
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = BrewColor.primary
            spinner.startAnimating()
            let wrapper = UIView()
            wrapper.translatesAutoresizingMaskIntoConstraints = false
            spinner.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(spinner)
            NSLayoutConstraint.activate([
                spinner.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 28),
                spinner.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
                spinner.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            ])
            contentStack.addArrangedSubview(wrapper)
        } else if offers.isEmpty {
            contentStack.addArrangedSubview(makeNoOffersPanel(copy: fallbackCopy, demoState: demoState))
        } else {
            let header = UILabel()
            header.text = "Picked for you"
            header.apply(.cardTitle, color: BrewColor.textPrimary)
            header.accessibilityTraits = .header
            contentStack.addArrangedSubview(header)

            for offer in offers {
                contentStack.addArrangedSubview(makeOfferCard(offer))
            }
        }
    }

    // MARK: - Header

    private func makeHeader() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = BrewColor.primaryDarkSurface

        let backButton = BackTileButton()
        backButton.addTapAction(for: .touchUpInside) { [weak self] in self?.onBack() }

        let title = UILabel()
        title.text = "Personalize"
        title.apply(.cardTitle, color: BrewColor.onDarkPrimary)

        let topRow = UIStackView(arrangedSubviews: [backButton, title])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.alignment = .center

        let description = UILabel()
        description.text = "Offers picked for you from your orders and loyalty tier — "
            + "each tab asks MoEngage a different question."
        description.apply(.caption, color: BrewColor.onDarkSecondary)
        description.numberOfLines = 0

        let tabsScroll = UIScrollView()
        tabsScroll.showsHorizontalScrollIndicator = false
        tabsScroll.translatesAutoresizingMaskIntoConstraints = false

        let tabsStack = UIStackView()
        tabsStack.axis = .horizontal
        tabsStack.spacing = 8
        tabsStack.translatesAutoresizingMaskIntoConstraints = false

        tabButtons = OfferDemoState.allCases.map { demo in
            let button = PillButton(kind: .tab, title: demo.label)
            button.setPillSelected(demo == state.demoState)
            button.addTapAction(for: .touchUpInside) { [weak self] in self?.state.select(demo) }
            return (demo, button)
        }
        tabButtons.forEach { tabsStack.addArrangedSubview($0.button) }

        tabsScroll.addSubview(tabsStack)
        NSLayoutConstraint.activate([
            tabsStack.topAnchor.constraint(equalTo: tabsScroll.topAnchor),
            tabsStack.bottomAnchor.constraint(equalTo: tabsScroll.bottomAnchor),
            tabsStack.leadingAnchor.constraint(equalTo: tabsScroll.leadingAnchor),
            tabsStack.trailingAnchor.constraint(equalTo: tabsScroll.trailingAnchor),
            tabsStack.heightAnchor.constraint(equalTo: tabsScroll.heightAnchor),
        ])

        let mainStack = UIStackView(arrangedSubviews: [topRow, description, tabsScroll])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: BrewSize.screenPadding),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -BrewSize.screenPadding),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: BrewSize.screenPadding),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -BrewSize.screenPadding),
        ])

        return container
    }

    // MARK: - Offer card

    /// One offering. Everything but the title is optional, so a partly
    /// authored offering still draws rather than disappearing.
    private func makeOfferCard(_ offer: PersonalizedOffer) -> UIView {
        let thumbnail: UIView
        if let url = offer.imageURL {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = BrewColor.neutralFill
            imageView.layer.cornerRadius = BrewCorner.input
            imageView.layer.cornerCurve = .continuous
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 48),
                imageView.heightAnchor.constraint(equalToConstant: 48),
            ])
            loadImage(from: url, into: imageView)
            thumbnail = imageView
        } else {
            thumbnail = IconTileView(systemImage: "tag", size: 48)
        }

        let titleLabel = UILabel()
        titleLabel.text = offer.title
        titleLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        titleLabel.numberOfLines = 0

        var textViews: [UIView] = [titleLabel]
        if !offer.subtitle.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.text = offer.subtitle
            subtitleLabel.apply(.caption, color: BrewColor.textSecondary)
            subtitleLabel.numberOfLines = 0
            textViews.append(subtitleLabel)
        }
        let textStack = UIStackView(arrangedSubviews: textViews)
        textStack.axis = .vertical
        textStack.spacing = 4

        let ctaLabel = UILabel()
        ctaLabel.text = offer.ctaLabel
        ctaLabel.apply(.captionMedium, color: BrewColor.link)
        ctaLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [thumbnail, textStack, ctaLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        let card = CardContainerView(uniformPadding: 14)
        card.stackView.addArrangedSubview(row)
        card.isUserInteractionEnabled = false

        let tappable = TappableCard(content: card)
        tappable.accessibilityLabel = offer.title
        tappable.accessibilityHint = offer.ctaLabel
        tappable.addTapAction { [weak self] in
            guard let self else { return }
            if let url = self.state.offerTapped(offer) {
                self.onFollow(url)
            }
        }

        return tappable
    }

    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

    // MARK: - No offers

    /// The no-offerings state: nothing configured, nothing eligible, or — on
    /// the Rewards tab — a campaign built with no Offering and no Decision
    /// Policy at all.
    ///
    /// The wording comes from the campaign's own `title`/`message` KV pairs;
    /// the strings below are this app's defaults for when it carries neither,
    /// or never arrived — themed per tab, matching `NoOffersPanel`.
    private func makeNoOffersPanel(copy: ExperienceCopy, demoState: OfferDemoState) -> UIView {
        let isRewards = demoState == .rewards

        let icon = IconTileView(
            systemImage: isRewards ? "gift" : "magnifyingglass",
            size: BrewSize.iconTile,
            background: BrewColor.neutralFill,
            tint: BrewColor.textTertiary
        )

        let defaultTitle = isRewards
            ? "Unlock rewards on your next order"
            : "No personalized offer right now"
        let defaultMessage = isRewards
            ? "Place an order of ₹5,000 or more within 3 months to earn rewards."
            : "Nothing matched for this user — check the menu instead. New offers appear the "
                + "moment a campaign has one for them."

        let titleLabel = UILabel()
        titleLabel.text = copy.title ?? defaultTitle
        titleLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = copy.message ?? defaultMessage
        messageLabel.apply(.caption, color: BrewColor.textSecondary)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center

        let card = CardContainerView(uniformPadding: 18)
        card.stackView.addArrangedSubview(stack)
        return card
    }
}

// MARK: - Tappable card

/// Makes an entire card tappable, mirroring a SwiftUI `Button` wrapping
/// `BrewCard` with `.buttonStyle(.plain)`.
private final class TappableCard: UIControl {

    init(content: UIView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.7 : 1 }
    }
}
