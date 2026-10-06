//
//  RootNavigationContainer.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Presents the navigation stack described by `Router.path`.
//
//  Two implementations sit behind one interface, chosen at runtime:
//
//  - iOS 16 and later use `NavigationStack`, which binds the route array
//    directly. Every navigation operation is an array operation.
//  - iOS 15 uses `NavigationView`, which has no equivalent binding. The array is
//    instead expressed as a chain of `NavigationLink`s, one per level, each
//    active while the stack is deep enough to reach it. Dismissing a link — by
//    the system back control or the swipe gesture — truncates the array so the
//    router and the view stay in agreement.
//
//  Callers see neither. They mutate `Router.path` and the correct container
//  renders it.
//

import SwiftUI

struct RootNavigationContainer<Root: View>: View {

    @ObservedObject var router: Router

    /// The screen at the bottom of the stack.
    @ViewBuilder let root: () -> Root

    /// Builds the screen for a pushed route.
    let destination: (Route) -> AnyView

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.path) {
                root()
                    .navigationDestination(for: Route.self) { route in
                        destination(route).hidesNavigationBar()
                    }
                    .hidesNavigationBar()
            }
        } else {
            NavigationView {
                root()
                    .background(link(at: 0))
                    .hidesNavigationBar()
            }
            .navigationViewStyle(.stack)
        }
    }

    // MARK: - iOS 15 link chain

    /// The link for one level of the stack, carrying the link for the next.
    ///
    /// One level beyond the current depth is always present, so that pushing a
    /// route activates a link that already exists and the transition animates.
    /// Recursion ends at that level, since `index` never exceeds the count.
    private func link(at index: Int) -> AnyView {
        guard index <= router.path.count else { return AnyView(EmptyView()) }

        return AnyView(
            NavigationLink(isActive: isActive(at: index)) {
                if router.path.count > index {
                    destination(router.path[index])
                        .background(link(at: index + 1))
                        .hidesNavigationBar()
                }
            } label: {
                EmptyView()
            }
            .hidden()
        )
    }

    /// Active while the stack reaches this level. Clearing it pops this level
    /// and everything above, which is how a system-driven dismissal reaches the
    /// router.
    private func isActive(at index: Int) -> Binding<Bool> {
        Binding(
            get: { router.path.count > index },
            set: { active in
                guard !active, router.path.count > index else { return }
                router.path.removeSubrange(index...)
            }
        )
    }
}

// MARK: - Navigation bar

extension View {

    /// Hides the system navigation bar.
    ///
    /// The design supplies its own headers as ordinary content, so the system
    /// bar would be a second one.
    @ViewBuilder
    func hidesNavigationBar() -> some View {
        if #available(iOS 16.0, *) {
            toolbar(.hidden, for: .navigationBar)
        } else {
            navigationBarHidden(true)
        }
    }
}
