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
//  MoEngage integration:
//  - Opening a message reports the click against the campaign on every open,
//    so the SDK can tell a first click from a repeat, and tracks the app's own
//    `Notification_Opened` event.
//  - "Mark all read" only marks messages read. Nothing was opened, so nothing
//    counts towards the campaign's click-through.
//

import Foundation

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
        MoEngageSDKHelper.fetchInboxMessages { [weak self] messages in
            self?.messages = messages
        }

        refreshUnreadCount()
    }

    /// Applied unconditionally, including zero — the SDK reporting no unread
    /// messages is an answer, and clearing the badge matters as much as
    /// setting it.
    func refreshUnreadCount() {
        MoEngageSDKHelper.fetchInboxUnreadCount { [weak self] count in
            self?.unreadCount = max(0, count)
        }
    }

    /// Opens a message. Returns where it leads, if anywhere.
    ///
    /// The click is reported even when the message is already read: the SDK
    /// tags a repeat open as such, and it is still an open.
    @discardableResult
    func open(_ message: InboxMessage) -> URL? {
        // Marks the message read in the SDK too — see
        // `MoEngageInboxModule.trackMessageClicked(campaignID:)`.
        MoEngageSDKHelper.trackInboxMessageClicked(campaignID: message.id)
        markReadLocally(message)

        MoEngageSDKHelper.trackNotificationOpened(
            campaignID: message.id,
            deeplink: message.deeplink?.absoluteString
        )
        return message.deeplink
    }

    func markAllRead() {
        for message in messages where !message.isRead {
            MoEngageSDKHelper.markInboxMessageRead(campaignID: message.id)
            markReadLocally(message)
        }
    }

    /// Mirrors a read into the list and the badge.
    ///
    /// The local edit is not an optimisation: the SDK is not re-read after
    /// this, so without it the row would stay bold until the next refresh.
    /// Guarded so an already-read message does not lower the count twice.
    private func markReadLocally(_ message: InboxMessage) {
        guard !message.isRead else { return }

        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].isRead = true
        }

        unreadCount = max(0, unreadCount - 1)
    }
}
