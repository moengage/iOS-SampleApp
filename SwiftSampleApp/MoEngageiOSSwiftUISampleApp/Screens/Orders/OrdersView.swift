//
//  OrdersView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Order history, and the root of the Orders tab.
//
//  The filters here genuinely filter, unlike the menu's — which are
//  presentation only. Both match the Android sample.
//
//  MoEngage moments:
//  - `Reorder_Tapped` when a past order is sent back to the cart.
//  - The screen is a nudge campaign's target, so it asks for one on arrival.
//    A nudge anchors itself to a position rather than covering the screen, so
//    unlike the menu's modal it is asked for every visit rather than once a
//    session.
//

import SwiftUI

struct OrdersView: View {

    let orders: [Order]

    /// Opens the status screen for an order still in progress.
    let onTrack: (Order) -> Void

    /// Sends a past order back to the cart.
    let onReorder: (Order) -> Void

    /// Opens the self-handled cards screen, where the subscription lives.
    let onSubscribe: () -> Void

    @State private var activeFilter: String = OrderCatalogue.filters[0]

    private var visible: [Order] {
        switch activeFilter {
        case "Pickup": return orders.filter { $0.mode == .pickup }
        case "Delivery": return orders.filter { $0.mode == .delivery }
        default: return orders
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // No back control: this is a tab's root, not a pushed screen.
            BrewAppBar(title: "Your orders", subtitle: OrderCatalogue.headerMeta)

            filters

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(visible) { order in
                        OrderCard(
                            order: order,
                            onTrack: { onTrack(order) },
                            onReorder: { onReorder(order) }
                        )
                    }

                    SubscriptionNudge(onSetUp: onSubscribe)
                }
                .padding(.horizontal, BrewSize.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.orders)
        .onAppear {
            MoEngageSDKHelper.showNudge()
        }
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OrderCatalogue.filters, id: \.self) { filter in
                    FilterPill(
                        label: filter,
                        isSelected: filter == activeFilter,
                        action: { activeFilter = filter }
                    )
                }
            }
            .padding(.horizontal, BrewSize.screenPadding)
            .padding(.vertical, 12)
        }
        .background(BrewColor.surface)
    }
}

// MARK: - Order card

private struct OrderCard: View {

    let order: Order
    let onTrack: () -> Void
    let onReorder: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: BrewCorner.card, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Marks an order still in progress. Drawn as part of the row so it
            // runs the card's full height whatever the content.
            if order.active {
                BrewColor.primary
                    .frame(width: BrewSize.activeStripe)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("#\(order.id) · \(order.placedAt)")
                        .brewTextStyle(.bodyMedium)
                        .foregroundColor(BrewColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if order.active {
                        StatusPill(label: "Brewing")
                    }
                }

                Text(order.lines.map(\.name).joined(separator: ", "))
                    .brewTextStyle(.support)
                    .foregroundColor(BrewColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Text(rupees(order.amount))
                        .brewTextStyle(.subtitleBold)
                        .foregroundColor(BrewColor.textPrimary)

                    Spacer(minLength: 8)

                    if order.active {
                        OrderAction(label: "Track", isFilled: false, action: onTrack)
                    } else {
                        OrderAction(label: "Reorder", isFilled: true, action: onReorder)
                    }
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .background(BrewColor.surface)
        .clipShape(shape)
        .overlay(shape.stroke(BrewColor.borderSubtle, lineWidth: 1))
    }
}

/// The card's one action — filled to reorder, outlined to track.
private struct OrderAction: View {

    let label: String
    let isFilled: Bool
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: BrewCorner.chip, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .brewTextStyle(.captionMedium)
                .foregroundColor(isFilled ? BrewColor.onDarkPrimary : BrewColor.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isFilled ? BrewColor.primary : BrewColor.surface)
                .clipShape(shape)
                .overlay(
                    shape.stroke(
                        isFilled ? Color.clear : BrewColor.borderDefault,
                        lineWidth: 1
                    )
                )
                .contentShape(shape)
        }
        .buttonStyle(.plain)
    }
}

/// The green "Brewing" pill.
private struct StatusPill: View {

    let label: String

    var body: some View {
        Text(label)
            .brewTextStyle(.microMedium)
            .foregroundColor(BrewColor.successText)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(BrewColor.successTint)
            .clipShape(Capsule(style: .continuous))
    }
}

// MARK: - Subscription

/// The dashed card closing the list.
///
/// Dashed rather than solid to read as an offer rather than as another order —
/// drawn with a stroke style, since no shared card supports a dashed border.
private struct SubscriptionNudge: View {

    let onSetUp: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            IconTile(systemImage: "cup.and.saucer", size: 40)

            Text(OrderCatalogue.subscriptionNudge)
                .brewTextStyle(.support)
                .foregroundColor(BrewColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onSetUp) {
                Text("Set up")
                    .brewTextStyle(.captionMedium)
                    .foregroundColor(BrewColor.link)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: BrewCorner.card, style: .continuous)
                .strokeBorder(
                    BrewColor.borderDefault,
                    style: StrokeStyle(lineWidth: 1, dash: [12, 10])
                )
        )
    }
}

#Preview {
    OrdersView(
        orders: OrderCatalogue.all(),
        onTrack: { _ in },
        onReorder: { _ in },
        onSubscribe: {}
    )
}
