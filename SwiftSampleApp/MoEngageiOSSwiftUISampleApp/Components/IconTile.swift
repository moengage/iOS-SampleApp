//
//  IconTile.swift
//  MoEngageiOSSwiftUISampleApp
//
//  A rounded square holding a single symbol — the recurring "tile" in this
//  design.
//

import SwiftUI

struct IconTile: View {

    private let systemImage: String
    private let size: CGFloat
    private let symbolSize: CGFloat
    private let background: Color
    private let tint: Color

    init(
        systemImage: String,
        size: CGFloat = BrewSize.iconTile,
        symbolSize: CGFloat = 20,
        background: Color = BrewColor.primaryLightTint,
        tint: Color = BrewColor.primary
    ) {
        self.systemImage = systemImage
        self.size = size
        self.symbolSize = symbolSize
        self.background = background
        self.tint = tint
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: symbolSize, weight: .regular))
            .foregroundColor(tint)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
            )
            // Decorative: the surrounding row always carries the meaning.
            .accessibilityHidden(true)
    }
}

#Preview {
    IconTile(systemImage: "cup.and.saucer")
        .padding(BrewSize.screenPadding)
}
