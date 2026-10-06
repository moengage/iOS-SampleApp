//
//  MenuCatalogue.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The demo menu.
//
//  The sample has no catalogue backend. These fixed items stand in for whatever
//  a real one would return, and are the source of every item name, price and
//  identifier reported to MoEngage — so they are shared with the other platform
//  samples, and a campaign targeted at `flat-white` works on every platform.
//

import Foundation

enum MenuCatalogue {

    /// Everything on the menu, in the order it is offered.
    static let items: [MenuItem] = coffee + herbalTeas + food

    /// The grid on the menu home screen: the first four featured items of a
    /// category.
    static func featured(_ category: MenuCategory) -> [MenuItem] {
        Array(byCategory(category).filter(\.featured).prefix(4))
    }

    /// Everything in one category, for the full-menu list.
    static func byCategory(_ category: MenuCategory) -> [MenuItem] {
        items.filter { $0.category == category }
    }

    /// Looks an item up by identifier, falling back to the first item for an
    /// unknown one rather than failing — a deep link naming a withdrawn item
    /// should still land somewhere.
    static func item(id: String) -> MenuItem {
        items.first { $0.id == id } ?? items[0]
    }

    /// Cup sizes. The middle one is the default.
    static let sizes = [
        SizeOption(label: "Small", volume: "180 ml", surcharge: 0),
        SizeOption(label: "Medium", volume: "240 ml", surcharge: 20),
        SizeOption(label: "Large", volume: "330 ml", surcharge: 40),
    ]

    /// Milk choices. The middle one is the default.
    static let milks = [
        MilkOption(label: "Dairy", surcharge: 0),
        MilkOption(label: "Oat", surcharge: 30),
        MilkOption(label: "Almond", surcharge: 30),
    ]

    /// Offered alongside a drink on the item screen.
    static let addOns = [
        AddOn(itemID: "almond-biscotti", label: "Almond biscotti", price: 110),
        AddOn(itemID: "greek-yogurt-bowl", label: "Greek yogurt & granola bowl", price: 280),
    ]

    /// The category list's filter labels.
    ///
    /// Presentation only — see `CategoryListView`. They exist because the
    /// design has them.
    static let filters = ["Popular", "Under ₹200", "Vegan"]

    /// The signed-in user's habitual order.
    static let usual = UsualOrder(
        summary: "Flat white · oat · medium",
        detail: "Ordered 14 times · ₹240",
        itemID: "flat-white"
    )

    // MARK: - Coffee

    private static let coffee: [MenuItem] = [
        MenuItem(
            id: "flat-white",
            name: "Flat white",
            note: "Double ristretto, steamed milk, thin microfoam",
            price: 220,
            category: .coffee,
            image: "HotCoffee",
            featured: true
        ),
        MenuItem(
            id: "cappuccino",
            name: "Cappuccino",
            note: "Equal parts espresso, milk and foam · cocoa dust",
            price: 210,
            category: .coffee,
            image: "HotCoffee"
        ),
        MenuItem(
            id: "masala-cortado",
            name: "Masala cortado",
            note: "Espresso cut with cardamom-clove milk",
            price: 190,
            category: .coffee,
            image: "HotCoffee"
        ),
        MenuItem(
            id: "cold-brew",
            name: "Cold brew",
            note: "18-hour steep, served black over ice",
            price: 240,
            category: .coffee,
            image: "ColdCoffee",
            featured: true
        ),
        MenuItem(
            id: "iced-latte",
            name: "Iced latte",
            note: "Espresso, chilled milk, choice of syrup",
            price: 230,
            category: .coffee,
            image: "ColdCoffee"
        ),
        MenuItem(
            id: "espresso-tonic",
            name: "Espresso tonic",
            note: "Single origin over tonic and orange peel",
            price: 250,
            category: .coffee,
            image: "ColdCoffee"
        ),
        MenuItem(
            id: "filter-coffee",
            name: "Filter coffee",
            note: "South Indian filter decoction, frothed",
            price: 120,
            category: .coffee,
            image: "HotCoffee",
            featured: true
        ),
        MenuItem(
            id: "vietnamese-cold",
            name: "Vietnamese cold",
            note: "Dark roast over condensed milk and ice",
            price: 260,
            category: .coffee,
            image: "ColdCoffee",
            featured: true
        ),
    ]

    // MARK: - Herbal teas

    private static let herbalTeas: [MenuItem] = [
        MenuItem(
            id: "chamomile",
            name: "Chamomile",
            note: "Whole flowers, slow steeped · caffeine-free",
            price: 150,
            category: .herbalTeas,
            image: "HerbalTea",
            featured: true
        ),
        MenuItem(
            id: "tulsi-ginger",
            name: "Tulsi ginger",
            note: "Holy basil with fresh ginger and a twist of lime",
            price: 140,
            category: .herbalTeas,
            image: "HerbalTea",
            featured: true
        ),
        MenuItem(
            id: "hibiscus-mint",
            name: "Hibiscus mint cooler",
            note: "Tart hibiscus, garden mint, served chilled",
            price: 160,
            category: .herbalTeas,
            image: "HerbalTea",
            featured: true
        ),
        MenuItem(
            id: "blue-pea-lemongrass",
            name: "Blue pea lemongrass",
            note: "Butterfly pea flower and lemongrass infusion",
            price: 170,
            category: .herbalTeas,
            image: "HerbalTea",
            featured: true
        ),
        MenuItem(
            id: "rooibos-vanilla",
            name: "Rooibos vanilla",
            note: "Red bush with vanilla pod · naturally sweet",
            price: 165,
            category: .herbalTeas,
            image: "HerbalTea"
        ),
        MenuItem(
            id: "kashmiri-kahwa",
            name: "Kashmiri kahwa",
            note: "Saffron, almond and cardamom green tea",
            price: 180,
            category: .herbalTeas,
            image: "HerbalTea"
        ),
    ]

    // MARK: - Food

    private static let food: [MenuItem] = [
        MenuItem(
            id: "greek-yogurt-bowl",
            name: "Greek yogurt & granola bowl",
            note: "Thick curd, honey granola, seasonal fruit",
            price: 280,
            category: .food,
            image: "YogurtBowl",
            featured: true
        ),
        MenuItem(
            id: "berry-chia-bowl",
            name: "Berry chia yogurt bowl",
            note: "Overnight chia, mixed berries, toasted coconut",
            price: 290,
            category: .food,
            image: "YogurtBowl",
            featured: true
        ),
        MenuItem(
            id: "savoury-yogurt-bowl",
            name: "Savoury yogurt bowl",
            note: "Hung curd, cucumber, dukkah and olive oil",
            price: 270,
            category: .food,
            image: "YogurtBowl"
        ),
        MenuItem(
            id: "butter-biscuits",
            name: "Butter biscuits",
            note: "Bakery classic, baked twice daily",
            price: 90,
            category: .food,
            image: "Snacks"
        ),
        MenuItem(
            id: "almond-biscotti",
            name: "Almond biscotti",
            note: "Crisp, twice-baked · made for dunking",
            price: 110,
            category: .food,
            image: "Snacks",
            featured: true
        ),
        MenuItem(
            id: "banana-walnut-cake",
            name: "Banana walnut cake",
            note: "Slow-baked loaf, dense and moist",
            price: 160,
            category: .food,
            image: "Snacks"
        ),
        MenuItem(
            id: "masala-croissant",
            name: "Masala cheese croissant",
            note: "Laminated overnight, spiced cheddar filling",
            price: 180,
            category: .food,
            image: "Snacks",
            featured: true
        ),
        MenuItem(
            id: "egg-kejriwal",
            name: "Egg kejriwal sandwich",
            note: "Chilli cheese toast, runny yolk, sourdough",
            price: 300,
            category: .food,
            image: "Snacks"
        ),
    ]
}
