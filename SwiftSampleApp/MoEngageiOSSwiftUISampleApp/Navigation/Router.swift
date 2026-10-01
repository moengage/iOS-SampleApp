//
//  Router.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Owns the navigation stack.
//
//  The stack is a plain array of `Route` values bound to a `NavigationStack`, so
//  every navigation operation is an array operation. Screens never hold a
//  reference to this type; they take closures and stay unaware of where they sit
//  in the hierarchy, which keeps them previewable on their own.
//

import SwiftUI

@MainActor
final class Router: ObservableObject {

    /// The screens stacked above the root. Empty means the root is showing.
    @Published var path: [Route] = []

    /// Pushes a destination.
    func navigate(to route: Route) {
        path.append(route)
    }

    /// Returns to the previous screen. Does nothing at the root.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Clears the stack back to the root screen.
    func popToRoot() {
        path.removeAll()
    }

    /// Replaces the stack so `route` becomes the only screen above the root.
    ///
    /// Used where a flow should not be returnable to — completing sign-in, or
    /// signing out — in place of pushing onto the screens already behind it.
    func replaceStack(with route: Route) {
        path = [route]
    }

    /// Routes a campaign deep link. Links naming no known destination are
    /// ignored, leaving the current screen in place.
    func handle(deeplink url: URL) {
        guard let route = Route(deeplink: url) else { return }
        navigate(to: route)
    }
}
