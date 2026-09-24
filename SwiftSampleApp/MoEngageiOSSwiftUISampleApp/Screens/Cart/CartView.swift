//
//  CartView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The order, before paying for it.
//
//  Lines are shown, not edited. The model carries a quantity and the bill
//  multiplies by it, but this screen offers no way to change one, remove a line
//  or empty the order — matching the Android sample, whose design has none of
//  those controls either.
//
//  MoEngage moment: `Cart_Viewed` on arrival, with the number of lines and what
//  the order comes to. `Add_To_Cart` was already reported by the item screen
//  that put each line here, and `Checkout_Started` belongs to payment — so this
//  screen reports arrival and nothing else.
//
//  No in-app campaign is requested here. The context is set, as on every
//  screen, but only the menu, an item and the order history ask for one.
//

import SwiftUI

struct CartView: View {

    @ObservedObject var cart: CartState

    let onBack: () -> Void

    /// Returns to the menu to add more. Android goes to the list for the
    /// category last browsed rather than to the menu itself.
    let onAddAnother: () -> Void

    let onProceed: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BrewAppBar(title: "Your order", onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    fulfilmentOptions
                    lines
                    BillCard(bill: cart.bill)
                    cupOptions
                }
                .padding(BrewSize.screenPadding)
            }

            footer
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.cart)
        .onAppear {
            MoEngageSDKHelper.trackCartViewed(lines: cart.lines, amount: cart.bill.toPay)
        }
    }

    // MARK: - Fulfilment

    private var fulfilmentOptions: some View {
        HStack(spacing: 12) {
            ForEach(Fulfilment.allCases) { option in
                SelectCard(
                    title: option.label,
                    subtitle: option.eta,
                    isSelected: option == cart.fulfilment,
                    action: { cart.fulfilment = option }
                )
            }
        }
    }

    // MARK: - Lines

    private var lines: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(cart.lines) { line in
                CartLineRow(line: line)
            }

            Button(action: onAddAnother) {
                Text("+ Add another item")
                    .brewTextStyle(.supportMedium)
                    .foregroundColor(BrewColor.link)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Cup

    private var cupOptions: some View {
        // Scrollable for the same reason as the menu's pills: the two labels
        // together overflow the width at large content sizes.
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CupPreference.allCases) { option in
                    SelectPill(
                        label: Self.cupLabel(for: option),
                        isSelected: option == cart.cupPreference,
                        action: { cart.cupPreference = option }
                    )
                }
            }
            .padding(.horizontal, BrewSize.screenPadding)
        }
        .padding(.horizontal, -BrewSize.screenPadding)
    }

    /// Advertises the saving on the option that has one.
    ///
    /// The saving is not actually applied to the bill — see `CartState.bill`.
    private static func cupLabel(for option: CupPreference) -> String {
        option.discount > 0 ? "\(option.label) · −₹\(option.discount)" : option.label
    }

    // MARK: - Footer

    private var footer: some View {
        FooterBar {
            Button("Proceed to pay · \(rupees(cart.bill.toPay))", action: onProceed)
                .buttonStyle(.brewPrimary)
        }
    }
}

// MARK: - Bill

/// The order's cost, broken down. Private: only the cart shows a bill this way.
private struct BillCard: View {

    let bill: Bill

    var body: some View {
        BrewCard(padding: 16) {
            VStack(spacing: 10) {
                DetailRow(label: "Item total", value: rupees(bill.itemTotal))
                DetailRow(label: "Taxes", value: rupees(bill.taxes))

                if let couponCode = bill.couponCode {
                    DetailRow(
                        label: "\(couponCode) discount",
                        value: "−\(rupees(bill.discount))",
                        valueColor: BrewColor.successText
                    )
                }

                if bill.cupDiscount > 0 {
                    DetailRow(
                        label: "Own cup",
                        value: "−\(rupees(bill.cupDiscount))",
                        valueColor: BrewColor.successText
                    )
                }

                ThinDivider()

                DetailRow(
                    label: "To pay",
                    value: rupees(bill.toPay),
                    labelStyle: .cardTitle,
                    labelColor: BrewColor.textPrimary,
                    valueStyle: .cardTitleBold
                )
            }
        }
    }
}

// MARK: - Line

/// One line of the order. Private: nothing else lists an order's contents.
private struct CartLineRow: View {

    let line: CartLine

    var body: some View {
        HStack(spacing: 12) {
            CoverImage(line.image)
                .frame(width: BrewSize.cartThumb, height: BrewSize.cartThumb)
                .background(BrewColor.neutralFill)
                .clipShape(
                    RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(line.name)
                    .brewTextStyle(.bodyMedium)
                    .foregroundColor(BrewColor.textPrimary)

                Text(line.options)
                    .brewTextStyle(.caption)
                    .foregroundColor(BrewColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(rupees(line.amount * line.quantity))
                .brewTextStyle(.bodyMedium)
                .foregroundColor(BrewColor.textPrimary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CartView(
        cart: CartState(),
        onBack: {},
        onAddAnother: {},
        onProceed: {}
    )
}
