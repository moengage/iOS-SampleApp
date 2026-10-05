//
//  MoEngageCardsTab.swift
//  MoEngageiOSSampleApp
//
//  Cards, using the SDK's own ready-made screen. UIKit targets only.
//
//  Lives outside `MoEngageSDKIntegration/` on purpose: that folder is also
//  compiled into the SwiftUI app, which does not link `MoEngageCards`.
//
//  The SDK draws everything — categories, card templates, pull to refresh,
//  delete — and records impressions, clicks and deletions itself, so there is
//  nothing to track here. A card's deep-link action is opened by the SDK and
//  arrives at `SceneDelegate` like any other `brewbar://` link, landing on
//  the matching `Route`.
//
//  To intercept a click instead, pass a `MoEngageCardsViewControllerDelegate`
//  and return `false` from `cardClicked(withCardInfo:andAction:forAccountMeta:)`.
//  To restyle the screen, pass a `MoEngageCardsUIConfiguration`.
//

import UIKit
import MoEngageCards

enum MoEngageCardsTab {

    /// Builds the SDK's cards screen, ready to be the root of a navigation
    /// controller.
    ///
    /// Asynchronous because the SDK resolves its instance first. The
    /// completion is not called when the SDK has no initialized instance —
    /// for example, a placeholder workspace ID — so the caller keeps whatever
    /// it was showing.
    @MainActor
    static func makeViewController(_ completion: @escaping (UIViewController) -> Void) {
        MoEngageSDKCards.sharedInstance.getCardsViewController(
            withUIConfiguration: nil,
            withCardsViewControllerDelegate: nil
        ) { cardsVC in
            guard let cardsVC else {
                print("MoEngage | cards screen unavailable — is the SDK initialized?")
                return
            }
            completion(cardsVC)
        }
    }
}
