//
//  CartModels.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The order's domain types.
//

import Foundation

/// One configured item in the order.
struct CartLine: Identifiable, Hashable {

    let id: String

    /// The menu item this line was built from.
    let itemID: String

    /// Item name and size, as one line — "Flat white · medium".
    let name: String

    /// The rest of the configuration — "Oat milk · 1 sugar".
    let options: String

    /// The configured price of one, in whole rupees.
    let amount: Int

    let quantity: Int

    /// Asset catalog image name.
    let image: String

    init(
        id: String,
        itemID: String,
        name: String,
        options: String,
        amount: Int,
        quantity: Int = 1,
        image: String
    ) {
        self.id = id
        self.itemID = itemID
        self.name = name
        self.options = options
        self.amount = amount
        self.quantity = quantity
        self.image = image
    }
}

/// How the order is collected.
enum Fulfilment: String, CaseIterable, Identifiable {

    case pickup
    case delivery

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pickup: return "Pickup"
        case .delivery: return "Delivery"
        }
    }

    var eta: String {
        switch self {
        case .pickup: return "6–8 min"
        case .delivery: return "25–35 min"
        }
    }
}

/// What the drink is served in.
enum CupPreference: String, CaseIterable, Identifiable {

    case ownCup
    case storeCup

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ownCup: return "Bring my own cup"
        case .storeCup: return "Store cup"
        }
    }

    /// What bringing your own cup saves, in whole rupees.
    ///
    /// Shown on the pill but deliberately not billed — see `Bill`.
    var discount: Int {
        switch self {
        case .ownCup: return 15
        case .storeCup: return 0
        }
    }
}

/// What the order costs, broken down.
///
/// Every field is supplied by the caller rather than derived here, so the
/// breakdown shown is exactly the breakdown that was calculated.
struct Bill {

    let itemTotal: Int
    let taxes: Int

    /// The applied coupon, or `nil` for a bill with none.
    let couponCode: String?

    /// What the coupon took off.
    let discount: Int

    /// What the cup preference took off.
    let cupDiscount: Int

    var toPay: Int {
        itemTotal + taxes - discount - cupDiscount
    }
}
