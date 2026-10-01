//
//  MainTabBarController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Screens/Main/MainTabView.swift.
//
//  The signed-in experience: a tab bar over four independent sections, each
//  wrapped in its own `UINavigationController` so pushing a screen inside one
//  tab leaves the others where they were, exactly like each tab owning its own
//  `Router` in the SwiftUI app.
//
//  Screen view controllers receive closures rather than a reference to this
//  tab bar controller, so a screen never decides where it leads — this file
//  does, exactly like `MainTabView` does for the SwiftUI app.
//

import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Shared state (owned here, spans one tab's screens or several)

    private let session: AppSession

    private let menuState = MenuState()
    private let cart = CartState()
    private let orders = OrderState()
    private let profile = ProfileState()
    private let inbox = InboxState()
    private let personalize = PersonalizeState()

    // MARK: - Per-tab navigation

    private let menuNav = UINavigationController()
    private let ordersNav = UINavigationController()
    private let profileNav = UINavigationController()

    init(session: AppSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        BrewTabBarAppearance.applyOnce()
        tabBar.tintColor = BrewColor.primary

        [menuNav, ordersNav, profileNav].forEach { $0.setNavigationBarHidden(true, animated: false) }

        menuNav.tabBarItem = UITabBarItem(
            title: BrewTab.menu.title, image: UIImage(systemName: BrewTab.menu.systemImage), tag: 0
        )
        ordersNav.tabBarItem = UITabBarItem(
            title: BrewTab.orders.title, image: UIImage(systemName: BrewTab.orders.systemImage), tag: 1
        )
        let cardsVC = TabPlaceholderViewController(tab: .cards)
        cardsVC.tabBarItem = UITabBarItem(
            title: BrewTab.cards.title, image: UIImage(systemName: BrewTab.cards.systemImage), tag: 2
        )
        profileNav.tabBarItem = UITabBarItem(
            title: BrewTab.profile.title, image: UIImage(systemName: BrewTab.profile.systemImage), tag: 3
        )

        menuNav.viewControllers = [makeMenuHome()]
        ordersNav.viewControllers = [makeOrdersRoot()]
        profileNav.viewControllers = [makeProfileRoot()]

        viewControllers = [menuNav, ordersNav, cardsVC, profileNav]

        // Deep-link CTAs from in-app campaigns, routed by the SDK delegate
        // rather than through `SceneDelegate`. See `MoEngageInApp`.
        MoEngageSDKHelper.onInAppDeepLink { [weak self] route in self?.follow(route) }
    }

    // MARK: - Deep links
    //
    // Called by `RootCoordinatorController.handle(url:)` — either immediately,
    // for a link naming a destination inside a tab that arrives while the tab
    // bar is already on screen, or once, for one that arrived during
    // onboarding and was held on `session.pendingDeepLink` until now.
    func follow(_ route: Route) {
        guard let tab = route.tab else { return }
        selectedIndex = [BrewTab.menu, .orders, .cards, .profile].firstIndex(of: tab) ?? 0

        switch route {
        case .orders:
            ordersNav.popToRootViewController(animated: true)
        case .category, .item, .cart, .payment, .orderStatus, .inbox:
            pushMenu(route)
        case .personalize:
            profileNav.pushViewController(makePersonalize(), animated: true)
        case .login, .permission:
            break
        }
    }

    private func pushMenu(_ route: Route) {
        switch route {
        case .category(let category):
            menuNav.pushViewController(makeCategoryList(category: category), animated: true)
        case .item(let id):
            menuNav.pushViewController(makeItemDetail(item: MenuCatalogue.item(id: id)), animated: true)
        case .cart:
            menuNav.pushViewController(makeCart(), animated: true)
        case .payment:
            menuNav.pushViewController(makePayment(), animated: true)
        case .orderStatus(let orderID):
            menuNav.pushViewController(makeOrderStatus(orderID: orderID, inMenuTab: true), animated: true)
        case .inbox:
            menuNav.pushViewController(makeInbox(), animated: true)
        default:
            break
        }
    }

    // MARK: - Menu tab

    private func makeMenuHome() -> UIViewController {
        MenuHomeViewController(
            menuState: menuState,
            inbox: inbox,
            onItemSelected: { [weak self] item in
                guard let self else { return }
                self.menuNav.pushViewController(self.makeItemDetail(item: item), animated: true)
            },
            onFullMenu: { [weak self] category in
                guard let self else { return }
                self.menuNav.pushViewController(self.makeCategoryList(category: category), animated: true)
            },
            onReorderUsual: { [weak self] in
                guard let self else { return }
                let usual = MenuCatalogue.usual
                MoEngageSDKHelper.trackReorderTapped(item: usual.summary, orderID: self.orders.lastOrder.id)
                self.menuNav.pushViewController(self.makeCart(), animated: true)
            },
            onInboxTapped: { [weak self] in
                guard let self else { return }
                self.menuNav.pushViewController(self.makeInbox(), animated: true)
            },
            onPromoOpened: { [weak self] url in
                guard let self, let route = Route(deeplink: url) else { return }
                self.follow(route)
            }
        )
    }

    private func makeCategoryList(category: MenuCategory) -> UIViewController {
        CategoryListViewController(
            category: category,
            menuState: menuState,
            onBack: { [weak self] in self?.menuNav.popViewController(animated: true) },
            onItemSelected: { [weak self] item in
                guard let self else { return }
                self.menuNav.pushViewController(self.makeItemDetail(item: item), animated: true)
            },
            // "Add" opens the item so size and milk can be chosen, rather than
            // putting a default configuration in the cart.
            onAdd: { [weak self] item in
                guard let self else { return }
                self.menuNav.pushViewController(self.makeItemDetail(item: item), animated: true)
            }
        )
    }

    private func makeItemDetail(item: MenuItem) -> UIViewController {
        ItemDetailViewController(
            item: item,
            onBack: { [weak self] in self?.menuNav.popViewController(animated: true) },
            onAdd: { [weak self] selection in
                guard let self else { return }
                MoEngageSDKHelper.trackAddToCart(item: item, selection: selection)
                self.cart.add(CartLine(item: item, selection: selection))
                self.menuNav.pushViewController(self.makeCart(), animated: true)
            }
        )
    }

    private func makeCart() -> UIViewController {
        CartViewController(
            cart: cart,
            onBack: { [weak self] in self?.menuNav.popViewController(animated: true) },
            // Returns to the list for the category last browsed rather than to
            // the menu itself.
            onAddAnother: { [weak self] in
                guard let self else { return }
                self.menuNav.pushViewController(self.makeCategoryList(category: self.menuState.category), animated: true)
            },
            onProceed: { [weak self] in
                guard let self else { return }
                self.menuNav.pushViewController(self.makePayment(), animated: true)
            }
        )
    }

    private func makePayment() -> UIViewController {
        PaymentViewController(
            cart: cart,
            orders: orders,
            onBack: { [weak self] in self?.menuNav.popViewController(animated: true) },
            onOrderPlaced: { [weak self] order in
                guard let self else { return }
                // Replaces the stack rather than pushing: the order is paid
                // for, so going back to payment would be wrong.
                var stack = self.menuNav.viewControllers
                stack.removeAll { $0 is CartViewController || $0 is PaymentViewController || $0 is ItemDetailViewController || $0 is CategoryListViewController }
                stack.append(self.makeOrderStatus(orderID: order.id, inMenuTab: true))
                self.menuNav.setViewControllers(stack, animated: true)
            }
        )
    }

    private func makeOrderStatus(orderID: String, inMenuTab: Bool) -> UIViewController {
        OrderStatusViewController(
            order: orders.order(id: orderID),
            onMyOrders: { [weak self] in
                guard let self else { return }
                if inMenuTab {
                    self.selectedIndex = 1
                } else {
                    self.ordersNav.popToRootViewController(animated: true)
                }
            },
            onBackToMenu: { [weak self] in
                guard let self else { return }
                if inMenuTab {
                    self.menuNav.popToRootViewController(animated: true)
                } else {
                    self.ordersNav.popToRootViewController(animated: true)
                    self.selectedIndex = 0
                }
            }
        )
    }

    private func makeInbox() -> UIViewController {
        InboxViewController(
            inbox: inbox,
            onBack: { [weak self] in self?.menuNav.popViewController(animated: true) },
            // A message's link is followed exactly as a campaign's would be,
            // so an inbox row and the notification it came from lead to the
            // same place.
            onMessageOpened: { [weak self] url in
                guard let self, let route = Route(deeplink: url) else { return }
                self.follow(route)
            }
        )
    }

    // MARK: - Orders tab

    private func makeOrdersRoot() -> UIViewController {
        OrdersViewController(
            orders: OrderCatalogue.all(),
            onTrack: { [weak self] order in
                guard let self else { return }
                self.ordersNav.pushViewController(self.makeOrderStatus(orderID: order.id, inMenuTab: false), animated: true)
            },
            onReorder: { [weak self] order in
                guard let self else { return }
                MoEngageSDKHelper.trackReorderTapped(item: order.lines.first?.name ?? "", orderID: order.id)
                self.selectedIndex = 0
                self.menuNav.pushViewController(self.makeCart(), animated: true)
            },
            // The self-handled cards screen is not built yet.
            onSubscribe: {}
        )
    }

    // MARK: - Profile tab

    private func makeProfileRoot() -> UIViewController {
        ProfileViewController(
            state: profile,
            onPersonalize: { [weak self] in
                guard let self else { return }
                self.profileNav.pushViewController(self.makePersonalize(), animated: true)
            },
            onLogout: { [weak self] in self?.signOut() }
        )
    }

    private func makePersonalize() -> UIViewController {
        PersonalizeViewController(
            state: personalize,
            onBack: { [weak self] in self?.profileNav.popViewController(animated: true) },
            // An offer's link is a campaign deep link like any other, so it is
            // resolved the same way rather than interpreted here.
            onFollow: { [weak self] url in
                guard let self, let route = Route(deeplink: url) else { return }
                self.follow(route)
            }
        )
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
        MoEngageSDKHelper.onInAppDeepLink(nil)

        cart.reset()
        orders.reset()
        profile.resetNotificationPreferences()
        menuNav.popToRootViewController(animated: false)
        ordersNav.popToRootViewController(animated: false)
        profileNav.popToRootViewController(animated: false)
        selectedIndex = 0

        session.signOut()
    }
}

// MARK: - Bar appearance

/// The parts of the tab bar's appearance UIKit does not default to matching
/// the design: an opaque background and the unselected item colour.
enum BrewTabBarAppearance {

    private static var isApplied = false

    static func applyOnce() {
        guard !isApplied else { return }
        isApplied = true

        let appearance = UITabBarAppearance()
        // Opaque, so the bar stays `surface` rather than blurring the content
        // scrolled beneath it.
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = BrewColor.surface
        appearance.shadowColor = BrewColor.borderSubtle

        UITabBar.appearance().standardAppearance = appearance
        // Applied when a scroll view is at its bottom edge; without it the bar
        // becomes transparent there on iOS 15+. The property itself doesn't
        // exist before iOS 15, hence the guard.
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        UITabBar.appearance().unselectedItemTintColor = BrewColor.textTertiary
    }
}
