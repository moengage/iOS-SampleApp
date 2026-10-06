//
//  FooterBar.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The pinned action bar at the bottom of a screen: a rule, then content on a
//  white surface.
//
//  Placed outside the screen's scroll view so it stays put while the content
//  moves, which is what makes the action reachable however long the page is.
//

import SwiftUI

struct FooterBar<Content: View>: View {

    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            ThinDivider()

            content()
                .padding(.horizontal, BrewSize.screenPadding)
                .padding(.top, 14)
                .padding(.bottom, 18)
        }
        .background(BrewColor.surface)
    }
}

#Preview {
    VStack {
        Spacer()
        FooterBar {
            Button("Add · ₹250", action: {})
                .buttonStyle(.brewPrimary)
        }
    }
    .background(BrewColor.pageBackground)
}
