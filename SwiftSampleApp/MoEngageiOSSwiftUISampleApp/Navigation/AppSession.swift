//
//  AppSession.swift
//  MoEngageiOSSwiftUISampleApp

import Foundation

/// The two halves of the application.
enum AppPhase {

    /// Splash, sign-in and notification opt-in.
    case onboarding

    /// The signed-in tab bar.
    case main
}

/// The signed-in session, and the phase that follows from it.
@MainActor
final class AppSession: ObservableObject {

    /// The half of the application currently on screen. Changed only through
    /// the two methods below, so every transition is greppable.
    @Published private(set) var phase: AppPhase = .onboarding

    /// A destination a campaign link named before the user had signed in.
    ///
    /// Such a link cannot be followed at the time: its screen lives inside a
    /// tab, and there is no tab bar yet. Rather than drop it — which loses the
    /// campaign's whole point — it is held here and followed once the tab bar
    /// appears.
    @Published var pendingDeepLink: Route?

    /// Enters the signed-in experience, discarding the onboarding stack.
    ///
    /// Called once the user has both signed in and answered — or declined to be
    /// asked — the notification permission.
    func enterMain() {
        phase = .main
    }

    /// Returns to onboarding. The counterpart of `enterMain()`, used by sign-out.
    func signOut() {
        phase = .onboarding
    }
}
