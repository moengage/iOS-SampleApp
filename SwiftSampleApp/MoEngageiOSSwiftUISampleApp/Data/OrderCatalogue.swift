//
//  OrderCatalogue.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Past orders and the ways to pay for a new one.
//
//  Three orders are seeded so the history screen has something to show without
//  the funnel having to be walked first. The first is in progress, which is
//  what gives that screen its stripe, its status pill and its "Track" action.
//

import Foundation

enum OrderCatalogue {

    private static let seed: [Order] = [
        Order(
            id: "BB-4821",
            placedAt: "Today, 8:34 am",
            lines: [
                OrderLine(name: "Flat white · medium · oat", amount: 270),
                OrderLine(name: "Berry chia yogurt bowl", amount: 290),
            ],
            amount: 476,
            mode: .pickup,
            stage: .brewing,
            readyAt: "ready ~ 8:42 am",
            paidVia: "Paid via wallet",
            active: true
        ),
        Order(
            id: "BB-4780",
            placedAt: "Sat, 9:12 am",
            lines: [
                OrderLine(name: "Cold brew · large", amount: 260),
                OrderLine(name: "Almond biscotti", amount: 110),
            ],
            amount: 350,
            mode: .pickup,
            stage: .pickedUp,
            readyAt: "collected 9:24 am",
            paidVia: "Paid via UPI"
        ),
        Order(
            id: "BB-4712",
            placedAt: "Thu, 5:40 pm",
            lines: [
                OrderLine(name: "Tulsi ginger tea", amount: 140),
                OrderLine(name: "Masala cheese croissant", amount: 180),
            ],
            amount: 320,
            mode: .delivery,
            stage: .pickedUp,
            readyAt: "delivered 6:08 pm",
            paidVia: "Paid via wallet"
        ),
    ]

    static func all() -> [Order] { seed }

    /// Falls back to the most recent order for an unknown identifier, so a
    /// campaign link naming an order this build has never seen still lands.
    static func order(id: String) -> Order {
        seed.first { $0.id == id } ?? seed[0]
    }

    /// The order a new one is modelled on, and the one the menu reorders.
    static func latest() -> Order { seed[0] }

    /// The subtitle on the history screen's app bar.
    static let headerMeta = "28 orders · 14 flat whites"

    /// The history screen's filters. Unlike the menu's, these do filter.
    static let filters = ["All", "Pickup", "Delivery"]

    static let subscriptionNudge = "Subscribe to a daily 8 am flat white and save 15%."

    // MARK: - Payment

    static let paymentMethods = [
        PaymentMethod(id: "wallet", label: "Brew Bar wallet", detail: "₹1,240"),
    ]

    static let defaultPaymentMethodID = "wallet"
}
