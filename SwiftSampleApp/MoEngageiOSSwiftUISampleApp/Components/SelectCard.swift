//
//  SelectCard.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A selectable card carrying a title and a supporting line — one of a set,
//  where exactly one is chosen.
//
//  Selection is shown three ways at once: a tinted fill, a brand-coloured
//  border and a heavier title. Colour alone would not be enough for someone who
//  cannot distinguish it.
//

import SwiftUI

struct SelectCard: View {

    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .brewTextStyle(isSelected ? .bodyMedium : .body)
                    .foregroundColor(BrewColor.textPrimary)

                Text(subtitle)
                    .brewTextStyle(.micro)
                    .foregroundColor(BrewColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(isSelected ? BrewColor.primarySelectedTint : BrewColor.surface)
            .clipShape(shape)
            .overlay(
                shape.stroke(
                    isSelected ? BrewColor.primary : BrewColor.borderSubtle,
                    lineWidth: 1
                )
            )
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    HStack(spacing: 8) {
        SelectCard(title: "Small", subtitle: "180 ml", isSelected: false, action: {})
        SelectCard(title: "Medium", subtitle: "240 ml +₹20", isSelected: true, action: {})
    }
    .padding(BrewSize.screenPadding)
    .background(BrewColor.pageBackground)
}
