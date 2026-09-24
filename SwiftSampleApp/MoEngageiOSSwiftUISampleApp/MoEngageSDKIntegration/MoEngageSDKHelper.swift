//
//  MoEngageSDKHelper.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The one place this app talks to the MoEngage SDK, and the entry point for the
//  whole integration. Screens call `MoEngageSDKHelper`; they never import
//  `MoEngageSDK` themselves.
//
//  This file is the index: every SDK capability the app uses appears below as a
//  one-line delegation, so the surface can be audited at a glance. The
//  implementations live alongside it, one type per feature:
//
//  - `MoEngageUser`       — identity and user attributes
//  - `MoEngagePush`       — push registration and notification permission
//  - `MoEngageInApp`      — in-app campaign contexts and callbacks
//  - `MoEngageGeofenceModule` — location-triggered campaigns
//  - `MoEngageEvents`     — the event dictionary
//  - `MoEngageReporting`  — the shared failure reporting every call goes through
//

import Foundation

enum MoEngageSDKHelper {

    // MARK: - Identity and user attributes

    /// Called once login succeeds. Establishes the user's identity and their
    /// reserved profile attributes.
    static func onLoginSucceeded() {
        MoEngageUser.onLoginSucceeded()
    }

    /// Mirrors the user's drink preferences onto their MoEngage profile.
    static func syncTasteProfile() {
        MoEngageUser.syncTasteProfile()
    }

    /// Ends the signed-in session. Everything tracked afterwards belongs to a
    /// new, anonymous user.
    static func logout() {
        MoEngageUser.logout()
    }

    // MARK: - Geofence

    /// Starts monitoring the workspace's fences. Call only once location
    /// permission has been granted.
    static func startGeofenceMonitoring() {
        MoEngageGeofenceModule.startMonitoring()
    }

    /// Stops monitoring.
    static func stopGeofenceMonitoring() {
        MoEngageGeofenceModule.stopMonitoring()
    }

    /// Called once at launch. Registers the fence crossing callbacks.
    static func registerGeofenceCallbacks() {
        MoEngageGeofenceModule.registerCallbacks()
    }

    // MARK: - Push

    /// Called at launch. Refreshes the push token for a user who has already
    /// answered the permission alert, without presenting it.
    static func refreshPushTokenIfAlreadyAnswered() {
        MoEngagePush.refreshTokenIfAlreadyAnswered()
    }

    /// Presents the system notification permission alert.
    static func requestPushPermission() {
        MoEngagePush.requestPermission()
    }

    /// Whether notifications are currently permitted.
    static func isPushAuthorized() async -> Bool {
        await MoEngagePush.isAuthorized()
    }

    /// Whether the permission alert has already been answered, either way.
    static func hasAnsweredPushPermission() async -> Bool {
        await MoEngagePush.hasBeenAsked()
    }

    /// Opens this app's notification settings.
    static func openNotificationSettings() {
        MoEngagePush.openNotificationSettings()
    }

    // MARK: - In-app

    /// Scopes in-app campaign eligibility to the screen now on display.
    ///
    /// Applied by screens through `inAppContext(_:)` rather than called
    /// directly, so a screen declares what it is and nothing has to track where
    /// it sits in the hierarchy.
    static func setInAppContext(_ context: MoEngageInAppContext) {
        MoEngageInApp.setContext(context)
    }

    /// Asks for an in-app campaign eligible for the context now set. Called by
    /// the screens that are campaign targets.
    static func showInApp() {
        MoEngageInApp.showInApp()
    }

    /// Asks for a nudge eligible for the context now set.
    static func showNudge() {
        MoEngageInApp.showNudge()
    }

    /// Called once at launch. Registers the in-app shown, clicked and
    /// dismissed callbacks.
    static func registerInAppCallbacks() {
        MoEngageInApp.registerCallbacks()
    }

    // MARK: - Self-handled in-app

    /// A self-handled campaign, decoupled from the SDK.
    typealias SelfHandledPromo = MoEngageInApp.SelfHandledPromo

    /// Asks for a self-handled campaign eligible for the context now set.
    static func fetchSelfHandledPromo(completion: @escaping (SelfHandledPromo?) -> Void) {
        MoEngageInApp.fetchSelfHandledPromo(completion: completion)
    }

    /// Registers to receive a self-handled campaign pushed while the app is
    /// foregrounded. Pass `nil` to stop listening.
    static func onSelfHandledPromoTriggered(_ handler: ((SelfHandledPromo) -> Void)?) {
        MoEngageInApp.onSelfHandledPromoTriggered = handler
    }

    /// Reports the promo card on screen.
    static func trackSelfHandledShown(_ promo: SelfHandledPromo) {
        MoEngageInApp.trackSelfHandledShown(promo)
    }

    /// Reports the card tapped.
    static func trackSelfHandledClicked(_ promo: SelfHandledPromo) {
        MoEngageInApp.trackSelfHandledClicked(promo)
    }

    /// Reports the card dismissed without being tapped.
    static func trackSelfHandledDismissed(_ promo: SelfHandledPromo) {
        MoEngageInApp.trackSelfHandledDismissed(promo)
    }

    // MARK: - Events

    /// Reports that the user arrived at the menu.
    static func trackMenuViewed(_ category: MenuCategory) {
        MoEngageEvents.trackMenuViewed(category)
    }

    /// Reports that the user moved to a different part of the menu.
    static func trackCategoryBrowsed(_ category: MenuCategory) {
        MoEngageEvents.trackCategoryBrowsed(category)
    }

    /// Reports that the user opened an item.
    static func trackItemViewed(_ item: MenuItem) {
        MoEngageEvents.trackItemViewed(item)
    }

    /// Reports an item added to the order, with how it was configured.
    static func trackAddToCart(item: MenuItem, selection: ItemSelection) {
        MoEngageEvents.trackAddToCart(item: item, selection: selection)
    }

    /// Reports that the user opened the order.
    static func trackCartViewed(lines: [CartLine], amount: Int) {
        MoEngageEvents.trackCartViewed(lines: lines, amount: amount)
    }

    /// Reports that the user reached payment.
    static func trackCheckoutStarted(amount: Int, fulfilment: Fulfilment, coupon: String?) {
        MoEngageEvents.trackCheckoutStarted(amount: amount, fulfilment: fulfilment, coupon: coupon)
    }

    /// Reports a placed order.
    static func trackOrderPlaced(_ order: Order) {
        MoEngageEvents.trackOrderPlaced(order)
    }

    /// Reports an order collected. Not called yet — see `MoEngageEvents`.
    static func trackOrderPickedUp(orderID: String) {
        MoEngageEvents.trackOrderPickedUp(orderID: orderID)
    }

    /// Reports a past order sent back to the cart.
    static func trackReorderTapped(item: String, orderID: String) {
        MoEngageEvents.trackReorderTapped(item: item, orderID: orderID)
    }

    /// Reports that the user opened a notification.
    static func trackNotificationOpened(campaignID: String?, deeplink: String?) {
        MoEngageEvents.trackNotificationOpened(campaignID: campaignID, deeplink: deeplink)
    }

    /// Reports that the user acted on an in-app campaign's call to action.
    static func trackInAppCtaClicked(campaignID: String, cta: String) {
        MoEngageEvents.trackInAppCtaClicked(campaignID: campaignID, cta: cta)
    }

    // MARK: - Live Activity

    /// Called once at launch. Registers to watch for Live Activity push
    /// tokens, so MoEngage's backend can later update or end an activity.
    @available(iOS 18, *)
    static func registerForLiveActivityTokenUpdates() {
        MoEngageLiveActivityModule.registerForTokenUpdates()
    }

    /// Starts the order-tracking Live Activity locally. Call the moment an
    /// order is placed while the app is open.
    @available(iOS 18, *)
    static func startOrderTracking(orderID: String, status: String, etaMinutes: Int) {
        MoEngageLiveActivityModule.startOrderTracking(orderID: orderID, status: status, etaMinutes: etaMinutes)
    }

    /// Starts a sale broadcast Live Activity locally — a secondary, opt-in
    /// path. The primary way this starts is push-to-start, server-side, for
    /// the whole target audience; the SDK already watches for that
    /// automatically, no call needed here for that path.
    @available(iOS 18, *)
    static func startSaleBroadcast(saleName: String, discountText: String, timeRemaining: String) {
        MoEngageLiveActivityModule.startSaleBroadcast(saleName: saleName, discountText: discountText, timeRemaining: timeRemaining)
    }
}
