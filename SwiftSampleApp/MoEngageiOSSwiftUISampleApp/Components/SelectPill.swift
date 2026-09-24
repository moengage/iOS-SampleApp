//
//  SelectPill.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A selectable pill — one of a set, where exactly one is chosen.
//
//  The third pill in this design system, and the three are not
//  interchangeable:
//
//  - `TabPill` switches what is listed. Selected fills with the brand colour.
//  - `FilterPill` narrows a list. Selected fills neutral grey.
//  - `SelectPill` chooses an option that changes a price. Selected takes a pale
//    brand tint with a brand border, matching `SelectCard`, because the two
//    appear together as parts of one choice.
//

import SwiftUI

struct SelectPill: View {

    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .brewTextStyle(isSelected ? .bodyMedium : .body)
                .foregroundColor(BrewColor.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? BrewColor.primarySelectedTint : BrewColor.surface)
                .clipShape(Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            isSelected ? BrewColor.primary : BrewColor.borderSubtle,
                            lineWidth: 1
                        )
                )
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    HStack(spacing: 8) {
        SelectPill(label: "Dairy", isSelected: false, action: {})
        SelectPill(label: "Oat +₹30", isSelected: true, action: {})
    }
    .padding(BrewSize.screenPadding)
    .background(BrewColor.pageBackground)
}
