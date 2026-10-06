//
//  MoEngageiOSSwiftUISampleAppApp.swift
//  MoEngageiOSSwiftUISampleApp
//
//  SwiftUI app entry point. MoEngage init/push wiring lives in AppDelegate,
//  attached here via @UIApplicationDelegateAdaptor — everything downstream
//  (tracking, in-app, push, deep links) works exactly as it does in the
//  UIKit sample target.
//

import SwiftUI
import MoEngageSDK

@main
struct MoEngageiOSSwiftUISampleAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
            // NOTE: Deep links and universal links are NOT tracked automatically in a
            // SwiftUI app. MoEngage's scene delegate swizzling cannot reach SwiftUI's
            // own scene delegate, so each link must be reported with `processURL`.
            // This app does that in the `.onOpenURL` handlers that already route the
            // link (`ContentView` and `MainTabView`), through
            // `MoEngageSDKHelper.trackDeepLinkOpened(_:)`. Universal links reach those
            // handlers too, because no `.onContinueUserActivity` is registered.
            //
            // An app with no routing handler of its own can report links here instead:
            //
            //    .onOpenURL { url in
            //        MoEngageSDKAnalytics.sharedInstance.processURL(url)
            //    }
            //
            // If you register `.onContinueUserActivity(NSUserActivityTypeBrowsingWeb)`,
            // universal links go there instead of `.onOpenURL`, so call `processURL`
            // in it too.
        }
    }
}
