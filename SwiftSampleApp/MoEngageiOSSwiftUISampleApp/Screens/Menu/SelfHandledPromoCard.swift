//
//  SelfHandledPromoCard.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A self-handled in-app campaign, drawn by the app rather than the SDK.
//
//  The SDK returns a payload with no presentation; this card renders it as a
//  dark, single-row card above the section header, dismissible without being
//  tapped.
//
//  MoEngage integration, all reported by the caller rather than this view:
//  - Shown, the moment it appears.
//  - Clicked, if tapped — which also resolves where it leads.
//  - Dismissed, if closed instead.
//

import SwiftUI

struct SelfHandledPromoCard: View {

    let payload: PromoPayload

    /// Reports the tap and resolves the deep link it leads to, if any.
    let onTap: () -> Void

    /// Reports the dismissal.
    let onDismiss: () -> Void

    var body: some View {
        BrewCard(
            background: BrewColor.primaryDarkSurface,
            borderColor: .clear,
            padding: 14
        ) {
            HStack(alignment: .top, spacing: 12) {
                IconTile(
                    systemImage: "tag.fill",
                    background: BrewColor.onDarkSecondary.opacity(0.16),
                    tint: BrewColor.onDarkPrimary
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(payload.title)
                        .brewTextStyle(.bodyMedium)
                        .foregroundColor(BrewColor.onDarkPrimary)

                    Text(payload.subtitle)
                        .brewTextStyle(.caption)
                        .foregroundColor(BrewColor.onDarkSecondary)
                }

                Spacer(minLength: 8)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(BrewColor.onDarkSecondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
        }
    }
}

#Preview {
    SelfHandledPromoCard(
        payload: .fallback,
        onTap: {},
        onDismiss: {}
    )
    .padding(BrewSize.screenPadding)
    .background(BrewColor.pageBackground)
}
