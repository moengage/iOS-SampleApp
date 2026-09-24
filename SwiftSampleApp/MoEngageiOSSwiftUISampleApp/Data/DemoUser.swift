//
//  DemoUser.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The signed-in persona and the store it is checked into.
//
//  The sample has no authentication backend. These fixed values stand in for
//  whatever a real sign-in would return, and are the source for every user
//  identity and attribute reported to MoEngage.
//

import Foundation

/// The store the demo user is checked into.
enum Store {

    /// Reported to MoEngage as the user's home store.
    static let name = "Banashankari"

    /// The store strip's first line.
    static let address = "Banashankari · Bengaluru"

    /// The store strip's second line.
    static let hours = "Pickup in 6–8 min · open till 11 pm"

    /// The app bar's subtitle on menu screens.
    static let pickupLine = "Banashankari · pickup 6–8 min"

    /// The store named alongside a fulfilment choice.
    static let summaryLine = "Banashankari, Bengaluru"
}

/// The signed-in demo persona.
enum DemoUser {

    /// The unique identifier reported to MoEngage as the user's identity.
    static let id = "brewbar-samuel-001"

    static let name = "Samuel"

    /// Shown in the profile avatar.
    static let initials = "S"

    /// The loyalty tier, shown as a pill beside the name.
    static let tier = "Gold cup"
    static let firstName = "Samuel"
    static let lastName = ""

    /// Displayed on the sign-in and profile screens.
    static let phone = "+91 12345 67890"

    /// Reported to MoEngage. E.164, as the dashboard expects.
    static let phoneE164 = "+911234567890"

    static let email = "samuel@example.com"

    /// The fixed one-time code shown on the sign-in screen.
    static let oneTimeCode = "4816"

    static let taste = TasteProfile(
        favouriteDrink: "Flat white",
        milk: "Oat",
        sweetness: "1 sugar",
        homeStore: Store.name,
        birthday: "14 Mar 1994",
        birthdayISO: "1994-03-14T00:00:00.000Z"
    )
}

/// The user's drink preferences, mirrored onto their MoEngage profile.
struct TasteProfile {
    let favouriteDrink: String
    let milk: String
    let sweetness: String
    let homeStore: String

    /// Shown on the profile screen.
    let birthday: String

    /// Reported to MoEngage, which expects ISO 8601.
    let birthdayISO: String
}
