//
//  OrderStatusView.swift
//  MoEngageiOSSwiftUISampleApp

import SwiftUI

struct OrderStatusView: View {

    let order: Order
    let onMyOrders: () -> Void
    let onBackToMenu: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    progressCard
                    itemsCard
                }
                .padding(BrewSize.screenPadding)
            }

            FooterBar {
                HStack(spacing: 12) {
                    Button("My orders", action: onMyOrders)
                        .buttonStyle(.brewSecondary)

                    Button("Back to menu", action: onBackToMenu)
                        .buttonStyle(.brewPrimary)
                }
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.orderStatus)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(BrewColor.onDarkPrimary)
                .frame(width: BrewSize.statusCircle, height: BrewSize.statusCircle)
                .background(BrewColor.primary)
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text("Order placed")
                .brewTextStyle(.heroHeader)
                .foregroundColor(BrewColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("#\(order.id) · show this at the bar")
                .brewTextStyle(.support)
                .foregroundColor(BrewColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BrewSize.screenPadding)
        .padding(.top, 32)
        .padding(.bottom, 20)
        .background(BrewColor.primaryLightTint)
    }

    // MARK: - Progress

    private var progressCard: some View {
        BrewCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "timer")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(BrewColor.primary)
                        .accessibilityHidden(true)

                    Text("Grinding & brewing")
                        .brewTextStyle(.subtitleMedium)
                        .foregroundColor(BrewColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(order.readyAt)
                        .brewTextStyle(.caption)
                        .foregroundColor(BrewColor.textSecondary)
                }

                ProgressSteps(stage: order.stage)
            }
        }
    }

    // MARK: - Items

    private var itemsCard: some View {
        BrewCard {
            ForEach(Array(order.lines.enumerated()), id: \.element.id) { index, line in
                if index > 0 {
                    ThinDivider()
                }

                DetailRow(
                    label: line.name,
                    value: rupees(line.amount),
                    labelColor: BrewColor.textPrimary
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            ThinDivider()

            HStack {
                Text(order.paidVia)
                    .brewTextStyle(.body)
                    .foregroundColor(BrewColor.textSecondary)

                Spacer(minLength: 12)

                Text(rupees(order.amount))
                    .brewTextStyle(.bodyMedium)
                    .foregroundColor(BrewColor.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            // Tinted so the total reads as a summary of the lines above it
            // rather than as another line.
            .background(BrewColor.pageBackground)
        }
    }
}

// MARK: - Progress bar

/// Four segments filled up to and including the current stage, labelled
/// underneath. Private: only this screen shows an order's progress.
private struct ProgressSteps: View {

    let stage: OrderStage

    private var reached: Int {
        OrderStage.allCases.firstIndex(of: stage) ?? 0
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(Array(OrderStage.allCases.enumerated()), id: \.element.id) { index, _ in
                    RoundedRectangle(cornerRadius: BrewCorner.track, style: .continuous)
                        .fill(index <= reached ? BrewColor.primary : BrewColor.neutralFill)
                        .frame(height: BrewSize.progressSegmentHeight)
                }
            }

            HStack(spacing: 6) {
                ForEach(OrderStage.allCases) { entry in
                    Text(entry.label)
                        .brewTextStyle(.micro)
                        .foregroundColor(
                            entry == stage ? BrewColor.textPrimary : BrewColor.textTertiary
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Order progress")
        .accessibilityValue(stage.label)
    }
}

