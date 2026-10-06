//
//  BackTile.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The outlined square back control, 36 pt with a 10 pt radius.
//
//  The tile itself is smaller than the 44 pt minimum touch target, so the button
//  carries a larger transparent hit area around the visible artwork.
//

import SwiftUI

struct BackTile: View {

    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(BrewColor.textPrimary)
                .frame(width: BrewSize.backTile, height: BrewSize.backTile)
                .overlay(
                    RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
                        .stroke(BrewColor.borderDefault, lineWidth: 1)
                )
                // Extends the tappable area to the 44 pt minimum without
                // enlarging the visible tile.
                .contentShape(Rectangle())
                .frame(width: 44, height: 44, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

#Preview {
    BackTile(action: {})
        .padding(BrewSize.screenPadding)
}
