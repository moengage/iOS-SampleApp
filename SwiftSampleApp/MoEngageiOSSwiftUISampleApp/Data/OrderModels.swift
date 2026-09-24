//
//  OrderModels.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A placed order, and how it was paid for.
//

import Foundation

/// How far along an order is. Declaration order is progress order — the status
/// screen fills its bar up to and including the current stage.
enum OrderStage: String, CaseIterable, Identifiable {

    case received
    case brewing
    case atTheBar
    case pickedUp

    var id: String { rawValue }

    var label: String {
        switch self {
        case .received: return "Received"
        case .brewing: return "Brewing"
        case .atTheBar: return "At the bar"
        case .pickedUp: return "Picked up"
        }
    }
}

/// One line of a placed order. Unlike a `CartLine` this is a record, not
/// something that can still be configured, so it carries only what is shown.
struct OrderLine: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let amount: Int
}

struct Order: Identifiable, Hashable {

    let id: String

    /// When it was placed, as displayed — "Today, 8:34 am".
    let placedAt: String

    let lines: [OrderLine]

    /// What was paid, in whole rupees.
    let amount: Int

    let mode: Fulfilment
    let stage: OrderStage

    /// When it will be, or was, collected — "ready ~ 8:42 am".
    let readyAt: String

    let paidVia: String

    /// In progress. An active order is tracked rather than reordered, and is
    /// marked in the history list.
    let active: Bool

    /// Number of lines, not total quantity. Reported as `items_count`.
    var itemsCount: Int { lines.count }

    init(
        id: String,
        placedAt: String,
        lines: [OrderLine],
        amount: Int,
        mode: Fulfilment,
        stage: OrderStage,
        readyAt: String,
        paidVia: String,
        active: Bool = false
    ) {
        self.id = id
        self.placedAt = placedAt
        self.lines = lines
        self.amount = amount
        self.mode = mode
        self.stage = stage
        self.readyAt = readyAt
        self.paidVia = paidVia
        self.active = active
    }
}

/// A notification, as it would appear if one arrived.
///
/// Not a real notification. A campaign would deliver this through the system,
/// but that needs a configured campaign and a push token, so the sample draws
/// its own so the flow can be shown on any device — matching the Android
/// sample, whose text this is.
struct SimulatedPush: Equatable {
    let title: String
    let body: String
    var timestamp: String = "Brew Bar · now"

    /// Where tapping it leads.
    let deeplink: String
}

/// A way to pay.
struct PaymentMethod: Identifiable, Hashable {
    let id: String
    let label: String

    /// The balance or account shown beside the name.
    let detail: String
}
