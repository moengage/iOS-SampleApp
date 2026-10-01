//
//  MenuHeader.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The white block at the top of the menu screen: greeting, store strip, search
//  field and category pills.
//
//  It scrolls away with the rest of the screen rather than pinning.
//
//  The search field is presentation only. The sample has no search, and a field
//  that took input but did nothing would be worse than one that plainly does
//  not — so it is drawn, not typed into.
//

import SwiftUI

struct MenuHeader: View {

    let category: MenuCategory

    /// Unread inbox messages. Zero hides the badge entirely.
    let unreadCount: Int

    let onCategorySelected: (MenuCategory) -> Void
    let onInboxTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                greeting
                storeStrip
                searchField
                categoryPills
            }
            .padding(.horizontal, BrewSize.screenPadding)
            .padding(.top, 18)
            .padding(.bottom, 14)

            ThinDivider()
        }
        .background(BrewColor.surface)
    }

    // MARK: - Greeting

    private var greeting: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning,")
                    .brewTextStyle(.caption)
                    .foregroundColor(BrewColor.textSecondary)

                Text(DemoUser.name)
                    .brewTextStyle(.titleBold)
                    .foregroundColor(BrewColor.textPrimary)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 12)

            bellButton
        }
    }

    /// The circular notification button, with the unread count overlaid.
    private var bellButton: some View {
        Button(action: onInboxTapped) {
            Image(systemName: "bell.fill")
                .font(.system(size: 19, weight: .regular))
                .foregroundColor(BrewColor.textPrimary)
                .frame(width: BrewSize.bellButton, height: BrewSize.bellButton)
                .background(BrewColor.componentFill)
                .clipShape(Circle())
                .overlay(alignment: .topTrailing) {
                    if unreadCount > 0 {
                        badge
                            // Overhangs the circle's top-trailing edge.
                            .offset(x: 3, y: -3)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notifications")
        .accessibilityValue(unreadCount > 0 ? "\(unreadCount) unread" : "No unread messages")
    }

    /// The count, carrying a white ring so it stays legible against the button.
    private var badge: some View {
        Text("\(unreadCount)")
            .brewTextStyle(.microMedium)
            .foregroundColor(BrewColor.onDarkPrimary)
            .frame(width: BrewSize.badge, height: BrewSize.badge)
            .background(BrewColor.unreadBadge)
            .clipShape(Circle())
            .padding(2)
            .background(BrewColor.surface)
            .clipShape(Circle())
    }

    // MARK: - Store

    private var storeStrip: some View {
        HStack(spacing: 10) {
            Image(systemName: "building.2")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(BrewColor.primary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(Store.address)
                    .brewTextStyle(.supportMedium)
                    .foregroundColor(BrewColor.textPrimary)

                Text(Store.hours)
                    .brewTextStyle(.micro)
                    .foregroundColor(BrewColor.textSecondary)
            }

            Spacer(minLength: 8)

            // Changing store is not part of the sample; the label is
            // deliberately inert.
            Text("Change")
                .brewTextStyle(.captionMedium)
                .foregroundColor(BrewColor.link)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrewColor.neutralFill)
        .clipShape(
            RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack {
            Text(category.searchPlaceholder)
                .brewTextStyle(.body)
                .foregroundColor(BrewColor.textTertiary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(category.searchMeta)
                .brewTextStyle(.caption)
                .foregroundColor(BrewColor.textSecondary)
                .layoutPriority(1)
        }
        .padding(.horizontal, 14)
        .frame(height: BrewSize.searchHeight)
        .background(BrewColor.componentFill)
        .clipShape(
            RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Categories

    private var categoryPills: some View {
        // Scrollable because the three labels together exceed the screen width
        // at larger content sizes, where a fixed row would clip the last pill.
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MenuCategory.allCases) { entry in
                    TabPill(
                        label: entry.label,
                        isSelected: entry == category,
                        action: { onCategorySelected(entry) }
                    )
                }
            }
            // The pills are inset from the header's padding, so the scroll view
            // is widened to the screen edge and the inset re-applied inside it.
            // A pill can then scroll to the very edge rather than stopping short.
            .padding(.horizontal, BrewSize.screenPadding)
        }
        .padding(.horizontal, -BrewSize.screenPadding)
    }
}

