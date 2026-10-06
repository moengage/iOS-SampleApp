//
//  FilterPill.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A list filter's pill.
//
//  Distinct from `TabPill` despite the similar shape: a selected filter takes a
//  neutral grey fill and keeps its dark label, where a selected tab takes the
//  brand colour and reverses its label. The two are not interchangeable.
//

import SwiftUI

struct FilterPill: View {

    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .brewTextStyle(.captionMedium)
                .foregroundColor(BrewColor.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? BrewColor.componentFill : BrewColor.surface)
                .clipShape(Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            isSelected ? Color.clear : BrewColor.borderDefault,
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
        FilterPill(label: "Popular", isSelected: true, action: {})
        FilterPill(label: "Under ₹200", isSelected: false, action: {})
    }
    .padding(BrewSize.screenPadding)
}
