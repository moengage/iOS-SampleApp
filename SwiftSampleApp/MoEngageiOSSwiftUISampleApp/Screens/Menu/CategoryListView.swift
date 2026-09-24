//
//  CategoryListView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The full list for one part of the menu.
//
//  The category arrives as part of the route, so the screen is fully described
//  by where it was navigated to — including from a campaign deep link. On
//  arrival it moves the shared menu state to that category, which is what
//  reports `Category_Browsed` and what leaves the menu showing the same
//  category on the way back.
//
//  The filter pills are presentation only, matching the Android sample: they
//  show a selection but the list is the whole category either way. Filtering
//  would need fields the demo catalogue does not carry.
//

import SwiftUI

struct CategoryListView: View {

    let category: MenuCategory

    /// The menu tab's shared state, moved to `category` on arrival.
    @ObservedObject var menuState: MenuState

    let onBack: () -> Void
    let onItemSelected: (MenuItem) -> Void

    /// Adding is a choice of size and milk, so it opens the item rather than
    /// putting anything in the cart — the same as the Android sample.
    let onAdd: (MenuItem) -> Void

    /// Shown as selected. Inert, as described above.
    @State private var activeFilter: String = MenuCatalogue.filters[0]

    var body: some View {
        VStack(spacing: 0) {
            BrewAppBar(
                title: category.sectionTitle,
                subtitle: Store.pickupLine,
                onBack: onBack
            )

            filters

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(MenuCatalogue.byCategory(category)) { item in
                        MenuRow(
                            item: item,
                            onSelect: { onItemSelected(item) },
                            onAdd: { onAdd(item) }
                        )
                    }
                }
                .padding(.horizontal, BrewSize.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.category)
        .onAppear { menuState.select(category) }
    }

    // MARK: - Filters

    private var filters: some View {
        // Scrollable for the same reason as the menu's category pills: three
        // labels overflow the width at large content sizes.
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MenuCatalogue.filters, id: \.self) { filter in
                    FilterPill(
                        label: filter,
                        isSelected: filter == activeFilter,
                        action: { activeFilter = filter }
                    )
                }
            }
            .padding(.horizontal, BrewSize.screenPadding)
            .padding(.vertical, 12)
        }
        .background(BrewColor.surface)
    }
}

#Preview {
    CategoryListView(
        category: .coffee,
        menuState: MenuState(),
        onBack: {},
        onItemSelected: { _ in },
        onAdd: { _ in }
    )
}
