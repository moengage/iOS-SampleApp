//
//  BrewTab.swift
//  MoEngageiOSSampleApp
//
//  Plain (non-SwiftUI) port of MoEngageiOSSwiftUISampleApp/Navigation/BrewTab.swift,
//  kept identical in cases/properties so the reused Route.swift keeps compiling.
//

import Foundation

enum BrewTab: String, CaseIterable, Identifiable, Hashable {

    /// The menu, and the app's home.
    case menu

    /// Past and in-progress orders.
    case orders

    /// Self-handled campaign cards. Titled "Cards" to fit a quarter-width tab.
    case cards

    /// Profile, preferences and sign-out.
    case profile

    var id: String { rawValue }

    /// The label shown beneath the symbol.
    var title: String {
        switch self {
        case .menu: return "Menu"
        case .orders: return "Orders"
        case .cards: return "Cards"
        case .profile: return "Profile"
        }
    }

    /// The SF Symbol shown in the bar.
    var systemImage: String {
        switch self {
        case .menu: return "bag"
        case .orders: return "list.bullet.rectangle"
        case .cards: return "gift"
        case .profile: return "person"
        }
    }
}
