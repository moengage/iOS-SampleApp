//
//  CartState.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The order: its lines and how it is to be collected.
//
//  The first state in this app that outlives a screen. The catalogue is fixed
//  and the menu's category is a presentation choice, but an order is built on
//  one screen, read on another and paid for on a third — so it belongs to
//  something that spans them.
//
//  The bill is computed rather than stored. A total kept alongside the lines
//  would be a second source of truth, and the two would eventually disagree.
//

import Foundation

@MainActor
final class CartState: ObservableObject {

    /// The order's lines. Starts seeded — see `CartCatalogue`.
    @Published private(set) var lines: [CartLine] = CartCatalogue.seedLines()

    @Published var fulfilment: Fulfilment = .pickup

    @Published var cupPreference: CupPreference = .ownCup

    /// What the order currently costs.
    ///
    /// Derived on every read, so it cannot fall out of step with the lines.
    var bill: Bill {
        let itemTotal = lines.reduce(0) { $0 + $1.amount * $1.quantity }
        let taxes = Int((Double(itemTotal * CartCatalogue.taxRate) / 100).rounded())
        let discount = Int((Double(itemTotal * CartCatalogue.couponPercent) / 100).rounded())

        return Bill(
            itemTotal: itemTotal,
            taxes: taxes,
            couponCode: CartCatalogue.couponCode,
            discount: discount,
            // The design's bill totals ₹476 with "bring my own cup" selected,
            // so the cup preference is recorded but not billed. Kept explicit
            // rather than silently dropped — the pill still advertises the
            // saving, and this is the line that declines to apply it.
            cupDiscount: 0
        )
    }

    /// Appends a configured item to the order.
    func add(_ line: CartLine) {
        lines.append(line)
    }

    /// Returns the basket to its starting contents, for a new session.
    func reset() {
        lines = CartCatalogue.seedLines()
        fulfilment = .pickup
        cupPreference = .ownCup
    }
}

// MARK: - Building a line

extension CartLine {

    /// Builds a line from an item and the choices made on its detail screen.
    ///
    /// The identifier combines the item with its configuration, so the same
    /// drink ordered two ways is two lines rather than one overwriting the
    /// other.
    init(item: MenuItem, selection: ItemSelection) {
        self.init(
            id: "\(item.id)-\(selection.size)-\(selection.milk)",
            itemID: item.id,
            name: "\(item.name) · \(selection.size.lowercased())",
            options: ([selection.milk + " milk"] + selection.addOns).joined(separator: " · "),
            amount: selection.amount,
            quantity: selection.quantity,
            image: item.image
        )
    }
}
