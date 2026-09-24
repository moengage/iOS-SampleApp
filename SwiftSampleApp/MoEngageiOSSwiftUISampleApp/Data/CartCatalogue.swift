//
//  CartCatalogue.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The order's starting contents and pricing rules.
//
//  The cart starts with two lines already in it, matching the Android sample.
//  That is deliberate: it lets the cart and payment screens be opened and
//  demonstrated without walking the whole funnel first, and it means the sample
//  has no empty-cart state to design.
//

import Foundation

enum CartCatalogue {

    /// The lines the order starts with.
    static func seedLines() -> [CartLine] {
        [
            CartLine(
                id: "line-1",
                itemID: "flat-white",
                name: "Flat white · medium",
                options: "Oat milk · 1 sugar",
                amount: 270,
                image: "HotCoffee"
            ),
            CartLine(
                id: "line-2",
                itemID: "berry-chia-bowl",
                name: "Berry chia yogurt bowl",
                options: "No honey",
                amount: 290,
                image: "YogurtBowl"
            ),
        ]
    }

    /// The coupon applied to every order.
    ///
    /// The sample has no way to enter or remove one: the discount is always
    /// applied, so the bill always shows a saving.
    static let couponCode = "CHILL20"

    /// The coupon's discount, as a percentage of the item total.
    static let couponPercent = 20

    /// Tax, as a percentage of the item total. ₹560 → ₹28.
    static let taxRate = 5
}
