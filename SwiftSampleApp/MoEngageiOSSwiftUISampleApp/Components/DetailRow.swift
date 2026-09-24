//
//  DetailRow.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A label on the left and a value on the right — the row a bill, an order
//  summary and a profile's details are all built from.
//
//  The styling is parameterised because the same row carries both an ordinary
//  line and an emphasised total.
//

import SwiftUI

struct DetailRow: View {

    let label: String
    let value: String

    var labelStyle: BrewTextStyle = .body
    var labelColor: Color = BrewColor.textSecondary
    var valueStyle: BrewTextStyle = .bodyMedium
    var valueColor: Color = BrewColor.textPrimary

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .brewTextStyle(labelStyle)
                .foregroundColor(labelColor)

            Spacer(minLength: 0)

            Text(value)
                .brewTextStyle(valueStyle)
                .foregroundColor(valueColor)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 10) {
        DetailRow(label: "Item total", value: "₹560")
        DetailRow(
            label: "CHILL20 discount",
            value: "−₹112",
            valueColor: BrewColor.successText
        )
        DetailRow(
            label: "To pay",
            value: "₹476",
            labelStyle: .cardTitle,
            labelColor: BrewColor.textPrimary,
            valueStyle: .cardTitleBold
        )
    }
    .padding(BrewSize.screenPadding)
}
