//
//  SectionHeader.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A section title with an optional trailing text action.
//

import SwiftUI

struct SectionHeader: View {

    let title: String

    /// The trailing action's label. Pass `nil` for a title-only header.
    var actionLabel: String?

    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .brewTextStyle(.cardTitle)
                .foregroundColor(BrewColor.textPrimary)
                // Reads as a heading to VoiceOver, so the section can be
                // navigated to directly.
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .brewTextStyle(.captionMedium)
                        .foregroundColor(BrewColor.link)
                        // The label alone is shorter than the minimum touch
                        // target, so the padding is part of the hit area.
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    SectionHeader(title: "Coffee · hot & cold", actionLabel: "Full menu", action: {})
        .padding(BrewSize.screenPadding)
}
