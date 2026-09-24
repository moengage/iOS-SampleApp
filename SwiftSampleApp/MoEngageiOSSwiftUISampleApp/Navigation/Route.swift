//
//  Route.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Every destination the application can navigate to.
//
//  A route carries its own arguments, so a destination is fully described by the
//  value alone. That is what lets a campaign deep link resolve straight into a
//  route, and what lets the stack be restored from a list of values.
//
//  `Hashable` conformance is required by `navigationDestination(for:)`.
//

import Foundation

enum Route: Hashable {

    /// Sign-in.
    case login

    /// Notification opt-in.
    case permission

    /// The full list for one part of the menu.
    case category(MenuCategory)

    /// One item, configured before ordering. Carries the item's identifier
    /// rather than the item, so a campaign link naming an item resolves to a
    /// route without the catalogue having to be consulted first.
    case item(id: String)

    /// The order, before paying for it.
    case cart

    /// Paying for the order.
    case payment

    /// Confirmation and progress for one order.
    case orderStatus(orderID: String)

    /// Order history. The root of its tab rather than a pushed screen — see
    /// `MainTabView`.
    case orders

    /// Notifications the device has received.
    case inbox

    /// Offers chosen for this user by MoEngage. Reached from the profile.
    case personalize
}

extension Route {

    /// Whether this destination belongs to the onboarding stack.
    ///
    /// Everything else lives inside a tab, and so is only reachable once the
    /// user has signed in.
    var isOnboarding: Bool {
        tab == nil
    }

    /// The tab this destination is reached through, or `nil` when it belongs to
    /// onboarding instead.
    ///
    /// A link naming a destination cannot just be pushed: it has to be pushed
    /// onto the right tab's stack, and that tab has to be selected first. This
    /// is what tells the tab bar which one.
    var tab: BrewTab? {
        switch self {
        case .login, .permission:
            return nil
        case .category, .item, .cart, .payment, .orderStatus, .inbox:
            return .menu
        case .orders:
            return .orders
        case .personalize:
            return .profile
        }
    }

    /// Resolves a campaign deep link, for example `brewbar://login`, to a route.
    ///
    /// Returns `nil` when the link names no destination this build knows about,
    /// in which case the caller should leave the current screen in place rather
    /// than navigate somewhere arbitrary.
    init?(deeplink url: URL) {
        let path = (url.host.map { [$0] } ?? []) + url.pathComponents.filter { $0 != "/" }
        guard let first = path.first else { return nil }

        switch first {
        case "login":
            self = .login
        case "permission":
            self = .permission
        case "category":
            // An unknown or absent identifier resolves to the default category
            // rather than failing, so a mistyped campaign link still lands on
            // the menu instead of nowhere.
            self = .category(MenuCategory.from(id: path.dropFirst().first))
        case "item":
            // Unlike a category, an unknown item has no sensible default, so a
            // link with no identifier names no destination and is ignored.
            guard let id = path.dropFirst().first else { return nil }
            self = .item(id: id)
        case "cart":
            self = .cart
        case "payment":
            self = .payment
        case "order_status", "status":
            // Android defaults a link with no identifier to the most recent
            // order rather than ignoring it, so a campaign can link to "the
            // order" without knowing which.
            self = .orderStatus(orderID: path.dropFirst().first ?? OrderCatalogue.latest().id)
        case "orders":
            self = .orders
        case "inbox":
            self = .inbox
        case "personalize":
            self = .personalize
        default:
            return nil
        }
    }
}
