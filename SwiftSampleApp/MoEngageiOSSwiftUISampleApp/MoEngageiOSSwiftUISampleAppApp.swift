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
            // NOTE: MoEngage tracks deep links and universal links on its own through
            // scene delegate swizzling, which is on by default. If you set
            // `MoEngageSceneDelegateProxyEnabled` to NO in Info.plist, uncomment the
            // modifiers below to report them yourself.
            //
            //    .onOpenURL { url in
            //        MoEngageSDKAnalytics.sharedInstance.processURL(url)
            //    }
            //    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            //        guard let url = userActivity.webpageURL else { return }
            //        MoEngageSDKAnalytics.sharedInstance.processURL(url)
            //    }
        }
    }
}
