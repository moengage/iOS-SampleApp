//
//  ItemDetailView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  One item, configured and added to the order.
//
//  Price is derived, never stored: the base price plus the size's and milk's
//  surcharges makes a unit price, add-ons are added to it, and the whole is
//  multiplied by the quantity. Every control therefore updates the footer's
//  total as a consequence of changing the selection, with nothing to keep in
//  step by hand.
//
//  MoEngage moments:
//  - `Item_Viewed` on arrival, with the item's name, price and category.
//  - The screen is an in-app campaign target and asks on every arrival —
//    unlike the menu, which asks once per session.
//  - `Add_To_Cart` on the call to action, carrying the configuration.
//

import SwiftUI

struct ItemDetailView: View {

    let item: MenuItem
    let onBack: () -> Void

    /// Hands the configured selection to the caller, which reports it and puts
    /// it in the cart.
    let onAdd: (ItemSelection) -> Void

    @State private var sizeIndex = 1
    @State private var milkIndex = 1
    @State private var quantity = 1
    @State private var selectedAddOnIDs: Set<String> = []

    // MARK: - Derived price

    private var size: SizeOption { MenuCatalogue.sizes[sizeIndex] }
    private var milk: MilkOption { MenuCatalogue.milks[milkIndex] }

    private var chosenAddOns: [AddOn] {
        MenuCatalogue.addOns.filter { selectedAddOnIDs.contains($0.itemID) }
    }

    private var total: Int {
        let unit = item.price + size.surcharge + milk.surcharge
        let addOns = chosenAddOns.reduce(0) { $0 + $1.price }
        return (unit + addOns) * quantity
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    details
                }
            }

            footer
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.item)
        .onAppear {
            MoEngageSDKHelper.trackItemViewed(item)
            // Asked for on every arrival. The menu's once-per-session rule is
            // about not interrupting the same visit twice on the app's home;
            // an item is a deliberate, specific choice, so a campaign here is
            // wanted each time.
            MoEngageSDKHelper.showInApp()
        }
    }

    // MARK: - Hero

    private var hero: some View {
        CoverImage(item.image)
            .frame(height: BrewSize.heroImageHeight)
            .background(BrewColor.neutralFill)
            .overlay(alignment: .topLeading) {
                // Not the outlined `BackTile` used elsewhere: this one sits on
                // artwork rather than a surface, so it carries its own
                // translucent backing to stay legible over any image.
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(BrewColor.textPrimary)
                        .frame(width: BrewSize.heroBackButton, height: BrewSize.heroBackButton)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
                .padding(14)
            }
    }

    // MARK: - Details

    private var details: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.name)
                        .brewTextStyle(.heroHeader)
                        .foregroundColor(BrewColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    Spacer(minLength: 12)

                    Text(rupees(item.price))
                        .brewTextStyle(.titleBold)
                        .foregroundColor(BrewColor.textPrimary)
                        .lineLimit(1)
                }

                Text(item.note)
                    .brewTextStyle(.support)
                    .foregroundColor(BrewColor.textSecondary)
            }

            OptionSection("Size") {
                HStack(spacing: 8) {
                    ForEach(Array(MenuCatalogue.sizes.enumerated()), id: \.element.id) { index, option in
                        SelectCard(
                            title: option.label,
                            subtitle: option.volume + surcharge(option.surcharge),
                            isSelected: index == sizeIndex,
                            action: { sizeIndex = index }
                        )
                    }
                }
            }

            OptionSection("Milk") {
                HStack(spacing: 8) {
                    ForEach(Array(MenuCatalogue.milks.enumerated()), id: \.element.id) { index, option in
                        SelectPill(
                            label: option.label + surcharge(option.surcharge),
                            isSelected: index == milkIndex,
                            action: { milkIndex = index }
                        )
                    }
                }
            }

            OptionSection("Make it a meal") {
                VStack(spacing: 8) {
                    ForEach(MenuCatalogue.addOns) { addOn in
                        AddOnRow(
                            addOn: addOn,
                            isChecked: selectedAddOnIDs.contains(addOn.itemID),
                            onToggle: { toggle(addOn) }
                        )
                    }
                }
            }
        }
        .padding(BrewSize.screenPadding)
    }

    private func toggle(_ addOn: AddOn) {
        if selectedAddOnIDs.contains(addOn.itemID) {
            selectedAddOnIDs.remove(addOn.itemID)
        } else {
            selectedAddOnIDs.insert(addOn.itemID)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        FooterBar {
            HStack(spacing: 12) {
                QuantityStepper(
                    quantity: quantity,
                    onDecrement: { quantity = max(1, quantity - 1) },
                    onIncrement: { quantity += 1 }
                )

                Button("Add · \(rupees(total))") {
                    onAdd(
                        ItemSelection(
                            size: size.label,
                            milk: milk.label,
                            addOns: chosenAddOns.map(\.label),
                            quantity: quantity,
                            amount: total
                        )
                    )
                }
                .buttonStyle(.brewPrimary)
            }
        }
    }
}

// MARK: - Option section

/// A titled group of controls. Private: only this screen groups options.
private struct OptionSection<Content: View>: View {

    private let title: String
    private let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .brewTextStyle(.cardTitle)
                .foregroundColor(BrewColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            content()
        }
    }
}

// MARK: - Add-on row

/// A card with a checkbox, a label and a price.
///
/// The checkbox is drawn rather than taken from SwiftUI: `Toggle` renders as a
/// switch on iOS, and `.checkboxStyle` is macOS only.
private struct AddOnRow: View {

    let addOn: AddOn
    let isChecked: Bool
    let onToggle: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: BrewCorner.button, style: .continuous)
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                checkbox

                Text(addOn.label)
                    .brewTextStyle(.body)
                    .foregroundColor(BrewColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                Text(rupees(addOn.price))
                    .brewTextStyle(.bodyMedium)
                    .foregroundColor(BrewColor.textPrimary)
                    .lineLimit(1)
            }
            .padding(14)
            .background(BrewColor.surface)
            .clipShape(shape)
            .overlay(shape.stroke(BrewColor.borderSubtle, lineWidth: 1))
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isChecked ? [.isButton, .isSelected] : .isButton)
    }

    private var checkbox: some View {
        RoundedRectangle(cornerRadius: BrewCorner.checkbox, style: .continuous)
            .fill(isChecked ? BrewColor.primary : Color.clear)
            .frame(width: BrewSize.checkbox, height: BrewSize.checkbox)
            .overlay(
                RoundedRectangle(cornerRadius: BrewCorner.checkbox, style: .continuous)
                    .stroke(isChecked ? BrewColor.primary : BrewColor.borderDefault, lineWidth: 1)
            )
            .overlay {
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(BrewColor.onDarkPrimary)
                }
            }
    }
}

// MARK: - Quantity

/// The outlined "− 1 +" control.
private struct QuantityStepper: View {

    let quantity: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            StepperButton(label: "−", action: onDecrement)
                .accessibilityLabel("Decrease quantity")

            Text("\(quantity)")
                .brewTextStyle(.bodyMedium)
                .foregroundColor(BrewColor.textPrimary)
                .frame(minWidth: 24)

            StepperButton(label: "+", action: onIncrement)
                .accessibilityLabel("Increase quantity")
        }
        .frame(height: BrewSize.buttonHeight)
        .overlay(
            RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
                .stroke(BrewColor.borderDefault, lineWidth: 1)
        )
        .accessibilityValue("\(quantity)")
    }
}

private struct StepperButton: View {

    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .brewTextStyle(.cardTitle)
                .foregroundColor(BrewColor.textPrimary)
                .frame(width: BrewSize.touchTarget, height: BrewSize.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ItemDetailView(
        item: MenuCatalogue.item(id: "flat-white"),
        onBack: {},
        onAdd: { _ in }
    )
}
