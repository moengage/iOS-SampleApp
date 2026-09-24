//
//  MoEngageInApp.swift
//  MoEngageiOSSwiftUISampleApp
//
//  In-app campaigns: contexts, requests and callbacks. Reached through
//  `MoEngageSDKHelper`.
//
//  Three separate things, in that order:
//
//  1. A *context* names the screen the user is looking at. The SDK only
//     considers campaigns configured for the context currently set, which is
//     what stops a campaign authored for the menu appearing over the cart.
//
//     Every screen sets one, including the ones no campaign targets. A context
//     stays active until replaced, so a screen that set none would inherit
//     whichever the previous screen left behind, and the next campaign would be
//     evaluated against the wrong screen.
//
//  2. A *request* asks whether anything is eligible. Setting a context shows
//     nothing on its own — only the screens that are campaign targets ask, so a
//     screen that sets a context but never asks can never display a campaign.
//
//  3. The *callbacks* report what happened. These are optional: the SDK records
//     its own impression, click and dismissal events whether or not a delegate
//     exists, and those are what the dashboard's figures are built from. The
//     delegate adds the app's own `InApp_Cta_Clicked` event, and is the only
//     route by which a custom action or a self-handled campaign reaches the app
//     at all.
//

import Foundation
import MoEngageInApps

// MARK: - Contexts

/// The screen currently on display, as campaigns refer to it.
///
/// Raw values are the contract with the MoEngage dashboard, and are identical to
/// the Android sample's — the same campaign then targets both platforms.
enum MoEngageInAppContext: String {

    case splash
    case login
    case permission
    case menu
    case category
    case item
    case cart
    case payment

    /// The token the dashboard knows this screen by. Spelled out because the
    /// case name and the token differ.
    case orderStatus = "order_status"

    case orders
    case profile
    case inbox
}

// MARK: - Module

enum MoEngageInApp {

    /// Scopes which campaigns are eligible to the screen now on display.
    ///
    /// The SDK takes a list, but the app always sets exactly one: a screen is a
    /// single context, and passing several would widen eligibility rather than
    /// describe where the user is.
    static func setContext(_ context: MoEngageInAppContext) {
        MoEngageSDKInApp.sharedInstance.setCurrentInAppContexts([context.rawValue])
    }

    /// Asks for a campaign eligible for the context now set.
    ///
    /// Nothing appears unless a campaign is configured, targets this user and
    /// matches the current context — so this is safe to call on arrival at any
    /// screen that is a campaign target.
    static func showInApp() {
        MoEngageSDKInApp.sharedInstance.showInApp()
            .onFailure { MoEngageReporting.failure("showInApp", $0) }
    }

    /// Asks for a nudge eligible for the context now set.
    ///
    /// Distinct from `showInApp`: a nudge anchors itself to a position rather
    /// than covering the screen, and the SDK matches it against nudge
    /// campaigns only. `.any` lets the campaign's own configured position win,
    /// which is what a sample app wants — the marketer decides, not the app.
    static func showNudge() {
        MoEngageSDKInApp.sharedInstance.showNudge(atPosition: .any)
            .onFailure { MoEngageReporting.failure("showNudge", $0) }
    }

    /// Registers the callbacks for campaigns being shown, acted on and
    /// dismissed. Called once at launch.
    static func registerCallbacks() {
        MoEngageSDKInApp.sharedInstance.setInAppDelegate(delegate)
    }

    /// Held here because the SDK keeps only a weak reference to the delegate.
    /// Passed as a temporary, it would be released the moment registration
    /// returned and every callback would be lost — with no error, and no crash.
    private static let delegate = Delegate()
}

// MARK: - Self-handled

extension MoEngageInApp {

    /// A self-handled campaign, decoupled from the SDK's own campaign type so
    /// the rest of the app can hold one without importing `MoEngageInApps`.
    ///
    /// `campaign` stays `fileprivate` for that reason: it exists only so this
    /// file can hand it back to the SDK when reporting shown, clicked or
    /// dismissed.
    struct SelfHandledPromo {
        let payload: PromoPayload
        fileprivate let campaign: MoEngageInAppSelfHandledCampaign

        fileprivate init(campaign: MoEngageInAppSelfHandledCampaign) {
            self.campaign = campaign
            guard
                let data = campaign.campaignContent.data(using: .utf8),
                let payload = try? JSONDecoder().decode(PromoPayload.self, from: data)
            else {
                self.payload = .fallback
                return
            }
            self.payload = payload
        }
    }

    /// Set by whichever screen is showing the self-handled promo card, so a
    /// campaign pushed while the app is foregrounded reaches it — see
    /// `Delegate.selfHandledInAppTriggered`. `nil` once nothing is listening.
    static var onSelfHandledPromoTriggered: ((SelfHandledPromo) -> Void)?

    /// Asks for a self-handled campaign eligible for the context now set.
    ///
    /// Nothing is drawn by the SDK: a self-handled campaign is a payload with
    /// no presentation, so this decodes it into `PromoPayload` and hands it
    /// back for the app to draw. `nil` means no eligible campaign, which is a
    /// normal outcome, not a failure.
    static func fetchSelfHandledPromo(completion: @escaping (SelfHandledPromo?) -> Void) {
        MoEngageSDKInApp.sharedInstance.getSelfHandledInApp()
            .onSuccess { result in
                completion(result.campaign.map(SelfHandledPromo.init(campaign:)))
            }
            .onFailure {
                MoEngageReporting.failure("getSelfHandledInApp", $0)
                completion(nil)
            }
    }

    /// Reports the promo card on screen. The dashboard's impression figures
    /// for a self-handled campaign come from this call alone — the SDK never
    /// sees the card itself.
    static func trackSelfHandledShown(_ promo: SelfHandledPromo) {
        MoEngageSDKInApp.sharedInstance.selfHandledShown(campaignInfo: promo.campaign)
            .onFailure { MoEngageReporting.failure("selfHandledShown", $0) }
    }

    /// Reports the card tapped.
    static func trackSelfHandledClicked(_ promo: SelfHandledPromo) {
        MoEngageSDKInApp.sharedInstance.selfHandledClicked(campaignInfo: promo.campaign)
            .onFailure { MoEngageReporting.failure("selfHandledClicked", $0) }
    }

    /// Reports the card dismissed without being tapped.
    static func trackSelfHandledDismissed(_ promo: SelfHandledPromo) {
        MoEngageSDKInApp.sharedInstance.selfHandledDismissed(campaignInfo: promo.campaign)
            .onFailure { MoEngageReporting.failure("selfHandledDismissed", $0) }
    }
}

// MARK: - Callbacks

extension MoEngageInApp {

    /// Receives the SDK's in-app callbacks.
    ///
    /// Two of these are not merely informational:
    ///
    /// - A custom action is key-value pairs the campaign author wrote. The SDK
    ///   has no idea what they mean, so if nothing is done with them here,
    ///   nothing happens at all.
    /// - A self-handled campaign is a payload with no presentation. Nothing
    ///   appears unless the app draws it.
    ///
    /// Deep-link CTAs do not arrive here. `shouldProvideDeeplinkCallback` is
    /// left at its default of `false`, which leaves the SDK to open the link —
    /// it reaches the app through `onOpenURL` like any other, and the tab bar
    /// routes it. The cost is that `InApp_Cta_Clicked` does not fire for those
    /// CTAs; the benefit is that a destination the app has not mapped yet still
    /// opens rather than dying silently. Setting that flag to `true` in
    /// Info.plist reverses both.
    final class Delegate: NSObject, MoEngageInAppNativeDelegate {

        // MARK: Lifecycle

        func inAppShown(
            withCampaignInfo inappCampaign: MoEngageInAppCampaign,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            log("shown", inappCampaign)
        }

        func inAppDismissed(
            withCampaignInfo inappCampaign: MoEngageInAppCampaign,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            log("dismissed", inappCampaign)
        }

        // MARK: Calls to action

        /// A CTA that navigates: a screen name, a rich landing or an external
        /// browser. Deep links are handled by the SDK and do not arrive here.
        func inAppClicked(
            withCampaignInfo inappCampaign: MoEngageInAppCampaign,
            andNavigationActionInfo navigationAction: MoEngageInAppNavigationAction,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            log("navigation CTA", inappCampaign)

            MoEngageSDKHelper.trackInAppCtaClicked(
                campaignID: inappCampaign.campaignId,
                cta: navigationAction.navigationUrl ?? ""
            )
        }

        /// A CTA carrying the campaign author's own key-value pairs.
        ///
        /// The sample reports which keys were carried and does nothing further,
        /// matching the Android sample. A real integration would read the
        /// values and act — apply the coupon, open the offer, whatever the
        /// pairs mean.
        func inAppClicked(
            withCampaignInfo inappCampaign: MoEngageInAppCampaign,
            andCustomActionInfo customAction: MoEngageInAppAction,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            log("custom CTA \(customAction.keyValuePairs)", inappCampaign)

            MoEngageSDKHelper.trackInAppCtaClicked(
                campaignID: inappCampaign.campaignId,
                cta: Self.ctaName(for: customAction)
            )
        }

        // MARK: Self-handled

        /// A campaign the app is expected to render itself.
        ///
        /// Handed to whichever screen is currently listening — the menu, for
        /// as long as its promo card is on screen — so a campaign pushed
        /// while the app is foregrounded reaches it without a second fetch.
        /// Ignored if nothing is listening.
        func selfHandledInAppTriggered(
            withInfo inappCampaign: MoEngageInAppSelfHandledCampaign,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            log("self-handled campaign available", inappCampaign)
            MoEngageInApp.onSelfHandledPromoTriggered?(.init(campaign: inappCampaign))
        }

        // MARK: Helpers

        /// Names a custom action by the keys it carried, not their values: the
        /// keys identify which control was tapped, which is the part worth
        /// segmenting on, while the values are per-user data to act on.
        ///
        /// Sorted because `Dictionary` has no defined order — unsorted, one
        /// campaign would report `"coupon,tier"` on one run and `"tier,coupon"`
        /// on the next, splitting into two values in the dashboard.
        private static func ctaName(for action: MoEngageInAppAction) -> String {
            action.keyValuePairs.keys.sorted().joined(separator: ",")
        }

        private func log(_ what: String, _ campaign: MoEngageInAppCampaign) {
            print("MoEngage | in-app \(what): \(campaign.campaignName)")
        }
    }
}
