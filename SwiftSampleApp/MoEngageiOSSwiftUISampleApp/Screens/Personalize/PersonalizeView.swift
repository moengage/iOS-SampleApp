//
//  PersonalizeView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Personalized offers, picked by MoEngage and drawn by the app.
//
//  A fetch answers in one of two shapes and this screen renders both: a
//  campaign whose payload carries offerings, drawn as cards, or one that
//  carries none — nothing configured, no eligible campaign, a user outside the
//  segment, or a campaign deliberately built without any — which falls back to
//  a panel written from the campaign's own copy rather than a blank screen.
//
//  The Rewards tab is always that second shape by design. The tabs re-fetch
//  different experience keys rather than switching local fixtures, so each one
//  exercises the real SDK round trip.
//
//  MoEngage integration: an experience impression once per answer, an offering
//  impression once per card drawn, and an offering click on tap.
//

import SwiftUI

struct PersonalizeView: View {

    @ObservedObject var state: PersonalizeState

    let onBack: () -> Void

    /// Follows an offer's deep link. The screen does not navigate itself —
    /// it does not know where it sits in the hierarchy.
    let onFollow: (URL) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    content
                }
                .padding(.horizontal, BrewSize.screenPadding)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.personalize)
        .task { state.onAppear() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if state.isLoading && !state.hasFetched {
            // Only before the first answer. A tab switch keeps the previous
            // cards in place rather than flashing a spinner between them.
            ProgressView()
                .tint(BrewColor.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
        } else if state.offers.isEmpty {
            NoOffersPanel(copy: state.fallbackCopy, demoState: state.demoState)
        } else {
            Text("Picked for you")
                .brewTextStyle(.cardTitle)
                .foregroundColor(BrewColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            ForEach(state.offers) { offer in
                OfferCard(offer: offer) {
                    if let url = state.offerTapped(offer) {
                        onFollow(url)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                BackTile(action: onBack)

                Text("Personalize")
                    .brewTextStyle(.cardTitle)
                    .foregroundColor(BrewColor.onDarkPrimary)
            }

            Text(
                "Offers picked for you from your orders and loyalty tier — "
                    + "each tab asks MoEngage a different question."
            )
            .brewTextStyle(.caption)
            .foregroundColor(BrewColor.onDarkSecondary)
            .fixedSize(horizontal: false, vertical: true)

            // Scrolls horizontally so each label keeps its natural width
            // instead of being squeezed by its siblings on a narrow screen.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(OfferDemoState.allCases) { demo in
                        TabPill(
                            label: demo.label,
                            isSelected: demo == state.demoState,
                            action: { state.select(demo) }
                        )
                    }
                }
            }
        }
        .padding(BrewSize.screenPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrewColor.primaryDarkSurface)
    }
}

// MARK: - Offer card

/// One offering. Everything but the title is optional, so a partly authored
/// offering still draws rather than disappearing.
private struct OfferCard: View {

    let offer: PersonalizedOffer
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BrewCard(padding: 14) {
                HStack(spacing: 12) {
                    thumbnail

                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer.title)
                            .brewTextStyle(.bodyMedium)
                            .foregroundColor(BrewColor.textPrimary)
                            .multilineTextAlignment(.leading)

                        if !offer.subtitle.isEmpty {
                            Text(offer.subtitle)
                                .brewTextStyle(.caption)
                                .foregroundColor(BrewColor.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(offer.ctaLabel)
                        .brewTextStyle(.captionMedium)
                        .foregroundColor(BrewColor.link)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(offer.ctaLabel)
    }

    /// The offering's own artwork, or the house tile when it carries none.
    ///
    /// Remote and campaign-authored, so it may be slow, missing or wrong — the
    /// tile stands in for every one of those rather than leaving a gap.
    @ViewBuilder
    private var thumbnail: some View {
        if let url = offer.imageURL {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                BrewColor.neutralFill
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous))
            .accessibilityHidden(true)
        } else {
            IconTile(systemImage: "tag", size: 48)
        }
    }
}

// MARK: - No offers

/// The no-offerings state: nothing configured, nothing eligible, or — on the
/// Rewards tab — a campaign built with no Offering and no Decision Policy at
/// all.
///
/// The wording comes from the campaign's own `title` and `message` KV pairs, so
/// the dashboard owns this panel the way it owns the cards: a campaign with
/// nothing to offer can still say why. The strings below are this app's
/// defaults for when it carries neither, or never arrived — themed per tab,
/// since "no offer right now" and "here is how to earn rewards" read very
/// differently. Anything wiring this up for real should do the same: show its
/// own default, never an empty screen.
private struct NoOffersPanel: View {

    let copy: ExperienceCopy
    let demoState: OfferDemoState

    private var isRewards: Bool { demoState == .rewards }

    var body: some View {
        BrewCard(padding: 18) {
            VStack(spacing: 10) {
                IconTile(
                    systemImage: isRewards ? "gift" : "magnifyingglass",
                    size: BrewSize.iconTile,
                    background: BrewColor.neutralFill,
                    tint: BrewColor.textTertiary
                )

                Text(copy.title ?? defaultTitle)
                    .brewTextStyle(.bodyMedium)
                    .foregroundColor(BrewColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(copy.message ?? defaultMessage)
                    .brewTextStyle(.caption)
                    .foregroundColor(BrewColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var defaultTitle: String {
        isRewards ? "Unlock rewards on your next order" : "No personalized offer right now"
    }

    private var defaultMessage: String {
        isRewards
            ? "Place an order of ₹5,000 or more within 3 months to earn rewards."
            : "Nothing matched for this user — check the menu instead. New offers appear the "
                + "moment a campaign has one for them."
    }
}
