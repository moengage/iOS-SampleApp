//
//  PaymentView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Paying for the order.
//
//  MoEngage integration: `Checkout_Started` on arrival, with what is being paid,
//  how it is collected and which coupon applied. Paying itself reports
//  `Order_Placed`, from `OrderState` rather than from here.
//
//  No in-app campaign is requested. The context is set, as everywhere, but
//  interrupting a payment with a modal is the one place a campaign should not
//  appear.
//

import SwiftUI

struct PaymentView: View {

    let bill: Bill
    let fulfilment: Fulfilment

    /// Number of lines in the order.
    let itemsCount: Int

    @Binding var selectedMethodID: String

    let onBack: () -> Void
    let onPay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BrewAppBar(title: "Payment", onBack: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summary
                    methods

                    if let couponCode = bill.couponCode {
                        CouponBanner(code: couponCode, discount: bill.discount)
                    }
                }
                .padding(BrewSize.screenPadding)
            }

            FooterBar {
                Button("Pay \(rupees(bill.toPay))", action: onPay)
                    .buttonStyle(.brewPrimary)
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.payment)
        .onAppear {
            MoEngageSDKHelper.trackCheckoutStarted(
                amount: bill.toPay,
                fulfilment: fulfilment,
                coupon: bill.couponCode
            )
        }
    }

    // MARK: - Summary

    /// Takes the page background rather than a white fill, so it reads as a
    /// restatement of the order rather than as another control.
    private var summary: some View {
        BrewCard(background: BrewColor.pageBackground, padding: 16) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(fulfilment.label) · \(Store.summaryLine)")
                        .brewTextStyle(.caption)
                        .foregroundColor(BrewColor.textSecondary)

                    Text("\(itemsCount) items · ready in \(fulfilment.eta)")
                        .brewTextStyle(.bodyMedium)
                        .foregroundColor(BrewColor.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(rupees(bill.toPay))
                    .brewTextStyle(.titleBoldSmall)
                    .foregroundColor(BrewColor.textPrimary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Methods

    private var methods: some View {
        VStack(spacing: 12) {
            ForEach(OrderCatalogue.paymentMethods) { method in
                MethodRow(
                    method: method,
                    isSelected: method.id == selectedMethodID,
                    action: { selectedMethodID = method.id }
                )
            }
        }
    }
}

// MARK: - Method row

private struct MethodRow: View {

    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RadioDot(isSelected: isSelected)

                Text("\(method.label) · \(method.detail)")
                    .brewTextStyle(.body)
                    .foregroundColor(BrewColor.textPrimary)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// An 18 pt ring. Selection thickens the border until the hole closes to a
/// dot, rather than drawing a separate inner circle.
private struct RadioDot: View {

    let isSelected: Bool

    var body: some View {
        Circle()
            .strokeBorder(
                isSelected ? BrewColor.primary : BrewColor.borderDefault,
                lineWidth: isSelected ? 5 : 1
            )
            .frame(width: 18, height: 18)
    }
}

// MARK: - Coupon

/// Restates the saving already applied to the bill.
private struct CouponBanner: View {

    let code: String
    let discount: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "tag.fill")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(BrewColor.primary)
                .accessibilityHidden(true)

            Text("\(code) applied — you saved \(rupees(discount))")
                .brewTextStyle(.body)
                .foregroundColor(BrewColor.textPrimary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(BrewColor.primaryLightTint)
        .clipShape(
            RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PaymentView(
        bill: Bill(itemTotal: 560, taxes: 28, couponCode: "CHILL20", discount: 112, cupDiscount: 0),
        fulfilment: .pickup,
        itemsCount: 2,
        selectedMethodID: .constant("wallet"),
        onBack: {},
        onPay: {}
    )
}
