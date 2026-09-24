//
//  MenuHomeView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The menu tab's home: the header, a two-column grid of featured items and the
//  user's usual order.
//
//  The whole screen is one scroll view, header included. The selected category
//  lives in `MenuState`, because the category list moves it too.
//
//  MoEngage moments:
//  - `Menu_Viewed` on arrival, and `Category_Browsed` on every pill tap — the
//    latter reported by `MenuState`, since the category list changes it too.
//  - The menu is an in-app campaign target, so it asks for one on arrival.
//  - The menu is also a self-handled campaign's target: `MenuState` fetches
//    it, this screen draws it as a card above the section header.
//

import SwiftUI

struct MenuHomeView: View {

    /// The menu tab's shared state. Shared rather than private because the
    /// category list reads and moves it too.
    @ObservedObject var menuState: MenuState

    /// Opens an item's detail screen.
    let onItemSelected: (MenuItem) -> Void

    /// Opens the full list for the selected category.
    let onFullMenu: (MenuCategory) -> Void

    /// Adds the usual order to the cart.
    let onReorderUsual: () -> Void

    /// Opens the notification inbox.
    let onInboxTapped: () -> Void

    /// Follows the self-handled promo card's deep link, if it has one.
    let onPromoOpened: (URL) -> Void

    /// Unread inbox messages, shown on the bell.
    var unreadCount: Int = 0

    /// Columns 12 pt apart, each at least 150 pt wide.
    ///
    /// Adaptive rather than a fixed pair: two columns is what 150 pt resolves to
    /// on a portrait phone, which is the shared design's grid, but a landscape
    /// phone or an iPad fits three or four — so the cards keep their proportions
    /// instead of stretching to half the screen.
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MenuHeader(
                    category: menuState.category,
                    unreadCount: unreadCount,
                    onCategorySelected: menuState.select,
                    onInboxTapped: onInboxTapped
                )

                VStack(alignment: .leading, spacing: 22) {
                    if let promo = menuState.promo {
                        promoCard(promo)
                    }

                    SectionHeader(
                        title: menuState.category.sectionTitle,
                        actionLabel: "Full menu",
                        action: { onFullMenu(menuState.category) }
                    )

                    featuredGrid
                    usualCard
                }
                .padding(.horizontal, BrewSize.screenPadding)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.menu)
        .onAppear {
            MoEngageSDKHelper.trackMenuViewed(menuState.category)
            menuState.requestSelfHandledPromoOnce()
        }
        .onDisappear { menuState.stopListeningForSelfHandledPromo() }
        // Runs after `inAppContext` has scoped eligibility to the menu, so the
        // campaign asked for below is matched against the right context.
        .task { await menuState.requestNativeInAppOnce() }
    }

    // MARK: - Self-handled promo

    private func promoCard(_ promo: MoEngageSDKHelper.SelfHandledPromo) -> some View {
        SelfHandledPromoCard(
            payload: promo.payload,
            onTap: {
                if let url = menuState.promoTapped() {
                    onPromoOpened(url)
                }
            },
            onDismiss: { menuState.dismissPromo() }
        )
        // Reports the impression the moment the card is actually drawn, not
        // when the campaign was merely fetched — a card fetched but never
        // rendered would otherwise inflate the dashboard's shown count.
        .onAppear { MoEngageSDKHelper.trackSelfHandledShown(promo) }
    }

    // MARK: - Featured

    private var featuredGrid: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(MenuCatalogue.featured(menuState.category)) { item in
                FeaturedCard(item: item) { onItemSelected(item) }
            }
        }
    }

    // MARK: - The usual

    private var usualCard: some View {
        BrewCard(padding: 14) {
            HStack(spacing: 12) {
                IconTile(systemImage: "cup.and.saucer.fill")

                VStack(alignment: .leading, spacing: 2) {
                    Text(MenuCatalogue.usual.summary)
                        .brewTextStyle(.bodyMedium)
                        .foregroundColor(BrewColor.textPrimary)

                    Text(MenuCatalogue.usual.detail)
                        .brewTextStyle(.caption)
                        .foregroundColor(BrewColor.textSecondary)
                }

                Spacer(minLength: 8)

                Button(action: onReorderUsual) {
                    Text("Reorder")
                        .brewTextStyle(.supportMedium)
                        .foregroundColor(BrewColor.link)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    MenuHomeView(
        menuState: MenuState(),
        onItemSelected: { _ in },
        onFullMenu: { _ in },
        onReorderUsual: {},
        onInboxTapped: {},
        onPromoOpened: { _ in },
        unreadCount: 3
    )
}
