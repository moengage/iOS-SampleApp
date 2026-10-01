//
//  MenuState.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The menu tab's shared state: which part of the menu the user is looking at.
//
//  Shared rather than private to a screen because two screens read it. The
//  category list is reached from the menu's selection, and arriving there —
//  including by deep link — moves the menu to that category, so returning shows
//  what was just browsed rather than what was selected before.
//
//  MoEngage integration:
//  - Changing category reports `Category_Browsed`. Selecting the category
//    already showing is not a change and reports nothing, so a deep link into
//    the category already open does not inflate the count.
//  - The menu asks for a native in-app campaign once per session. The flag for
//    that lives here because this object lasts as long as the signed-in
//    session, where a screen's own state would not.
//  - The menu is also a self-handled campaign's target: the app draws the
//    promo card itself, and reports it shown, tapped or dismissed.
//

import Foundation

@MainActor
final class MenuState: ObservableObject {

    /// The part of the menu on display.
    @Published private(set) var category: MenuCategory = .coffee

    /// Moves to a category, reporting the change.
    func select(_ category: MenuCategory) {
        guard category != self.category else { return }
        self.category = category
        MoEngageSDKHelper.trackCategoryBrowsed(category)
    }

    // MARK: - Native in-app

    /// Set once the menu has asked for a campaign, so returning to the menu
    /// later in the same session does not ask again.
    private var hasRequestedInAppThisSession = false

    /// Asks for an in-app campaign eligible for the menu, at most once per
    /// session.
    ///
    /// The pause lets the screen finish appearing first: presenting a campaign
    /// in the same frame as the navigation transition conflicts with it.
    ///
    /// Nothing appears unless a campaign is configured and targets this user —
    /// the request is silent when there is nothing to show.
    func requestNativeInAppOnce() async {
        guard !hasRequestedInAppThisSession else { return }
        hasRequestedInAppThisSession = true
        try? await Task.sleep(nanoseconds: Self.inAppRequestDelay)

        MoEngageSDKHelper.showInApp()
    }

    /// 120 ms, enough for the navigation transition to settle.
    private static let inAppRequestDelay: UInt64 = 120_000_000

    // MARK: - Self-handled promo

    /// The self-handled campaign to draw above the section header, if one is
    /// eligible. `nil` shows nothing — the card's presence is entirely driven
    /// by whether a campaign is configured and targets this user.
    @Published private(set) var promo: MoEngageSDKHelper.SelfHandledPromo? {
        didSet { hasReportedPromoShown = false }
    }

    /// Set once the current `promo` has been reported shown. The card is drawn
    /// again on every return to the menu, but the campaign was delivered only
    /// once — and each `selfHandledShown` counts against its frequency cap — so
    /// it is reported once per delivered campaign, not once per appearance.
    private var hasReportedPromoShown = false

    /// Set once the menu has asked for a campaign, so returning to the menu
    /// later in the same session does not ask again.
    private var hasRequestedPromoThisSession = false

    /// Asks for a self-handled campaign, at most once per session, and starts
    /// listening for one pushed while the menu is on screen.
    func requestSelfHandledPromoOnce() {
        MoEngageSDKHelper.onSelfHandledPromoTriggered { [weak self] promo in
            self?.promo = promo
        }

        guard !hasRequestedPromoThisSession else { return }
        hasRequestedPromoThisSession = true

        MoEngageSDKHelper.fetchSelfHandledPromo { [weak self] promo in
            guard let promo else { return }
            self?.promo = promo
        }
    }

    /// The card was drawn. Reports the impression the first time only — see
    /// `hasReportedPromoShown`.
    func promoAppeared() {
        guard let promo, !hasReportedPromoShown else { return }
        hasReportedPromoShown = true
        MoEngageSDKHelper.trackSelfHandledShown(promo)
    }

    /// Stops listening for a pushed campaign. Called when the menu leaves the
    /// screen, so a campaign meant for this session does not silently land
    /// once the user has moved elsewhere.
    func stopListeningForSelfHandledPromo() {
        MoEngageSDKHelper.onSelfHandledPromoTriggered(nil)
    }

    /// The card was tapped. Reports the click and resolves where it leads,
    /// exactly as a campaign deep link from anywhere else would.
    ///
    /// Two reports: the SDK's click, which feeds the campaign's dashboard
    /// figures, and the app's own `InApp_Cta_Clicked`, named by the card's
    /// title so it can be segmented on.
    func promoTapped() -> URL? {
        guard let promo else { return nil }
        MoEngageSDKHelper.trackSelfHandledClicked(promo)
        MoEngageSDKHelper.trackInAppCtaClicked(campaignID: promo.campaignID, cta: promo.payload.title)
        self.promo = nil
        return promo.payload.deeplink.flatMap(URL.init(string:))
    }

    /// The card was dismissed without being tapped.
    func dismissPromo() {
        guard let promo else { return }
        MoEngageSDKHelper.trackSelfHandledDismissed(promo)
        self.promo = nil
    }
}
