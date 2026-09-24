//
//  InboxView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Push campaigns the device has received, kept for reading later.
//
//  Drawn by the app from data the SDK returns. The SDK ships its own inbox
//  screen — see `MoEngageInbox` — but this one shares the design system, and
//  building it is the only option on Android, so the two apps match.
//
//  Nothing is seeded behind this screen. On a fresh install it is empty until a
//  campaign lands, which is why the empty state says where messages come from
//  rather than apologising for their absence.
//

import SwiftUI

struct InboxView: View {

    @ObservedObject var inbox: InboxState

    let onBack: () -> Void

    /// Opens whatever a message links to. The state object has already
    /// reported the open by the time this is called.
    let onMessageOpened: (URL) -> Void

    var body: some View {
        VStack(spacing: 0) {
            BrewAppBar(title: "Notifications", onBack: onBack) {
                if !inbox.messages.isEmpty {
                    Button("Mark all read") { inbox.markAllRead() }
                        .brewInlineLink()
                }
            }

            if inbox.messages.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.inbox)
        // A campaign can land while the screen is open, so the list is
        // re-read on arrival rather than only when it is first built.
        .onAppear { inbox.refresh() }
    }

    // MARK: - List

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(InboxGroup.allCases) { group in
                    let grouped = inbox.messages.filter { $0.group == group }

                    if !grouped.isEmpty {
                        Text(group.header.uppercased())
                            .brewTextStyle(.label)
                            .foregroundColor(BrewColor.textTertiary)
                            .padding(.top, 6)
                            .padding(.bottom, 4)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(grouped) { message in
                            NotificationRow(message: message) { open(message) }
                        }
                    }
                }
            }
            .padding(.horizontal, BrewSize.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
    }

    private func open(_ message: InboxMessage) {
        if let url = inbox.open(message) {
            onMessageOpened(url)
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            IconTile(systemImage: "bell", size: 56, symbolSize: 26)

            Text("Your MoEngage Inbox messages will appear here")
                .brewTextStyle(.support)
                .foregroundColor(BrewColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, BrewSize.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row

/// One message. Unread carries a brand stripe and full opacity; read loses the
/// stripe and dims, so the two are distinguishable without relying on colour
/// alone.
private struct NotificationRow: View {

    let message: InboxMessage
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                if !message.isRead {
                    BrewColor.primary
                        .frame(width: BrewSize.activeStripe)
                }

                HStack(alignment: .top, spacing: 12) {
                    IconTile(
                        systemImage: "cup.and.saucer.fill",
                        size: BrewSize.iconTileSmall,
                        symbolSize: 17
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.title)
                            .brewTextStyle(.bodyMedium)
                            .foregroundColor(BrewColor.textPrimary)

                        Text(message.body)
                            .brewTextStyle(.support)
                            .foregroundColor(BrewColor.textSecondary)

                        Text(message.timestamp)
                            .brewTextStyle(.micro)
                            .foregroundColor(BrewColor.textTertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity)
            .background(BrewColor.surface)
            .clipShape(shape)
            .overlay(shape.stroke(BrewColor.borderSubtle, lineWidth: 1))
            .opacity(message.isRead ? 0.72 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityValue(message.isRead ? "Read" : "Unread")
    }
}

#Preview {
    InboxView(inbox: InboxState(), onBack: {}, onMessageOpened: { _ in })
}
