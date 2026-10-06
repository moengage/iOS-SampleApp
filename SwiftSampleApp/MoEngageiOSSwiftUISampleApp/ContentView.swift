//
//  ContentView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Root of the application, and the one place navigation is wired.
//
//  The app has two phases. Onboarding is a navigation stack rooted at the splash
//  screen: everything in it is a `Route` pushed onto that stack. The signed-in
//  experience is a tab bar. `AppSession.phase` decides which is on screen, and
//  swapping between them here — rather than pushing one onto the other — is what
//  makes onboarding unreachable once it is done.
//
//  Screens receive closures rather than the router or the session, so a screen
//  never decides where it leads — this file does.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var session = AppSession()
    @StateObject private var router = Router()

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .onboarding:
            RootNavigationContainer(router: router) {
                SplashView(onGetStarted: { router.navigate(to: .login) })
            } destination: { route in
                destination(for: route)
            }
            // Reports the link to MoEngage, then works out where it leads.
            // Reporting is explicit here because scene delegate swizzling
            // cannot reach SwiftUI's own scene delegate — see
            // `MoEngageEvents.trackDeepLinkOpened(_:)`. Universal links arrive
            // here too: the app registers no `onContinueUserActivity`.
            //
            // A link naming a screen inside a tab cannot be followed yet —
            // there is no tab bar — so it is held until there is. The tab bar
            // carries its own handler for links arriving after that.
            .onOpenURL { url in
                MoEngageSDKHelper.trackDeepLinkOpened(url)
                MoEngageSDKHelper.trackOrderActivityOpened(url)
                guard let route = Route(deeplink: url) else { return }

                if route.isOnboarding {
                    router.navigate(to: route)
                } else {
                    session.pendingDeepLink = route
                }
            }

        case .main:
            MainTabView(session: session)
        }
    }

    // MARK: - Flow

    /// Shows the notification opt-in only to a user who has not yet answered the
    /// permission alert. Anyone who has — on an earlier run, or in Settings —
    /// has nothing left to be asked, so the screen is skipped entirely rather
    /// than shown and dismissed, and the flow continues straight into the app.
    private func continueAfterLogin() {
        Task {
            if await MoEngageSDKHelper.hasAnsweredPushPermission() {
                session.enterMain()
            } else {
                router.navigate(to: .permission)
            }
        }
    }

    // MARK: - Destinations

    private func destination(for route: Route) -> AnyView {
        switch route {
        case .login:
            return AnyView(
                LoginView(
                    onBack: { router.pop() },
                    onVerified: {
                        MoEngageSDKHelper.onLoginSucceeded()
                        MoEngageSDKHelper.syncTasteProfile()
                        continueAfterLogin()
                    }
                )
            )

        // Not reachable: the deep-link handler above admits only onboarding
        // destinations, and nothing in this stack navigates to the others.
        case .category, .item, .cart, .payment, .orderStatus, .orders, .personalize, .inbox:
            return AnyView(EmptyView())

        case .permission:
            return AnyView(
                PushOptInView(onContinue: {
                    // Registers the token for a user who has now allowed
                    // notifications. Does nothing for one who declined.
                    MoEngageSDKHelper.refreshPushTokenIfAlreadyAnswered()
                    session.enterMain()
                })
            )
        }
    }
}
