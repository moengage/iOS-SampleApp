//
//  MenuModels.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The menu's domain types.
//
//  These describe what the app sells, not how it is drawn. They carry no
//  SwiftUI, so they can be constructed in a preview or a test without a view.
//

import Foundation

/// The three menu tabs.
///
/// Each case carries its own copy, so a category change is a single value change
/// rather than four parallel lookups. `id` is the value a `category/{id}` deep
/// link carries, and matches the Android sample's identifiers.
enum MenuCategory: String, CaseIterable, Identifiable, Hashable {

    case coffee
    case herbalTeas
    case food

    var id: String {
        switch self {
        case .coffee: return "coffee"
        case .herbalTeas: return "teas"
        case .food: return "food"
        }
    }

    /// The tab label.
    var label: String {
        switch self {
        case .coffee: return "Coffee"
        case .herbalTeas: return "Herbal teas"
        case .food: return "Food"
        }
    }

    /// The section title above the featured grid.
    var sectionTitle: String {
        switch self {
        case .coffee: return "Coffee · hot & cold"
        case .herbalTeas: return "Herbal teas & infusions"
        case .food: return "Bowls, bakes & snacks"
        }
    }

    /// The search field's placeholder.
    var searchPlaceholder: String {
        switch self {
        case .coffee: return "Search flat white, cold brew…"
        case .herbalTeas: return "Search chamomile, tulsi ginger…"
        case .food: return "Search bowls, bakes, snacks…"
        }
    }

    /// The trailing text inside the search field.
    var searchMeta: String {
        switch self {
        case .coffee: return "Hot & cold"
        case .herbalTeas: return "Caffeine-free"
        case .food: return "All day"
        }
    }

    /// Resolves a deep link's category identifier, falling back to coffee for an
    /// unknown one rather than failing the navigation.
    static func from(id: String?) -> MenuCategory {
        allCases.first { $0.id == id } ?? .coffee
    }
}

/// One thing on the menu.
struct MenuItem: Identifiable, Hashable {

    let id: String
    let name: String

    /// The one-line description beneath the name.
    let note: String

    /// Whole rupees. Formatted for display by `rupees(_:)`.
    let price: Int

    let category: MenuCategory

    /// Asset catalog image name.
    let image: String

    /// Featured items fill the two-column grid on the menu home screen.
    let featured: Bool

    init(
        id: String,
        name: String,
        note: String,
        price: Int,
        category: MenuCategory,
        image: String,
        featured: Bool = false
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.price = price
        self.category = category
        self.image = image
        self.featured = featured
    }
}

/// A cup size, and what it adds to the base price.
struct SizeOption: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let volume: String
    let surcharge: Int
}

/// A milk choice, and what it adds to the base price.
struct MilkOption: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let surcharge: Int
}

/// Something offered alongside a drink.
struct AddOn: Identifiable, Hashable {
    /// The menu item this add-on is, so it can be priced and pictured.
    let itemID: String
    var id: String { itemID }
    let label: String
    let price: Int
}

/// What the user configured on the item screen, handed back so it can be
/// reported and put in the cart.
struct ItemSelection {
    let size: String
    let milk: String
    let addOns: [String]
    let quantity: Int

    /// The line total: the configured unit price times the quantity.
    let amount: Int
}

/// The user's habitual order, offered for one-tap reordering.
struct UsualOrder {
    let summary: String
    let detail: String
    let itemID: String
}
