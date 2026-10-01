//
//  InboxViewController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Inbox/InboxView.swift.
//
//  Push campaigns the device has received, kept for reading later, grouped
//  into "Today" / "Earlier". Unread rows are bold and carry a stripe.
//
//  MoEngage moment: `setInAppContext(.inbox)` on arrival. `inbox.refresh()` is
//  called on every `viewWillAppear`, matching the SwiftUI source's comment
//  that a campaign can land while the screen is open, so the list is re-read
//  on arrival rather than only when it is first built. Opening a message
//  (`InboxState.open(_:)`) marks it read and reports `Notification_Opened`
//  on the state object's own timing, not duplicated here.
//

import UIKit
import Combine

final class InboxViewController: UIViewController {

    private let inbox: InboxState
    private let onBack: () -> Void
    private let onMessageOpened: (URL) -> Void

    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateView = UIView()
    private let markAllReadButton = UIButton(type: .system)

    /// Flattened (group, message) rows currently on screen.
    private var sections: [(group: InboxGroup, messages: [InboxMessage])] = []

    init(inbox: InboxState, onBack: @escaping () -> Void, onMessageOpened: @escaping (URL) -> Void) {
        self.inbox = inbox
        self.onBack = onBack
        self.onMessageOpened = onMessageOpened
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
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MoEngageSDKHelper.setInAppContext(.inbox)
        // A campaign can land while the screen is open, so the list is
        // re-read on arrival rather than only when it was first built.
        inbox.refresh()
    }

    // MARK: - Binding

    private func bind() {
        inbox.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    // MARK: - Layout

    private func buildLayout() {
        let appBar = BrewAppBarView(title: "Notifications")
        appBar.onBack = { [weak self] in self?.onBack() }

        markAllReadButton.setTitle("Mark all read", for: .normal)
        markAllReadButton.setTitleColor(BrewColor.link, for: .normal)
        markAllReadButton.titleLabel?.font = BrewTextStyle.captionMedium.font
        markAllReadButton.addTarget(self, action: #selector(markAllReadTapped), for: .touchUpInside)
        markAllReadButton.translatesAutoresizingMaskIntoConstraints = false
        appBar.trailingContainer.addSubview(markAllReadButton)
        NSLayoutConstraint.activate([
            markAllReadButton.topAnchor.constraint(equalTo: appBar.trailingContainer.topAnchor),
            markAllReadButton.bottomAnchor.constraint(equalTo: appBar.trailingContainer.bottomAnchor),
            markAllReadButton.leadingAnchor.constraint(equalTo: appBar.trailingContainer.leadingAnchor),
            markAllReadButton.trailingAnchor.constraint(equalTo: appBar.trailingContainer.trailingAnchor),
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InboxRowCell.self, forCellReuseIdentifier: InboxRowCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 28, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        // Empty state.
        let icon = IconTileView(systemImage: "bell", size: 56, symbolSize: 26)
        let emptyLabel = UILabel()
        emptyLabel.text = "Your MoEngage Inbox messages will appear here"
        emptyLabel.apply(.support, color: BrewColor.textSecondary)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        let emptyStack = UIStackView(arrangedSubviews: [icon, emptyLabel])
        emptyStack.axis = .vertical
        emptyStack.alignment = .center
        emptyStack.spacing = 16
        emptyStack.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyStack)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStack.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStack.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: BrewSize.screenPadding),
            emptyStack.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -BrewSize.screenPadding),
        ])

        let contentContainer = UIView()
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(tableView)
        contentContainer.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            emptyStateView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        ])

        let root = UIStackView(arrangedSubviews: [appBar, contentContainer])
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

    private func refresh() {
        markAllReadButton.isHidden = inbox.messages.isEmpty

        sections = InboxGroup.allCases.compactMap { group in
            let grouped = inbox.messages.filter { $0.group == group }
            return grouped.isEmpty ? nil : (group, grouped)
        }

        let isEmpty = inbox.messages.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func markAllReadTapped() {
        inbox.markAllRead()
    }

    private func open(_ message: InboxMessage) {
        if let url = inbox.open(message) {
            onMessageOpened(url)
        }
    }
}

// MARK: - Table view

extension InboxViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].messages.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].group.header.uppercased()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let label = UILabel()
        label.text = sections[section].group.header.uppercased()
        label.apply(.label, color: BrewColor.textTertiary)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: BrewSize.screenPadding),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -BrewSize.screenPadding),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
        ])
        return container
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InboxRowCell.reuseIdentifier, for: indexPath) as! InboxRowCell
        cell.configure(message: sections[indexPath.section].messages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        open(sections[indexPath.section].messages[indexPath.row])
    }
}

// MARK: - Row cell

private final class InboxRowCell: UITableViewCell {

    static let reuseIdentifier = "InboxRowCell"

    private let card = UIView()
    private let stripe = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let timestampLabel = UILabel()

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
        card.layer.cornerRadius = BrewCorner.button
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = BrewColor.borderSubtle.cgColor
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false

        stripe.backgroundColor = BrewColor.primary
        stripe.translatesAutoresizingMaskIntoConstraints = false

        let icon = IconTileView(systemImage: "cup.and.saucer.fill", size: BrewSize.iconTileSmall, symbolSize: 17)

        titleLabel.numberOfLines = 0
        bodyLabel.numberOfLines = 0
        timestampLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, timestampLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        row.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stripe)
        card.addSubview(row)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BrewSize.screenPadding),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BrewSize.screenPadding),

            stripe.topAnchor.constraint(equalTo: card.topAnchor),
            stripe.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stripe.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stripe.widthAnchor.constraint(equalToConstant: BrewSize.activeStripe),

            row.topAnchor.constraint(equalTo: card.topAnchor),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
        ])
    }

    func configure(message: InboxMessage) {
        titleLabel.text = message.title
        titleLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        bodyLabel.text = message.body
        bodyLabel.apply(.support, color: BrewColor.textSecondary)
        timestampLabel.text = message.timestamp
        timestampLabel.apply(.micro, color: BrewColor.textTertiary)

        stripe.isHidden = message.isRead
        card.alpha = message.isRead ? 0.72 : 1
    }
}
