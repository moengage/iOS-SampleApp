//
//  MainTabView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The signed-in experience: a tab bar over four independent sections.
//
//  `TabView` is used rather than a hand-built bar. The system bar keeps each
//  tab's view alive, so a tab returns in the state it was left in; it carries
//  the correct accessibility traits; and it insets itself above the home
//  indicator. A custom bar would give finer control over measurements but would
//  have to reimplement all of that.
//
//  Only the palette is customized. The bar's height, symbol size and label size
//  are the system's and are not adjustable.
//
//  Each tab owns its own navigation stack, so pushing a screen inside one tab
//  leaves the others where they were — and returning to a tab returns to where
//  it was left. A tab with no screen to push has no stack.
//

import SwiftUI

struct MainTabView: View {

    /// Consulted for a campaign link that arrived before the tab bar existed.
    @ObservedObject var session: AppSession

    /// The visible tab. `TabView` needs its own selection state; it is not
    /// navigation and so does not belong to a router.
    @State private var selection: BrewTab = .menu

    /// The Menu tab's stack. Each tab gets its own, so they never interfere.
    @StateObject private var menuRouter = Router()

    /// The Menu tab's shared state, read by both of its screens.
    @StateObject private var menuState = MenuState()

    /// The order. Owned here rather than by a screen because it is built on
    /// one, read on another and paid for on a third.
    @StateObject private var cart = CartState()

    /// What was ordered last, and how the next one is paid for.
    @StateObject private var orders = OrderState()

    /// The Orders tab's stack.
    @StateObject private var ordersRouter = Router()

    /// Permission state, read by the Profile tab.
    @StateObject private var profile = ProfileState()

    /// The Profile tab's stack, onto which Personalize is pushed.
    @StateObject private var profileRouter = Router()

    /// Received notifications, and the count behind the menu's bell. Owned
    /// here because the badge is needed whether or not the inbox is opened.
    @StateObject private var inbox = InboxState()

    /// What the Personalize screen is showing. Owned here so the tab returns to
    /// it as it was left, like every other tab.
    @StateObject private var personalize = PersonalizeState()

    /// Declared rather than left to the memberwise initializer, so the bar's
    /// appearance is configured before the first one is drawn.
    init(session: AppSession) {
        self.session = session
        BrewTabBarAppearance.applyOnce()
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(BrewTab.allCases) { tab in
                content(for: tab)
                    .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                    .tag(tab)
            }
        }
        // Tints the selected symbol and label. The unselected colour is not
        // reachable from SwiftUI and is set in `BrewTabBarAppearance`.
        .tint(BrewColor.primary)
        // A link arriving now, with the tab bar already on screen.
        .onOpenURL { url in
            MoEngageSDKHelper.trackOrderActivityOpened(url)
            guard let route = Route(deeplink: url) else { return }
            follow(route)
        }
        // Deep-link CTAs from in-app campaigns, routed by the SDK delegate
        // rather than through `onOpenURL`. See `MoEngageInApp`.
        .onAppear { MoEngageSDKHelper.onInAppDeepLink(follow) }
        .onDisappear { MoEngageSDKHelper.onInAppDeepLink(nil) }
        // A link that arrived during onboarding and was held until now.
        .task {
            guard let route = session.pendingDeepLink else { return }
            session.pendingDeepLink = nil
            follow(route)
        }
    }

    // MARK: - Deep links

    /// Selects the tab a destination belongs to, then pushes it there.
    ///
    /// Selecting first matters: pushing onto a stack that is not on screen
    /// would leave the user where they were, with the destination waiting
    /// unseen behind another tab.
    private func follow(_ route: Route) {
        guard let tab = route.tab else { return }
        selection = tab

        switch route {
        // A tab's own root. Selecting the tab is the whole navigation; pushing
        // would put a second copy of the screen on top of itself.
        case .orders:
            ordersRouter.popToRoot()

        case .category, .item, .cart, .payment, .orderStatus, .inbox:
            menuRouter.navigate(to: route)

        case .personalize:
            profileRouter.navigate(to: route)

        case .login, .permission:
            break
        }
    }

    // MARK: - Sections

    /// The content of one tab. The Cards tab shows a placeholder.
    @ViewBuilder
    private func content(for tab: BrewTab) -> some View {
        switch tab {
        case .menu:
            menuTab

        case .orders:
            ordersTab

        case .profile:
            profileTab

        case .cards:
            TabPlaceholderView(tab: tab)
        }
    }

    // MARK: - Menu

    /// The Menu tab and everything reachable from it.
    private var menuTab: some View {
        RootNavigationContainer(router: menuRouter) {
            MenuHomeView(
                menuState: menuState,
                onItemSelected: { menuRouter.navigate(to: .item(id: $0.id)) },
                onFullMenu: { menuRouter.navigate(to: .category($0)) },
                onReorderUsual: {
                    let usual = MenuCatalogue.usual
                    MoEngageSDKHelper.trackReorderTapped(
                        item: usual.summary,
                        orderID: orders.lastOrder.id
                    )
                    menuRouter.navigate(to: .cart)
                },
                onInboxTapped: { menuRouter.navigate(to: .inbox) },
                // The promo card's link is a campaign deep link like any
                // other, so it is resolved the same way rather than
                // interpreted here.
                onPromoOpened: { url in
                    guard let route = Route(deeplink: url) else { return }
                    follow(route)
                },
                unreadCount: inbox.unreadCount
            )
            // A campaign can land while the app is elsewhere, so the badge is
            // re-read whenever the menu is returned to.
            .onAppear { inbox.refreshUnreadCount() }
        } destination: { route in
            menuDestination(for: route)
        }
    }

    // MARK: - Signing out

    /// Ends the session and returns to onboarding.
    ///
    /// Everything built during the session is discarded first. Without that,
    /// signing back in would show the previous user's basket and their last
    /// order — the state objects outlive the tab bar, and only the phase
    /// changes underneath them.
    private func signOut() {
        MoEngageSDKHelper.logout()

        cart.reset()
        orders.reset()
        profile.resetNotificationPreferences()
        menuRouter.popToRoot()
        ordersRouter.popToRoot()
        profileRouter.popToRoot()
        selection = .menu

        session.signOut()
    }

    // MARK: - Profile

    /// The Profile tab: who the user is, what they have allowed, and the offers
    /// MoEngage has picked for them.
    private var profileTab: some View {
        RootNavigationContainer(router: profileRouter) {
            ProfileView(
                state: profile,
                onPersonalize: { profileRouter.navigate(to: .personalize) },
                onLogout: signOut
            )
        } destination: { route in
            profileDestination(for: route)
        }
    }

    private func profileDestination(for route: Route) -> AnyView {
        switch route {
        case .personalize:
            return AnyView(
                PersonalizeView(
                    state: personalize,
                    onBack: { profileRouter.pop() },
                    // An offer's link is a campaign deep link like any other,
                    // so it is resolved the same way rather than interpreted
                    // here.
                    onFollow: { url in
                        guard let route = Route(deeplink: url) else { return }
                        follow(route)
                    }
                )
            )

        // Nothing else is reachable from this tab.
        case .login, .permission, .category, .item, .cart, .payment, .orderStatus, .orders,
             .inbox:
            return AnyView(EmptyView())
        }
    }

    // MARK: - Orders

    /// The Orders tab: history, and the status of anything still in progress.
    private var ordersTab: some View {
        RootNavigationContainer(router: ordersRouter) {
            OrdersView(
                orders: OrderCatalogue.all(),
                onTrack: { ordersRouter.navigate(to: .orderStatus(orderID: $0.id)) },
                onReorder: { order in
                    MoEngageSDKHelper.trackReorderTapped(
                        item: order.lines.first?.name ?? "",
                        orderID: order.id
                    )
                    selection = .menu
                    menuRouter.navigate(to: .cart)
                },
                // The Cards screen is not implemented in this sample.
                onSubscribe: {}
            )
        } destination: { route in
            ordersDestination(for: route)
        }
    }

    private func ordersDestination(for route: Route) -> AnyView {
        switch route {
        case .orderStatus(let orderID):
            return AnyView(
                OrderStatusView(
                    order: orders.order(id: orderID),
                    onMyOrders: { ordersRouter.popToRoot() },
                    onBackToMenu: {
                        ordersRouter.popToRoot()
                        selection = .menu
                    }
                )
            )

        // Nothing else is reachable from this tab.
        case .login, .permission, .category, .item, .cart, .payment, .orders, .personalize,
             .inbox:
            return AnyView(EmptyView())
        }
    }

    // MARK: - Destinations

    private func menuDestination(for route: Route) -> AnyView {
        switch route {
        case .category(let category):
            return AnyView(
                CategoryListView(
                    category: category,
                    menuState: menuState,
                    onBack: { menuRouter.pop() },
                    onItemSelected: { menuRouter.navigate(to: .item(id: $0.id)) },
                    // "Add" opens the item so size and milk can be chosen,
                    // rather than putting a default configuration in the cart.
                    onAdd: { menuRouter.navigate(to: .item(id: $0.id)) }
                )
            )

        case .item(let id):
            let item = MenuCatalogue.item(id: id)
            return AnyView(
                ItemDetailView(
                    item: item,
                    onBack: { menuRouter.pop() },
                    onAdd: { selection in
                        MoEngageSDKHelper.trackAddToCart(item: item, selection: selection)
                        cart.add(CartLine(item: item, selection: selection))
                        menuRouter.navigate(to: .cart)
                    }
                )
            )

        case .payment:
            return AnyView(
                PaymentView(
                    bill: cart.bill,
                    fulfilment: cart.fulfilment,
                    itemsCount: cart.lines.count,
                    selectedMethodID: $orders.paymentMethodID,
                    onBack: { menuRouter.pop() },
                    onPay: {
                        let order = orders.placeOrder(from: cart)

                        // Starts the order-tracking Live Activity as soon as
                        // the order exists. The app already holds the initial
                        // content, so the activity is started locally rather
                        // than by a push from the backend.
                        if #available(iOS 18, *) {
                            MoEngageSDKHelper.startOrderTracking(
                                orderID: order.id,
                                status: "Order Placed",
                                etaMinutes: 12
                            )
                        }

                        // Replaces the stack rather than pushing: the order is
                        // paid for, so going back to payment would be wrong.
                        menuRouter.replaceStack(with: .orderStatus(orderID: order.id))
                    }
                )
            )

        case .orderStatus(let orderID):
            return AnyView(
                OrderStatusView(
                    order: orders.order(id: orderID),
                    onMyOrders: { selection = .orders },
                    onBackToMenu: { menuRouter.popToRoot() }
                )
            )

        case .cart:
            return AnyView(
                CartView(
                    cart: cart,
                    onBack: { menuRouter.pop() },
                    // Returns to the list for the category last browsed
                    // rather than to the menu itself.
                    onAddAnother: { menuRouter.navigate(to: .category(menuState.category)) },
                    onProceed: { menuRouter.navigate(to: .payment) }
                )
            )

        case .inbox:
            return AnyView(
                InboxView(
                    inbox: inbox,
                    onBack: { menuRouter.pop() },
                    // A message's link is followed exactly as a campaign's
                    // would be, so an inbox row and the notification it came
                    // from lead to the same place.
                    onMessageOpened: { url in
                        guard let route = Route(deeplink: url) else { return }
                        follow(route)
                    }
                )
            )

        // Not reachable from this stack: onboarding sits before the tab bar,
        // order history is another tab's root, and Personalize belongs to
        // the Profile tab.
        case .login, .permission, .orders, .personalize:
            return AnyView(EmptyView())
        }
    }
}

// MARK: - Bar appearance

/// The parts of the tab bar's appearance that SwiftUI does not expose.
///
/// The unselected item colour and an opaque background are only reachable
/// through the UIKit appearance proxy. That proxy is global and applies to every
/// tab bar in the process, so it is applied once.
@MainActor
enum BrewTabBarAppearance {

    private static var isApplied = false

    static func applyOnce() {
        guard !isApplied else { return }
        isApplied = true

        let appearance = UITabBarAppearance()
        // Opaque, so the bar stays `surface` rather than blurring the content
        // scrolled beneath it.
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BrewColor.surface)
        appearance.shadowColor = UIColor(BrewColor.borderSubtle)

        UITabBar.appearance().standardAppearance = appearance
        // Applied when a scroll view is at its bottom edge; without it the bar
        // becomes transparent there on iOS 15.
        UITabBar.appearance().scrollEdgeAppearance = appearance

        UITabBar.appearance().unselectedItemTintColor = UIColor(BrewColor.textTertiary)
    }
}

#Preview {
    MainTabView(session: AppSession())
}
