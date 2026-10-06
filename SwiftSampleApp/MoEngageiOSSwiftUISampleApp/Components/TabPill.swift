//
//  TabPill.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The category selector's pill. Filled when selected, outlined when not.
//

import SwiftUI

struct TabPill: View {

    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .brewTextStyle(.captionMedium)
                .foregroundColor(isSelected ? BrewColor.onDarkPrimary : BrewColor.textSecondary)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? BrewColor.primary : BrewColor.surface)
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
