//
//  PushOptInViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Permission/PushOptInView.swift.
//
//  Notification opt-in: the screen that explains what notifications are for,
//  before the system permission alert appears.
//
//  MoEngage moment: the call to action registers for push, which presents the
//  system alert. The answer is not reported anywhere — the SDK reads the
//  authorization status itself. See `MoEngagePush`.
//
//  iOS presents that alert once per install, so this screen exists to make the
//  ask land: the user sees the value before the decision, not after.
//
//  The screen moves on as soon as the alert has been answered, whichever way.
//  A system alert makes the app briefly inactive, so returning to the active
//  phase (`UIApplication.didBecomeActiveNotification`) is the signal that an
//  answer now exists to read — the UIKit equivalent of the SwiftUI original's
//  `.onChange(of: scenePhase)`.
//

import UIKit

final class PushOptInViewController: UIViewController {

    /// Called once the permission alert has been answered, or when the user
    /// declines to be asked. The caller decides where the flow continues.
    private let onContinue: () -> Void

    /// Set once the permission alert has been requested, so the app only
    /// re-reads the authorization status for a decision this screen actually
    /// asked for.
    private var didRequestPermission = false

    /// Guards against calling `onContinue` more than once.
    private var hasContinued = false

    private var didBecomeActiveObserver: NSObjectProtocol?

    private static let valueProps = [
        "A ping the moment your order hits the bar",
        "Croissants out of the oven at 8:30 am",
        "Star milestones and free-drink reminders",
    ]

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(didBecomeActiveObserver)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground
        buildLayout()
        observeForegroundReturn()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MoEngageSDKHelper.setInAppContext(.permission)

        // Nothing left to ask for if the user has answered already, whether
        // on an earlier run or in Settings.
        Task { [weak self] in
            guard let self else { return }
            if await MoEngageSDKHelper.hasAnsweredPushPermission() {
                self.finish()
            }
        }
    }

    private func observeForegroundReturn() {
        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.didRequestPermission else { return }
            Task { [weak self] in
                guard let self else { return }
                if await MoEngageSDKHelper.hasAnsweredPushPermission() {
                    self.finish()
                }
            }
        }
    }

    private func finish() {
        guard !hasContinued else { return }
        hasContinued = true
        onContinue()
    }

    // MARK: - Layout

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        let content = UIStackView(arrangedSubviews: [makeBanner(), makeMessage(), makeActions()])
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 0
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
        ])
    }

    /// Fitted, not filled, so the whole banner image stays visible and the
    /// tint shows at the sides on a wide, short screen — matching the SwiftUI
    /// `.scaledToFit()` treatment.
    private func makeBanner() -> UIView {
        let container = UIView()
        container.backgroundColor = BrewColor.primaryLightTint
        container.heightAnchor.constraint(equalToConstant: BrewSize.bannerMaxHeight).isActive = true

        if let bannerImage = UIImage(named: "PermissionBanner") {
            let imageView = UIImageView(image: bannerImage)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: container.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
        }
        return container
    }

    private func makeMessage() -> UIView {
        let title = UILabel()
        title.numberOfLines = 0
        title.text = "Know the moment it's ready"
        title.apply(.screenTitleSmall, color: BrewColor.textPrimary)

        let subtitle = UILabel()
        subtitle.numberOfLines = 0
        subtitle.text = "We only send what's useful: your order, the bakes you like and the stars you're about to earn."
        subtitle.apply(.subtitle, color: BrewColor.textSecondary)

        var rows: [UIView] = [title, subtitle]
        rows.append(contentsOf: Self.valueProps.map(makeValueProp))

        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 26, left: 22, bottom: 22, right: 22)
        return stack
    }

    private func makeValueProp(_ line: String) -> UIView {
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = BrewColor.primary
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.widthAnchor.constraint(equalToConstant: 14).isActive = true

        let label = UILabel()
        label.numberOfLines = 0
        label.text = line
        label.apply(.body, color: BrewColor.textPrimary)

        let stack = UIStackView(arrangedSubviews: [checkmark, label])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 10
        return stack
    }

    private func makeActions() -> UIView {
        let enableButton = BrewButtonFactory.makePrimaryButton(title: "Enable notifications")
        enableButton.addTapAction { [weak self] in
            self?.didRequestPermission = true
            MoEngageSDKHelper.requestPushPermission()
        }

        let notNowButton = BrewButtonFactory.makeQuietButton(title: "Not now")
        notNowButton.addTapAction(for: .touchUpInside) { [weak self] in self?.finish() }

        let stack = UIStackView(arrangedSubviews: [enableButton, notNowButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: BrewSize.screenPadding, bottom: 22, right: BrewSize.screenPadding)
        return stack
    }
}
