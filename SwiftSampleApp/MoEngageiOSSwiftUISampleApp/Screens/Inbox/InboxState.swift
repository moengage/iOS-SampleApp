//
//  InboxState.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The inbox's contents and its unread count.
//
//  Owned above the tab bar rather than by the inbox screen, because the bell
//  badge on the menu needs the count whether or not the inbox has ever been
//  opened.
//
//  MoEngage moment: opening a message marks it read, reports the click against
//  the campaign, and reports `Notification_Opened`.
//

import Foundation
import MoEngageInbox

@MainActor
final class InboxState: ObservableObject {

    @Published private(set) var messages: [InboxMessage] = []

    /// Drives the bell badge. Zero hides it.
    @Published private(set) var unreadCount = 0

    /// Refreshes the list and the count.
    ///
    /// Called on arriving at the menu and at the inbox, because a campaign can
    /// land while either is open.
    func refresh() {
        MoEngageInboxModule.fetchMessages { [weak self] entries in
            self?.messages = entries.compactMap(InboxMessage.init(entry:))
        }

        refreshUnreadCount()
    }

    /// Applied unconditionally, including zero — the SDK reporting no unread
    /// messages is an answer, and clearing the badge matters as much as
    /// setting it.
    func refreshUnreadCount() {
        MoEngageInboxModule.fetchUnreadCount { [weak self] count in
            self?.unreadCount = max(0, count)
        }
    }

    /// Opens a message. Returns where it leads, if anywhere.
    @discardableResult
    func open(_ message: InboxMessage) -> URL? {
        markRead(message)
        MoEngageSDKHelper.trackNotificationOpened(
            campaignID: message.id,
            deeplink: message.deeplink?.absoluteString
        )
        return message.deeplink
    }

    func markAllRead() {
        for message in messages where !message.isRead {
            markRead(message)
        }
    }

    /// Marks read in the SDK and locally.
    ///
    /// The local edit is not an optimisation: the SDK is not re-read after
    /// this, so without it the row would stay bold until the next refresh.
    private func markRead(_ message: InboxMessage) {
        guard !message.isRead else { return }

        MoEngageInboxModule.markRead(campaignID: message.id)

        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].isRead = true
        }

        unreadCount = max(0, unreadCount - 1)
    }
}

// MARK: - Mapping

private extension InboxMessage {

    /// Builds a row from an SDK entry, or `nil` when the entry carries no
    /// campaign identifier — without one it cannot be marked read or reported,
    /// so it would be a row that does nothing.
    init?(entry: MoEngageInboxEntry) {
        guard let campaignID = entry.campaignID, !campaignID.isEmpty else { return nil }

        let sentAt = entry.sentTime ?? entry.receivedDate

        self.init(
            id: campaignID,
            title: entry.notificationTitle,
            body: entry.notificationBody,
            timestamp: relativeTime(since: sentAt),
            group: Self.group(for: sentAt),
            isRead: entry.isRead,
            deeplink: entry.deepLinkURL.flatMap(URL.init(string:))
        )
    }

    static func group(for date: Date?) -> InboxGroup {
        guard let date else { return .earlier }
        return Calendar.current.isDateInToday(date) ? .today : .earlier
    }
}
