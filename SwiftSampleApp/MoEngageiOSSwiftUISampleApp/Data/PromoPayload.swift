//
//  PromoPayload.swift
//  MoEngageiOSSwiftUISampleApp
//
//  What a self-handled in-app campaign's card shows.
//
//  MoEngage hands the app a raw JSON string with no presentation — this is
//  what that string decodes to. The keys are shared with the other platform
//  samples, so the same dashboard campaign drives every platform.
//

import Foundation

struct PromoPayload: Decodable, Equatable {

    let title: String
    let subtitle: String

    /// A coupon code the campaign is offering, if any.
    let code: String?

    /// Where the card leads. Resolved as a campaign deep link like any other,
    /// so it lands wherever `Route(deeplink:)` sends it.
    let deeplink: String?

    /// Shown when the payload is missing or fails to decode, so a
    /// misconfigured campaign still renders a card rather than none.
    static let fallback = PromoPayload(
        title: "Members get more",
        subtitle: "Tap to see today's offer",
        code: nil,
        deeplink: nil
    )
}
