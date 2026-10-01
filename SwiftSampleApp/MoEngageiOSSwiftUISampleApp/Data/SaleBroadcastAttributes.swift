//
//  SaleBroadcastAttributes.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A broadcast Live Activity's data shape — the same content goes to every
//  subscribed user at once (a sale, a live score), unlike BrewOrderAttributes
//  which is one activity per order. Shared between the app and the
//  BrewOrderLiveActivity widget extension — both targets need this type.
//

import ActivityKit

struct SaleBroadcastAttributes: ActivityAttributes {

    /// The live-updating part, refreshed for every subscriber at once via
    /// MoEngage's push-to-start / broadcast update path.
    public struct ContentState: Codable, Hashable {
        var discountText: String
        var timeRemaining: String
    }

    /// Static — set once when the broadcast starts.
    var saleName: String
}
