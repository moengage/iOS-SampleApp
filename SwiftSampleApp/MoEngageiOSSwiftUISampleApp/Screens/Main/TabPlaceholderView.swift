//
//  TabPlaceholderView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Stands in for a tab whose screen is not implemented in this sample.
//

import SwiftUI

struct TabPlaceholderView: View {

    let tab: BrewTab

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: tab.systemImage)
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(BrewColor.textTertiary)

            Text(tab.title)
                .brewTextStyle(.screenTitleSmall)
                .foregroundColor(BrewColor.textPrimary)

            Text("Coming next.")
                .brewTextStyle(.caption)
                .foregroundColor(BrewColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrewColor.pageBackground.ignoresSafeArea())
    }
}

#Preview {
    TabPlaceholderView(tab: .menu)
}
