//
//  MenuRow.swift
//  MoEngageiOSSwiftUISampleApp
//
//  One row of the category list.
//
//  A fixed height, because the design's rows are uniform and the image fills
//  the row from top to bottom. The note is capped at two lines so a long one
//  can never push the row taller, which keeps the price and the add control on
//  a common baseline down the list.
//

import SwiftUI

struct MenuRow: View {

    let item: MenuItem
    let onSelect: () -> Void
    let onAdd: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                CoverImage(item.image)
                    .frame(width: BrewSize.listRowImageWidth)
                    .background(BrewColor.neutralFill)

                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .brewTextStyle(.bodyMedium)
                            .foregroundColor(BrewColor.textPrimary)
                            .lineLimit(1)

                        Text(item.note)
                            .brewTextStyle(.caption)
                            .foregroundColor(BrewColor.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 8)

                    HStack {
                        Text(rupees(item.price))
                            .brewTextStyle(.subtitleBold)
                            .foregroundColor(BrewColor.textPrimary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        AddPill(action: onAdd)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .frame(height: BrewSize.listRowHeight)
            .background(BrewColor.surface)
            .clipShape(
                RoundedRectangle(cornerRadius: BrewCorner.card, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BrewCorner.card, style: .continuous)
                    .stroke(BrewColor.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        // The row's texts read as one element; the add control stays separate,
        // because it is a second action rather than part of the description.
        .accessibilityElement(children: .contain)
    }
}

/// The outlined "Add" chip at the end of a row.
///
/// Private to this file: nothing outside the category list uses it, so it is
/// not a shared component.
private struct AddPill: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Add")
                .brewTextStyle(.captionMedium)
                .foregroundColor(BrewColor.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: BrewCorner.chip, style: .continuous)
                        .stroke(BrewColor.borderDefault, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuRow(item: MenuCatalogue.item(id: "flat-white"), onSelect: {}, onAdd: {})
        .padding(BrewSize.screenPadding)
        .background(BrewColor.pageBackground)
}
