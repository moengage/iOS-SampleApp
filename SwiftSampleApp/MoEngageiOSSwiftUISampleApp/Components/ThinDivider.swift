//
//  ThinDivider.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A one-point rule.
//
//  SwiftUI's `Divider` takes its thickness and colour from the platform and
//  cannot be set to an exact value, so the rule is drawn directly.
//

import SwiftUI

struct ThinDivider: View {

    private let color: Color

    init(color: Color = BrewColor.borderSubtle) {
        self.color = color
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
    }
}

