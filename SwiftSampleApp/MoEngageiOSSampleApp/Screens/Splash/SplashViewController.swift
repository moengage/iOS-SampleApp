//
//  SplashViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Splash/SplashView.swift.
//
//  Brand introduction screen, and the first screen presented at launch.
//
//  The MoEngage SDK is initialised in
//  `AppDelegate.application(_:didFinishLaunchingWithOptions:)`, before this
//  screen is built. The footnote records that, as the sample is intended to
//  make each SDK integration point visible.
//
//  This view controller holds no state and performs no side effects beyond
//  the in-app context. It accepts a single closure and has no knowledge of
//  navigation, which keeps it independently reusable.
//

import UIKit

final class SplashViewController: UIViewController {

    /// Invoked by the primary call to action. The caller decides the destination.
    private let onGetStarted: () -> Void

    init(onGetStarted: @escaping () -> Void) {
        self.onGetStarted = onGetStarted
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.primaryDarkSurface
        buildLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MoEngageSDKHelper.setInAppContext(.splash)
    }

    // MARK: - Layout

    private func buildLayout() {
        // Dimmed background artwork, composited over the base fill and
        // extending past the safe area, exactly like `CoverImage` in SwiftUI.
        if let backgroundImage = UIImage(named: "SplashBackground") {
            let backgroundImageView = UIImageView(image: backgroundImage)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.clipsToBounds = true
            backgroundImageView.alpha = 0.45
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundImageView)
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }

        let brandBlock = makeBrandBlock()
        let actionBlock = makeActionBlock()

        brandBlock.translatesAutoresizingMaskIntoConstraints = false
        actionBlock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(brandBlock)
        view.addSubview(actionBlock)

        NSLayoutConstraint.activate([
            brandBlock.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            brandBlock.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            brandBlock.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),

            actionBlock.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: BrewSize.screenPadding),
            actionBlock.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -BrewSize.screenPadding),
            actionBlock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            actionBlock.topAnchor.constraint(greaterThanOrEqualTo: brandBlock.bottomAnchor, constant: 16),
        ])
    }

    /// Rounded brand tile, heading and subtitle, pinned to the top-leading area.
    private func makeBrandBlock() -> UIView {
        let brandTile = UIView()
        brandTile.backgroundColor = BrewColor.primary
        brandTile.layer.cornerRadius = BrewCorner.card
        brandTile.layer.cornerCurve = .continuous
        brandTile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            brandTile.widthAnchor.constraint(equalToConstant: BrewSize.brandTile),
            brandTile.heightAnchor.constraint(equalToConstant: BrewSize.brandTile),
        ])

        let glyph = UIImageView(image: UIImage(systemName: "cup.and.saucer.fill"))
        glyph.tintColor = BrewColor.onDarkPrimary
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        brandTile.addSubview(glyph)
        NSLayoutConstraint.activate([
            glyph.centerXAnchor.constraint(equalTo: brandTile.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: brandTile.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 22),
            glyph.heightAnchor.constraint(equalToConstant: 22),
        ])

        let heading = UILabel()
        heading.numberOfLines = 0
        heading.text = "Brew Bar"
        heading.apply(.display, color: BrewColor.onDarkPrimary)

        let subtitle = UILabel()
        subtitle.numberOfLines = 0
        subtitle.text = "Slow-roast coffee, herbal brews and fresh bakes — ordered before you reach the counter."
        subtitle.apply(.subtitle, color: BrewColor.onDarkSecondary)
        // Caps the measure so the copy wraps at a comfortable line length.
        subtitle.preferredMaxLayoutWidth = 260
        subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 260).isActive = true

        let stack = UIStackView(arrangedSubviews: [brandTile, heading, subtitle])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        return stack
    }

    private func makeActionBlock() -> UIView {
        let getStartedButton = BrewButtonFactory.makePrimaryButton(title: "Get started")
        getStartedButton.addTapAction(for: .touchUpInside) { [weak self] in self?.onGetStarted() }

        let footnote = UILabel()
        footnote.numberOfLines = 0
        footnote.textAlignment = .center
        footnote.text = "MoEngage SDK initialised in AppDelegate"
        footnote.apply(.caption, color: BrewColor.onDarkFootnote)

        let stack = UIStackView(arrangedSubviews: [getStartedButton, footnote])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }
}
