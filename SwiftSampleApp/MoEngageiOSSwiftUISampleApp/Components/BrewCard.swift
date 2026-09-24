//
//  BrewCard.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The house card: white, 14 pt radius, a 1 pt border and no shadow.
//
//  Elevation in this design is carried entirely by the border, so the card never
//  draws a shadow.
//

import SwiftUI

struct BrewCard<Content: View>: View {

    private let cornerRadius: CGFloat
    private let background: Color
    private let borderColor: Color
    private let contentPadding: EdgeInsets
    private let content: () -> Content

    init(
        cornerRadius: CGFloat = BrewCorner.card,
        background: Color = BrewColor.surface,
        borderColor: Color = BrewColor.borderSubtle,
        contentPadding: EdgeInsets = EdgeInsets(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.background = background
        self.borderColor = borderColor
        self.contentPadding = contentPadding
        self.content = content
    }

    /// Uniform padding on all four edges.
    init(
        cornerRadius: CGFloat = BrewCorner.card,
        background: Color = BrewColor.surface,
        borderColor: Color = BrewColor.borderSubtle,
        padding: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            cornerRadius: cornerRadius,
            background: background,
            borderColor: borderColor,
            contentPadding: EdgeInsets(
                top: padding,
                leading: padding,
                bottom: padding,
                trailing: padding
            ),
            content: content
        )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(contentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        // Clipped before the border is stroked, so content that fills the card
        // — an image banner — is cut to the same corners.
        .clipShape(shape)
        .overlay(shape.stroke(borderColor, lineWidth: 1))
    }
}
