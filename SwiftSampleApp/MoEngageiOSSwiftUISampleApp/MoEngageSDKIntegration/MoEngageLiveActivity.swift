//
//  MoEngageLiveActivity.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Order-tracking Live Activity: local start, and the launch-time listener
//  that syncs the activity's push token to MoEngage. Reached through
//  `MoEngageSDKHelper`, same as every other feature.
//
//  Updating and ending the activity are NOT handled here — there is no
//  client-side API for either. Both happen exclusively through MoEngage's
//  Inform API, called by the backend, referencing the same transactionId
//  used to start it below.
//

import Foundation
import ActivityKit
import MoEngageLiveActivity

@available(iOS 18, *)
typealias BrewOrderActivity = MoEngageTransactionActivity<BrewOrderAttributes>

@available(iOS 18, *)
typealias SaleBroadcastActivity = MoEngageActivity<SaleBroadcastAttributes>

enum MoEngageLiveActivityModule {

    /// The Live Activity campaign's identity on the MoEngage dashboard.
    /// Fixed — one campaign covers every order, distinguished at runtime by
    /// `transactionId`, not by creating a new campaignId per order.
    ///
    /// Replace with the real values once the campaign exists on the
    /// dashboard; the SDK cannot start this locally without them.
    private static let campaignId = "<real alert ID from MoEngage dashboard>"
    private static let campaignName = "<real alert name from MoEngage dashboard>"

    /// Registers to watch for Live Activity push tokens. Call once, from
    /// `didFinishLaunchingWithOptions` — this is what lets MoEngage's backend
    /// later reach a device to update or end an activity it didn't start.
    ///
    /// Must run at launch, not just after starting one: this also picks up
    /// activities that already existed before this app session.
    @available(iOS 18, *)
    static func registerForTokenUpdates() {
        Task {
            await MoEngageSDKLiveActivity.monitorLiveActivities(
                types: [BrewOrderAttributes.self]
            ) { data in
                print("MoEngage | Live Activity token registered for transaction \(data.tokenData.transactionId)")
            }
        }
    }

    /// Starts the order-tracking Live Activity locally, the moment an order
    /// is placed while the app is open.
    @available(iOS 18, *)
    static func startOrderTracking(orderID: String, status: String, etaMinutes: Int) {
        let campaign = MoEngageSDKLiveActivity.TransactionCampaign<BrewOrderAttributes>(
            campaignId: campaignId,
            campaignName: campaignName,
            transactionId: orderID,
            attributeType: "\(BrewOrderAttributes.self)",
            instanceId: UUID().uuidString,
            appAttributes: BrewOrderAttributes(),
            appContent: .init(status: status, etaMinutes: etaMinutes)
        )

        MoEngageSDKLiveActivity.createAttributes(withCampaign: campaign) { result in
            guard let result else {
                print("MoEngage | No Live Activity creation result")
                return
            }
            do {
                // Not calling trackStarted here: the SDK's own
                // monitorLiveActivities listener (registered at launch)
                // calls it automatically the moment this activity's push
                // token generates. Calling it again here hits the SDK's
                // duplicate-tracking guard and crashes.
                _ = try BrewOrderActivity.request(
                    attributes: result.attributes,
                    content: .init(state: result.content, staleDate: nil),
                    pushType: .token
                )
            } catch {
                print("MoEngage | Live Activity start failed: \(error)")
            }
        }
    }

    // MARK: - Broadcast (sale) — secondary, opt-in local start

    /// Identifies this broadcast campaign for MoEngage's analytics — plain
    /// metadata, unrelated to Apple's push channel below. Matches whatever
    /// campaign you set up on the dashboard, same idea as the transactional
    /// campaignId above.
    private static let saleCampaignId = "<real campaign ID from MoEngage dashboard>"

    /// Apple's broadcast push channel — every device subscribed to this
    /// channel receives the same update at once. This is DIFFERENT from a
    /// per-activity push token. For now, set directly from Apple's Push
    /// Notifications console (Channels tab) for local testing — normally
    /// this would come from MoEngage's create-campaign API response.
    private static let saleChannelId = "+kt9m+OsEfAAADpQ490hNw=="

    /// Starts the sale broadcast locally — an OPT-IN path for a user who
    /// wants to follow along even though the primary way this starts is
    /// push-to-start, triggered server-side for the whole target audience
    /// when the sale goes live. The SDK already watches for the
    /// push-to-start token automatically at init; nothing else to register
    /// for that path.
    @available(iOS 18, *)
    static func startSaleBroadcast(saleName: String, discountText: String, timeRemaining: String) {
        let campaign = MoEngageSDKLiveActivity.Campaign<SaleBroadcastAttributes>(
            campaignId: saleCampaignId,
            campaignName: saleName,
            deliveryType: "Broadcast Live Activity",
            attributeType: "\(SaleBroadcastAttributes.self)",
            instanceId: UUID().uuidString,
            appAttributes: SaleBroadcastAttributes(saleName: saleName),
            appContent: .init(discountText: discountText, timeRemaining: timeRemaining)
        )

        MoEngageSDKLiveActivity.createAttributes(withCampaign: campaign) { result in
            guard let result else {
                print("MoEngage | No broadcast Live Activity creation result")
                return
            }
            do {
                // .channel, NOT .token — broadcast activities share one
                // update channel across every subscribed device, unlike
                // order tracking's per-activity token. staleDate/
                // relevanceScore/style match MoEngage's own reference
                // example exactly (Examples/MoEngageTestApp).
                let activity = try SaleBroadcastActivity.request(
                    attributes: result.attributes,
                    content: .init(state: result.content, staleDate: .distantFuture, relevanceScore: 10),
                    pushType: .channel(saleChannelId), style: .standard
                )
                // Unlike order tracking, this call IS required here: there's
                // no monitorLiveActivities-style listener for broadcast
                // activities, so nothing calls trackStarted automatically.
                MoEngageSDKLiveActivity.trackStarted(activity: activity)
            } catch {
                print("MoEngage | Broadcast Live Activity start failed: \(error)")
            }
        }
    }
}
