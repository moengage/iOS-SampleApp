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
                .onOpenURL { url in
                    
                    MoEngageSDKAnalytics.sharedInstance.processURL(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    MoEngageSDKAnalytics.sharedInstance.processURL(url)
                }
        }
    }
}
