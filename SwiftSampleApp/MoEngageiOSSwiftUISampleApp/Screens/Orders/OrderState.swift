//
//  OrderState.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The most recent order, and how the next one will be paid for.
//
//  Spans three screens: payment reads the method, placing an order writes the
//  record, and both the status screen and the history list read it back.
//
//  MoEngage integration: `Order_Placed` is reported from `placeOrder`, not
//  from a screen. Placing an order is the thing being reported, and it happens
//  here; reporting it from the screen that navigated away afterwards would tie
//  the event to a view's lifecycle instead of to the action.
//

import Foundation

@MainActor
final class OrderState: ObservableObject {

    /// The order placed most recently. Seeded so the history and status
    /// screens have something to show before anything is bought.
    @Published private(set) var lastOrder: Order = OrderCatalogue.latest()

    @Published var paymentMethodID: String = OrderCatalogue.defaultPaymentMethodID

    /// Turns the current basket into an order, and reports it.
    ///
    /// Modelled on the seeded order rather than built from nothing, so it
    /// keeps a plausible identifier, timestamp and ready time — the sample has
    /// no backend to issue them.
    @discardableResult
    func placeOrder(from cart: CartState) -> Order {
        let order = Order(
            id: lastOrder.id,
            placedAt: lastOrder.placedAt,
            lines: cart.lines.map { OrderLine(name: $0.name, amount: $0.amount) },
            amount: cart.bill.toPay,
            mode: cart.fulfilment,
            stage: .brewing,
            readyAt: lastOrder.readyAt,
            paidVia: lastOrder.paidVia,
            active: true
        )

        lastOrder = order
        MoEngageSDKHelper.trackOrderPlaced(order)
        return order
    }

    /// Resolves an identifier to an order, preferring the one just placed.
    ///
    /// The placed order is not in the catalogue — it replaced the seed of the
    /// same identifier in memory only — so it has to be checked first, or the
    /// status screen would show the stale seeded version of what was just
    /// bought.
    func order(id: String) -> Order {
        id == lastOrder.id ? lastOrder : OrderCatalogue.order(id: id)
    }

    /// Forgets what this session ordered, for a new one.
    func reset() {
        lastOrder = OrderCatalogue.latest()
        paymentMethodID = OrderCatalogue.defaultPaymentMethodID
    }
}
