//
//  SplashView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Brand introduction screen, and the first screen presented at launch.
//
//  The MoEngage SDK is initialised in
//  `AppDelegate.application(_:didFinishLaunchingWithOptions:)`, before this view
//  is built. The footnote records that, as the sample is intended to make each
//  SDK integration point visible.
//
//  The view holds no state and performs no side effects. It accepts a single
//  closure and has no knowledge of navigation, which keeps it independently
//  previewable and testable.
//

import SwiftUI

struct SplashView: View {

    /// Invoked by the primary call to action. The caller decides the destination.
    let onGetStarted: () -> Void

    var body: some View {
        ZStack {
            // Base fill. The artwork is composited over it, so both extend past
            // the safe area while the content below does not.
            BrewColor.primaryDarkSurface
                .ignoresSafeArea()

            // Dimmed so the copy above remains legible.
            CoverImage("SplashBackground")
                .opacity(0.45)
                .ignoresSafeArea()

            content
        }
        .inAppContext(.splash)
    }

    // MARK: - Content

    /// The brand block is pinned to the top and the action block to the bottom;
    /// the spacer absorbs the remaining height.
    private var content: some View {
        VStack(spacing: 0) {
            brandBlock
            Spacer(minLength: 16)
            actionBlock
        }
    }

    private var brandBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            brandTile

            Text("Brew Bar")
                .brewTextStyle(.display)
                .foregroundColor(BrewColor.onDarkPrimary)

            Text("Slow-roast coffee, herbal brews and fresh bakes — ordered before you reach the counter.")
                .brewTextStyle(.subtitle)
                .foregroundColor(BrewColor.onDarkSecondary)
                // Caps the measure so the copy wraps at a comfortable line length.
                .frame(maxWidth: 260, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.top, 56)
    }

    /// Rounded brand tile with the product glyph centred inside it.
    private var brandTile: some View {
        Image(systemName: "cup.and.saucer.fill")
            .font(.system(size: 22))
            .foregroundColor(BrewColor.onDarkPrimary)
            .frame(width: BrewSize.brandTile, height: BrewSize.brandTile)
            .background(BrewColor.primary)
            .clipShape(
                RoundedRectangle(cornerRadius: BrewCorner.card, style: .continuous)
            )
            // Decorative: the wordmark alongside already names the product.
            .accessibilityHidden(true)
    }

    private var actionBlock: some View {
        VStack(spacing: 12) {
            Button("Get started", action: onGetStarted)
                .buttonStyle(.brewPrimary)

            Text("MoEngage SDK initialised in AppDelegate")
                .brewTextStyle(.caption)
                .foregroundColor(BrewColor.onDarkFootnote)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, BrewSize.screenPadding)
        .padding(.bottom, 28)
    }
}

