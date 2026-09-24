//
//  BrewOrderAttributes.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The order-tracking Live Activity's data shape. Shared between the app
//  (which starts and updates the activity) and the BrewOrderLiveActivity
//  widget extension (which renders it) — both targets need this exact type.
//

import ActivityKit

struct BrewOrderAttributes: ActivityAttributes {

    /// The live-updating part. The backend refreshes this via MoEngage's
    /// Inform API; the widget just redraws whatever it's given.
    public struct ContentState: Codable, Hashable {
        var status: String
        var etaMinutes: Int
    }
}
