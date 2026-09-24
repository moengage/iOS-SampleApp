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
//  design system, and because that is the only option on Android, where the
//  SDK provides no screen at all.
//
//  There is nothing to show on a fresh install. The inbox fills as campaigns
//  arrive, so an empty list is the normal starting state rather than a failure.
//

import Foundation
import MoEngageInbox

enum MoEngageInboxModule {

    /// Every message the device has received, newest first as the SDK returns
    /// them.
    static func fetchMessages(_ onResult: @escaping ([MoEngageInboxEntry]) -> Void) {
        MoEngageSDKInbox.sharedInstance.getInboxMessages { entries, _ in
            onResult(entries)
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

    /// Marks one message read, and reports the click to MoEngage.
    ///
    /// Two calls rather than one: the first is the inbox's own read state, the
    /// second is the campaign statistic. A message opened from the inbox counts
    /// towards the campaign exactly as one opened from the notification would.
    static func markRead(campaignID: String) {
        MoEngageSDKInbox.sharedInstance.markInboxNotificationClicked(withCampaignID: campaignID)
        MoEngageSDKInbox.sharedInstance.trackInboxClick(withCampaignID: campaignID)
    }
}
