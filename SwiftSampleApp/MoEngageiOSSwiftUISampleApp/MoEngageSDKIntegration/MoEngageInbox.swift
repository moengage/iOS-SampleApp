//
//  MoEngageInbox.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The notification inbox. Reached through `MoEngageSDKHelper`.
//
//  The SDK keeps every push campaign the device received and hands them back on
//  request. It returns data only here — the app draws the list itself, which is
//  what lets the inbox match the rest of this app rather than look like a
//  second application inside it.
//
//  The SDK does also ship a ready-made screen — `presentInboxViewController`
//  and friends, built in UIKit with a storyboard. Using it is a couple of lines
//  and worth knowing about; this app builds its own so the inbox shares the
//  design system.
//
//  There is nothing to show on a fresh install. The inbox fills as campaigns
//  arrive, so an empty list is the normal starting state rather than a failure.
//

import Foundation
import MoEngageInbox

enum MoEngageInboxModule {

    /// Every message the device has received, newest first as the SDK returns
    /// them, mapped onto the app's own `InboxMessage`.
    static func fetchMessages(_ onResult: @escaping ([InboxMessage]) -> Void) {
        MoEngageSDKInbox.sharedInstance.getInboxMessages { entries, _ in
            onResult(entries.compactMap(InboxMessage.init(entry:)))
        }
    }

    /// The count behind the bell badge.
    ///
    /// Reported even when zero: the SDK answering "none" is a real answer, and
    /// clearing the badge is as important as setting it.
    static func fetchUnreadCount(_ onResult: @escaping (Int) -> Void) {
        MoEngageSDKInbox.sharedInstance.getUnreadNotificationCount { count, _ in
            onResult(count)
        }
    }

    /// Reports a message opened. Call on every open, not just the first.
    ///
    /// One call, not two: `trackInboxClick` marks the entry read itself, after
    /// deciding from its state at call time whether this is the first click
    /// (`isFirstClick`) or a repeat (`isRead`). Marking it read beforehand
    /// would make every click look like a repeat.
    static func trackMessageClicked(campaignID: String) {
        MoEngageSDKInbox.sharedInstance.trackInboxClick(withCampaignID: campaignID)
    }

    /// Marks a message read without reporting a click — for "Mark all read",
    /// where the user has not opened anything, so nothing should count towards
    /// the campaign's click-through.
    static func markMessageRead(campaignID: String) {
        MoEngageSDKInbox.sharedInstance.markInboxNotificationClicked(withCampaignID: campaignID)
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
