//
//  FeaturedCard.swift
//  MoEngageiOSSwiftUISampleApp
//
//  One cell of the featured grid: an image banner over the name, note and price.
//
//  The two cards in a row are given a common height by the grid, so the note is
//  capped at two lines and the text block is bottom-padded rather than centred.
//  A one-line note and a two-line note then still align.
//

import SwiftUI

struct FeaturedCard: View {

    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BrewCard {
                CoverImage(item.image)
                    .aspectRatio(BrewSize.featuredImageAspect, contentMode: .fit)
                    .background(BrewColor.neutralFill)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .brewTextStyle(.bodyMedium)
                        .foregroundColor(BrewColor.textPrimary)
                        .lineLimit(1)

                    Text(item.note)
                        .brewTextStyle(.micro)
                        .foregroundColor(BrewColor.textSecondary)
                        .lineLimit(2)
                        // Holds two lines' worth of space even for a one-line
                        // note, so the price sits at the same height on both
                        // cards of a row.
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                    Text(rupees(item.price))
                        .brewTextStyle(.bodyBold)
                        .foregroundColor(BrewColor.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

