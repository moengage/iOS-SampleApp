//
//  LoginViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Login/LoginView.swift.
//
//  Sign-in screen: mobile number and one-time code.
//
//  MoEngage moment: confirming sign-in establishes the user's identity
//  through `identifyUser`, sets their reserved profile attributes, and
//  mirrors their taste profile as custom attributes. That call is made by the
//  caller (`onVerified`), not here — see `MoEngageSDKHelper`.
//
//  The sample has no authentication backend, so the number and the code are
//  fixed values from `DemoUser` presented as read-only fields. There is no
//  text entry, and therefore no validation or error state on this screen.
//  Both the primary and the secondary action confirm sign-in identically.
//

import UIKit

final class LoginViewController: UIViewController {

    /// Returns to the previous screen.
    private let onBack: () -> Void

    /// Sign-in confirmed. The caller reports identity and decides where to go.
    private let onVerified: () -> Void

    init(onBack: @escaping () -> Void, onVerified: @escaping () -> Void) {
        self.onBack = onBack
        self.onVerified = onVerified
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.surface
        buildLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MoEngageSDKHelper.setInAppContext(.login)
    }

    // MARK: - Layout

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        let content = UIStackView()
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 22
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: BrewSize.screenPadding),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -BrewSize.screenPadding),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * BrewSize.screenPadding),
        ])

        let backButton = BackTileButton()
        backButton.addTapAction(for: .touchUpInside) { [weak self] in self?.onBack() }
        // BackTile is leading-aligned within its own 44x44 hit area; wrap it
        // in a container so the stack view doesn't stretch it full width.
        let backContainer = UIView()
        backContainer.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backContainer.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: backContainer.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: backContainer.bottomAnchor),
            backButton.leadingAnchor.constraint(equalTo: backContainer.leadingAnchor),
        ])

        content.addArrangedSubview(backContainer)
        content.addArrangedSubview(makeHeading())
        content.addArrangedSubview(makeFields())

        let verifyButton = BrewButtonFactory.makePrimaryButton(title: "Verify & continue")
        verifyButton.addTapAction(for: .touchUpInside) { [weak self] in self?.onVerified() }
        content.addArrangedSubview(verifyButton)

        content.addArrangedSubview(makeSeparator())

        let googleButton = BrewButtonFactory.makeSecondaryButton(title: "Continue with Google")
        googleButton.addTapAction(for: .touchUpInside) { [weak self] in self?.onVerified() }
        content.addArrangedSubview(googleButton)

        let footnote = UILabel()
        footnote.numberOfLines = 0
        footnote.textAlignment = .center
        footnote.text = "Signing in links this device to your Brew Bar identity so orders, stars and notifications follow you."
        footnote.apply(.micro, color: BrewColor.textTertiary)
        content.addArrangedSubview(footnote)
    }

    // MARK: - Sections

    private func makeHeading() -> UIView {
        let title = UILabel()
        title.numberOfLines = 0
        title.text = "Sign in for stars"
        title.apply(.screenTitle, color: BrewColor.textPrimary)

        let subtitle = UILabel()
        subtitle.numberOfLines = 0
        subtitle.text = "Every ₹100 earns a star. Ten stars, one free drink."
        subtitle.apply(.body, color: BrewColor.textSecondary)

        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func makeFields() -> UIView {
        let phoneGroup = makeFieldGroup(label: "Mobile number", content: makeReadOnlyField(value: DemoUser.phone))
        let otpGroup = makeFieldGroup(label: "OTP", content: makeOneTimeCodeRow(code: DemoUser.oneTimeCode))

        let stack = UIStackView(arrangedSubviews: [phoneGroup, otpGroup])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        return stack
    }

    /// A label above its field.
    private func makeFieldGroup(label: String, content: UIView) -> UIView {
        let labelView = UILabel()
        labelView.text = label
        labelView.apply(.captionMedium, color: BrewColor.textSecondary)

        let stack = UIStackView(arrangedSubviews: [labelView, content])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }

    /// A field-shaped container presenting a fixed value. Not editable.
    private func makeReadOnlyField(value: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = BrewCorner.input
        container.layer.cornerCurve = .continuous
        container.layer.borderColor = BrewColor.borderDefault.cgColor
        container.layer.borderWidth = 1
        container.heightAnchor.constraint(greaterThanOrEqualToConstant: BrewSize.inputHeight).isActive = true

        let label = UILabel()
        label.text = value
        label.apply(.body, color: BrewColor.textPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -14),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        return container
    }

    /// The one-time code, one boxed digit each.
    private func makeOneTimeCodeRow(code: String) -> UIView {
        let digits = Array(code.prefix(4)).map(String.init)
        let boxes: [UIView] = digits.map { digit in
            let box = UIView()
            box.layer.cornerRadius = BrewCorner.input
            box.layer.cornerCurve = .continuous
            box.layer.borderColor = BrewColor.borderDefault.cgColor
            box.layer.borderWidth = 1
            box.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                box.widthAnchor.constraint(equalToConstant: BrewSize.otpBoxWidth),
                box.heightAnchor.constraint(equalToConstant: BrewSize.inputHeight),
            ])

            let label = UILabel()
            label.textAlignment = .center
            label.text = digit
            label.apply(.otpDigit, color: BrewColor.textPrimary)
            label.translatesAutoresizingMaskIntoConstraints = false
            box.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: box.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            ])
            return box
        }

        let stack = UIStackView(arrangedSubviews: boxes)
        stack.axis = .horizontal
        stack.spacing = 10
        // Read as one value rather than four unrelated digits.
        stack.isAccessibilityElement = true
        stack.accessibilityLabel = "One-time code"
        stack.accessibilityValue = digits.joined(separator: " ")

        // `makeFieldGroup`'s outer stack uses `.fill` alignment, which would
        // otherwise stretch this row to the full field width and force one
        // box to grow to absorb the leftover space. Wrapping it lets the row
        // itself take the extra width while the boxes keep their fixed size.
        let row = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            stack.topAnchor.constraint(equalTo: row.topAnchor),
            stack.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
        ])
        return row
    }

    /// Rule, label, rule — the two rules share the width left over by the label.
    private func makeSeparator() -> UIView {
        let leading = ThinDividerView(color: BrewColor.borderDefault)
        let trailing = ThinDividerView(color: BrewColor.borderDefault)

        let label = UILabel()
        label.text = "or"
        label.apply(.caption, color: BrewColor.textTertiary)

        let stack = UIStackView(arrangedSubviews: [leading, label, trailing])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }
}
