//
//  ProfileViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Profile/ProfileView.swift.
//
//  Who the user is, and what they have allowed.
//
//  Most of this screen is about the MoEngage integration rather than about the
//  user: what notifications are permitted, what location is permitted, whether
//  fences are being watched, and the way into the personalized offers MoEngage
//  has picked. That is the point of the screen in a sample app — it shows the
//  integration's state rather than hiding it.
//
//  MoEngage moment: signing out invalidates the identity, so everything
//  tracked afterwards belongs to a new anonymous user. No events are reported
//  from this screen.
//

import UIKit
import Combine
import CoreLocation

final class ProfileViewController: UIViewController {

    private let state: ProfileState
    private let onPersonalize: () -> Void
    private let onLogout: () -> Void

    private var cancellables = Set<AnyCancellable>()

    // Live rows.
    private let pushCaptionLabel = UILabel()
    private let pushToggle = UISwitch()
    private let offersToggle = UISwitch()
    private let marketingToggle = UISwitch()
    private let locationCaptionLabel = UILabel()
    private let locationActionButton = UIButton(type: .system)
    private let locationValueLabel = UILabel()
    private let preciseCaptionLabel = UILabel()
    private let preciseActionButton = UIButton(type: .system)
    private let preciseValueLabel = UILabel()
    private let geofenceValueLabel = UILabel()

    init(state: ProfileState, onPersonalize: @escaping () -> Void, onLogout: @escaping () -> Void) {
        self.state = state
        self.onPersonalize = onPersonalize
        self.onLogout = onLogout
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground

        let header = makeHeader()

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        let contentStack = UIStackView(arrangedSubviews: [
            makeTasteProfileSection(),
            makePersonalizeSection(),
            makeNotificationsSection(),
            makeLocationSection(),
            makeLogoutButton(),
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 18
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

        // Both permissions can be changed in Settings while the app is away,
        // so what is displayed is re-read rather than remembered.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await state.refresh() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MoEngageSDKHelper.setInAppContext(.profile)
    }

    @objc private func appDidBecomeActive() {
        Task { await state.refresh() }
    }

    // MARK: - Binding

    private func bindState() {
        Publishers.CombineLatest3(state.$isPushGranted, state.$isPushBlocked, state.$hasAnsweredPush)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted, blocked, _ in
                self?.updateNotifications(isGranted: granted, isBlocked: blocked)
            }
            .store(in: &cancellables)

        state.$isOffersOptedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in self?.offersToggle.setOn(isOn, animated: true) }
            .store(in: &cancellables)

        state.$isMarketingOptedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in self?.marketingToggle.setOn(isOn, animated: true) }
            .store(in: &cancellables)

        Publishers.CombineLatest3(state.$locationStatus, state.$isPreciseLocation, state.$isMonitoringGeofences)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status, precise, monitoring in
                self?.updateLocation(status: status, isPrecise: precise, isMonitoring: monitoring)
            }
            .store(in: &cancellables)
    }

    private func updateNotifications(isGranted: Bool, isBlocked: Bool) {
        pushCaptionLabel.text = pushStatusLine(isGranted: isGranted, isBlocked: isBlocked)
        pushCaptionLabel.apply(.caption, color: isBlocked ? BrewColor.unreadBadge : BrewColor.textSecondary)
        // Shown, not operated. No app can switch notifications on or off —
        // only the OS can — so the switch reports the answer.
        pushToggle.setOn(isGranted, animated: true)
    }

    private func pushStatusLine(isGranted: Bool, isBlocked: Bool) -> String {
        if isBlocked { return "Blocked at OS level · tap to open settings" }
        if isGranted { return "Allowed · token registered" }
        return "Not requested yet · tap to allow"
    }

    private func updateLocation(status: CLAuthorizationStatus, isPrecise: Bool, isMonitoring: Bool) {
        locationCaptionLabel.text = locationCaption(for: status)

        if let action = locationAction(for: status) {
            locationActionButton.setTitle(action, for: .normal)
            locationActionButton.isHidden = false
            locationValueLabel.isHidden = true
        } else {
            locationActionButton.isHidden = true
            locationValueLabel.isHidden = false
            locationValueLabel.text = locationValue(for: status)
            locationValueLabel.apply(
                .captionMedium,
                color: status == .authorizedAlways ? BrewColor.successText : BrewColor.textTertiary
            )
        }

        // Approximate location stops iOS monitoring regions altogether, and the
        // SDK does not check for it, so this row is the only place it shows.
        preciseCaptionLabel.text = isPrecise ? "Needed for fences to fire" : "Off: iOS won't monitor fences at all"

        // Only Settings can turn precise location back on. Offered once location
        // is granted, since before that there is no precision to change.
        let isGranted = status == .authorizedAlways || status == .authorizedWhenInUse
        preciseActionButton.isHidden = isPrecise || !isGranted
        preciseValueLabel.isHidden = !preciseActionButton.isHidden
        preciseValueLabel.text = isPrecise ? "On" : "Off"
        preciseValueLabel.apply(.captionMedium, color: isPrecise ? BrewColor.successText : BrewColor.textTertiary)

        geofenceValueLabel.text = isMonitoring ? "Active" : "Inactive"
        geofenceValueLabel.apply(.bodyMedium, color: isMonitoring ? BrewColor.successText : BrewColor.textTertiary)
    }

    /// iOS asks once and answers on two axes: when location may be used, and
    /// how precisely. The caption names which grant is in play.
    private func locationCaption(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways: return "Fences can fire with the app closed"
        case .authorizedWhenInUse: return "Fences fire only while the app is open"
        case .denied, .restricted: return "Changeable in Settings only"
        default: return "Needed before fences can be watched"
        }
    }

    private func locationValue(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "While using"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        default: return "Not requested"
        }
    }

    /// The next step available, or `nil` when there is nothing left to ask.
    private func locationAction(for status: CLAuthorizationStatus) -> String? {
        switch status {
        case .notDetermined: return "Allow"
        case .authorizedWhenInUse: return "Allow always"
        case .denied, .restricted: return "Open settings"
        default: return nil
        }
    }

    // MARK: - Header

    private func makeHeader() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = BrewColor.surface

        let avatar = UIView()
        avatar.backgroundColor = BrewColor.primary
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = BrewSize.avatar / 2
        avatar.isAccessibilityElement = false

        let initialsLabel = UILabel()
        initialsLabel.text = DemoUser.initials
        initialsLabel.apply(.initials, color: BrewColor.onDarkPrimary)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(initialsLabel)

        let nameLabel = UILabel()
        nameLabel.text = DemoUser.name
        nameLabel.apply(.titleBoldSmall, color: BrewColor.textPrimary)

        let phoneLabel = UILabel()
        phoneLabel.text = DemoUser.phone
        phoneLabel.apply(.support, color: BrewColor.textSecondary)

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, phoneLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 4

        let tierPill = ProfilePillLabel(text: DemoUser.tier, background: BrewColor.warmTint, textColor: BrewColor.warmIcon)
        tierPill.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [avatar, nameStack, tierPill])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: BrewSize.avatar),
            avatar.heightAnchor.constraint(equalToConstant: BrewSize.avatar),
            initialsLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),

            row.topAnchor.constraint(equalTo: container.topAnchor, constant: BrewSize.screenPadding),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -BrewSize.screenPadding),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: BrewSize.screenPadding),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -BrewSize.screenPadding),
        ])

        return container
    }

    // MARK: - Taste profile

    private func makeTasteProfileSection() -> UIView {
        let taste = DemoUser.taste
        let rows: [(String, String)] = [
            ("Favourite drink", taste.favouriteDrink),
            ("Milk", taste.milk),
            ("Sweetness", taste.sweetness),
            ("Home store", taste.homeStore),
            ("Birthday", taste.birthday),
        ]

        let card = CardContainerView()
        for (index, row) in rows.enumerated() {
            if index > 0 {
                card.stackView.addArrangedSubview(ThinDividerView())
            }
            let detail = DetailRowView(label: row.0, value: row.1)
            card.stackView.addArrangedSubview(padded(detail, horizontal: 16, vertical: 14))
        }

        return section(title: "Taste profile", content: card)
    }

    // MARK: - Personalize

    /// The way into offers the app asks MoEngage for and draws itself.
    ///
    /// On the profile because it is about this user rather than about the
    /// menu: what is shown there is chosen from who they are.
    private func makePersonalizeSection() -> UIView {
        let icon = IconTileView(systemImage: "sparkles", size: BrewSize.iconTileSmall, symbolSize: 16)

        let title = UILabel()
        title.text = "Personalized offers"
        title.apply(.body, color: BrewColor.textPrimary)

        let subtitle = UILabel()
        subtitle.text = "Picked for you from your orders and tier"
        subtitle.apply(.caption, color: BrewColor.textSecondary)
        subtitle.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.axis = .vertical
        textStack.spacing = 4

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = BrewColor.textTertiary
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [icon, textStack, chevron])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        let card = CardContainerView()
        let tappable = TappableRow(content: padded(row, horizontal: 16, vertical: 16))
        tappable.accessibilityLabel = "Personalized offers"
        tappable.accessibilityHint = "Opens offers picked for you"
        tappable.addTarget(self, action: #selector(personalizeTapped), for: .touchUpInside)
        card.stackView.addArrangedSubview(tappable)

        return section(title: "Personalize", content: card)
    }

    @objc private func personalizeTapped() {
        onPersonalize()
    }

    // MARK: - Notifications

    private func makeNotificationsSection() -> UIView {
        let title = UILabel()
        title.text = "Order updates"
        title.apply(.body, color: BrewColor.textPrimary)

        pushCaptionLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [title, pushCaptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        pushToggle.onTintColor = BrewColor.primary
        pushToggle.isUserInteractionEnabled = false
        pushToggle.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [textStack, pushToggle])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        let card = CardContainerView()
        let tappable = TappableRow(content: padded(row, horizontal: 16, vertical: 16))
        tappable.accessibilityLabel = "Order updates"
        tappable.addTarget(self, action: #selector(notificationsTapped), for: .touchUpInside)
        card.stackView.addArrangedSubview(tappable)

        // Unlike the row above, these are the app's own settings, so the
        // switches operate. Each change is mirrored onto MoEngage.
        offersToggle.addTarget(self, action: #selector(offersToggled), for: .valueChanged)
        card.stackView.addArrangedSubview(ThinDividerView())
        card.stackView.addArrangedSubview(
            preferenceRow(label: "Offers & new menu", caption: "Limited-time deals and new drinks", toggle: offersToggle)
        )

        marketingToggle.addTarget(self, action: #selector(marketingToggled), for: .valueChanged)
        card.stackView.addArrangedSubview(ThinDividerView())
        card.stackView.addArrangedSubview(
            preferenceRow(label: "Marketing campaigns", caption: "Promotions and seasonal news", toggle: marketingToggle)
        )

        return section(title: "Notifications", content: card)
    }

    /// A notification category the user switches on or off in the app.
    private func preferenceRow(label: String, caption: String, toggle: UISwitch) -> UIView {
        let title = UILabel()
        title.text = label
        title.apply(.body, color: BrewColor.textPrimary)

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.apply(.caption, color: BrewColor.textSecondary)
        captionLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [title, captionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        toggle.onTintColor = BrewColor.primary
        toggle.accessibilityLabel = label
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [textStack, toggle])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return padded(row, horizontal: 16, vertical: 16)
    }

    @objc private func offersToggled() {
        state.setOffersOptIn(offersToggle.isOn)
    }

    @objc private func marketingToggled() {
        state.setMarketingOptIn(marketingToggle.isOn)
    }

    /// Asks the OS where it can still be asked, and opens Settings once it
    /// cannot.
    ///
    /// iOS presents the permission alert once per install. Before that answer
    /// exists the app can still prompt; afterwards — allowed or refused — the
    /// only way to change it is Settings.
    @objc private func notificationsTapped() {
        if state.hasAnsweredPush {
            MoEngageSDKHelper.openNotificationSettings()
        } else {
            MoEngageSDKHelper.requestPushPermission()
        }
    }

    // MARK: - Location

    private func makeLocationSection() -> UIView {
        let card = CardContainerView()

        // Location access.
        let accessTitle = UILabel()
        accessTitle.text = "Location access"
        accessTitle.apply(.body, color: BrewColor.textPrimary)

        locationCaptionLabel.numberOfLines = 0

        let accessTextStack = UIStackView(arrangedSubviews: [accessTitle, locationCaptionLabel])
        accessTextStack.axis = .vertical
        accessTextStack.spacing = 4

        locationActionButton.titleLabel?.font = BrewTextStyle.captionMedium.font
        locationActionButton.setTitleColor(BrewColor.link, for: .normal)
        locationActionButton.addTarget(self, action: #selector(locationActionTapped), for: .touchUpInside)
        locationActionButton.setContentHuggingPriority(.required, for: .horizontal)

        locationValueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let accessRow = UIStackView(arrangedSubviews: [accessTextStack, locationActionButton, locationValueLabel])
        accessRow.axis = .horizontal
        accessRow.spacing = 12
        accessRow.alignment = .center
        card.stackView.addArrangedSubview(padded(accessRow, horizontal: 16, vertical: 14))

        card.stackView.addArrangedSubview(ThinDividerView())

        // Precise location.
        let preciseTitle = UILabel()
        preciseTitle.text = "Precise location"
        preciseTitle.apply(.body, color: BrewColor.textPrimary)

        preciseCaptionLabel.apply(.caption, color: BrewColor.textSecondary)
        preciseCaptionLabel.numberOfLines = 0

        let preciseTextStack = UIStackView(arrangedSubviews: [preciseTitle, preciseCaptionLabel])
        preciseTextStack.axis = .vertical
        preciseTextStack.spacing = 4

        preciseValueLabel.setContentHuggingPriority(.required, for: .horizontal)

        preciseActionButton.setTitle("Open settings", for: .normal)
        preciseActionButton.titleLabel?.font = BrewTextStyle.captionMedium.font
        preciseActionButton.setTitleColor(BrewColor.link, for: .normal)
        preciseActionButton.addTarget(self, action: #selector(preciseActionTapped), for: .touchUpInside)
        preciseActionButton.setContentHuggingPriority(.required, for: .horizontal)

        let preciseRow = UIStackView(arrangedSubviews: [preciseTextStack, preciseActionButton, preciseValueLabel])
        preciseRow.axis = .horizontal
        preciseRow.spacing = 12
        preciseRow.alignment = .center
        card.stackView.addArrangedSubview(padded(preciseRow, horizontal: 16, vertical: 14))

        card.stackView.addArrangedSubview(ThinDividerView())

        // Geofence monitoring.
        let geofenceLabel = UILabel()
        geofenceLabel.text = "Geofence monitoring"
        geofenceLabel.apply(.body, color: BrewColor.textSecondary)
        geofenceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        geofenceValueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let geofenceRow = UIStackView(arrangedSubviews: [geofenceLabel, geofenceValueLabel])
        geofenceRow.axis = .horizontal
        geofenceRow.spacing = 12
        geofenceRow.alignment = .firstBaseline
        card.stackView.addArrangedSubview(padded(geofenceRow, horizontal: 16, vertical: 14))

        return section(title: "Location", content: card)
    }

    /// The next step available, or opens Settings once nothing is left to ask.
    @objc private func locationActionTapped() {
        switch state.locationStatus {
        case .denied, .restricted:
            state.openAppSettings()
        default:
            state.requestLocation()
        }
    }

    @objc private func preciseActionTapped() {
        state.openAppSettings()
    }

    // MARK: - Log out

    private func makeLogoutButton() -> UIView {
        let button = BrewButtonFactory.makeSecondaryButton(title: "Log out")
        button.addTapAction(for: .touchUpInside) { [weak self] in self?.onLogout() }
        return button
    }

    // MARK: - Section helper

    /// A titled group, matching the private `CardSection` in `ProfileView`.
    private func section(title: String, content: UIView) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.apply(.cardTitle, color: BrewColor.textPrimary)
        titleLabel.accessibilityTraits = .header

        let stack = UIStackView(arrangedSubviews: [titleLabel, content])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func padded(_ view: UIView, horizontal: CGFloat, vertical: CGFloat) -> UIView {
        let container = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: vertical),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -vertical),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontal),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontal),
        ])
        return container
    }
}

// MARK: - Small parts

/// A read-only capsule label — the loyalty tier beside the user's name.
private final class ProfilePillLabel: UILabel {

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

/// Makes an entire row tappable, mirroring a SwiftUI `Button` wrapping a row
/// of content with `.buttonStyle(.plain)`.
private final class TappableRow: UIControl {

    init(content: UIView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        content.isUserInteractionEnabled = false
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
