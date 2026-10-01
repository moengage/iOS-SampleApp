//
//  RootCoordinatorController.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/ContentView.swift +
//  RootNavigationContainer.swift.
//
//  Owns the shared `AppSession` and swaps its single child view controller
//  between the onboarding flow (a `UINavigationController` rooted at
//  `SplashViewController`) and the signed-in `MainTabBarController`, whenever
//  `session.phase` changes.
//
//  Screens receive closures rather than a reference to this coordinator, so a
//  screen never decides where it leads — this file does, exactly like
//  `ContentView` does for the SwiftUI app.
//

import UIKit
import Combine

final class RootCoordinatorController: UIViewController {

    private let session = AppSession()
    private var cancellables = Set<AnyCancellable>()

    /// The currently displayed child (either the onboarding nav controller or
    /// the main tab bar).
    private var currentChild: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BrewColor.pageBackground

        session.$phase
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phase in
                self?.show(for: phase)
            }
            .store(in: &cancellables)
    }

    // MARK: - Phase switching

    private func show(for phase: AppPhase) {
        let next: UIViewController
        switch phase {
        case .onboarding:
            next = makeOnboardingFlow()
        case .main:
            next = MainTabBarController(session: session)
        }

        let previous = currentChild
        currentChild = next

        addChild(next)
        next.view.frame = view.bounds
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(next.view)
        next.didMove(toParent: self)

        if let previous {
            previous.willMove(toParent: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParent()
        }

        // A link that arrived during onboarding and was held until now.
        if case .main = phase, let pending = session.pendingDeepLink {
            session.pendingDeepLink = nil
            (next as? MainTabBarController)?.follow(pending)
        }
    }

    // MARK: - Onboarding

    /// A fresh navigation stack rooted at the splash screen, exactly as
    /// `RootNavigationContainer` presents a fresh `Router` path for onboarding.
    private func makeOnboardingFlow() -> UIViewController {
        let splash = SplashViewController { [weak self] in
            self?.pushLogin()
        }
        let nav = UINavigationController(rootViewController: splash)
        nav.setNavigationBarHidden(true, animated: false)
        onboardingNav = nav
        return nav
    }

    /// Held only long enough to push subsequent onboarding screens onto the
    /// same stack.
    private weak var onboardingNav: UINavigationController?

    private func pushLogin() {
        let login = LoginViewController(
            onBack: { [weak self] in
                self?.onboardingNav?.popViewController(animated: true)
            },
            onVerified: { [weak self] in
                MoEngageSDKHelper.onLoginSucceeded()
                MoEngageSDKHelper.syncTasteProfile()
                self?.continueAfterLogin()
            }
        )
        onboardingNav?.pushViewController(login, animated: true)
    }

    /// Shows the notification opt-in only to a user who has not yet answered
    /// the permission alert. Anyone who has — on an earlier run, or in
    /// Settings — has nothing left to be asked, so the screen is skipped
    /// entirely and the flow continues straight into the app.
    private func continueAfterLogin() {
        Task { @MainActor in
            if await MoEngageSDKHelper.hasAnsweredPushPermission() {
                session.enterMain()
            } else {
                pushPushOptIn()
            }
        }
    }

    private func pushPushOptIn() {
        let optIn = PushOptInViewController { [weak self] in
            // Registers the token for a user who has now allowed
            // notifications. Does nothing for one who declined.
            MoEngageSDKHelper.refreshPushTokenIfAlreadyAnswered()
            self?.session.enterMain()
        }
        onboardingNav?.pushViewController(optIn, animated: true)
    }

    // MARK: - Deep links
    //
    // Entry point is `SceneDelegate`'s `scene(_:openURLContexts:)` /
    // `scene(_:continue:)`, which calls this after reporting the link to
    // MoEngage — this handler is only concerned with where the link leads,
    // exactly like `ContentView`'s `.onOpenURL` for the SwiftUI app.
    func handle(url: URL) {
        MoEngageSDKHelper.trackOrderActivityOpened(url)
        guard let route = Route(deeplink: url) else { return }

        switch session.phase {
        case .onboarding:
            // A link naming a screen inside a tab cannot be followed yet —
            // there is no tab bar — so it is held until there is.
            // `MainTabBarController` picks it up in `show(for:)` above, the
            // moment it comes on screen.
            if route.isOnboarding {
                switch route {
                case .login:
                    pushLogin()
                case .permission:
                    pushPushOptIn()
                default:
                    break
                }
            } else {
                session.pendingDeepLink = route
            }

        case .main:
            // A link arriving now, with the tab bar already on screen.
            (currentChild as? MainTabBarController)?.follow(route)
        }
    }
}
