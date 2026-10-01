//
//  InboxModels.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The inbox as the app displays it.
//
//  The SDK's `MoEngageInboxEntry` carries far more than a list row needs — the
//  whole push payload, expiry, grouping keys, rich-landing URLs. This is the
//  subset the screen actually draws, so the view never reaches into an SDK type
//  and the mapping happens in one place.
//

import Foundation

/// Which part of the list a message falls under.
enum InboxGroup: String, CaseIterable, Identifiable {

    case today
    case earlier

    var id: String { rawValue }

    /// Shown as the group's header, uppercased by the view.
    var header: String {
        switch self {
        case .today: return "Today"
        case .earlier: return "Earlier"
        }
    }
}

/// One row of the inbox.
struct InboxMessage: Identifiable, Equatable {

    /// The campaign identifier, which is also what the SDK is told about when
    /// the message is opened.
    let id: String

    let title: String
    let body: String

    /// Relative and already formatted — "12 min ago", "Mon".
    let timestamp: String

    let group: InboxGroup

    /// Opened before. Read rows are dimmed and lose their stripe.
    var isRead: Bool

    /// Where opening it leads, when the campaign carried a link.
    let deeplink: URL?
}
