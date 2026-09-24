//
//  AppDelegate.swift
//  MoEngageiOSSwiftUISampleApp
//

import UIKit
import MoEngageSDK
import UserNotifications
import MoEngageLiveActivity

class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Choosing how to configure the SDK
    //
    // The SDK can be initialized in two ways. Pick ONE:
    //
    //  A. Info.plist
    //     Every key already exists in Info.plist's `MoEngage` dictionary, with inline
    //     comments explaining each one. Just replace placeholders with your own values
    //  B. Code
    //    call setupSDK() from `didFinishLaunchingWithOptions` with passing your config values.
    //
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Enables all the default logs which are not specific to any particular instance.
        MoEngageSDKCore.sharedInstance.enableAllLogs()

        // OPTION A — update the values in Info.plist; the call below reads them
        //  including `IsTestEnvironment`, to decide whether to initialize the
        // test or live environment.
        MoEngage.sharedInstance.initializeDefaultInstance()

        // OPTION B — configuring in code by passing your config, uncomment below line
        //     setupSDK()

        setMessagingDelegate()

        // Campaign shown / clicked / dismissed callbacks. Registering these is
        // optional: the SDK reports its own impression and click events either
        // way. They are registered here so the app can add its own event, and
        // because a custom-action CTA reaches the app through no other route.
        MoEngageSDKHelper.registerInAppCallbacks()

        // Fence crossing callbacks. Registering them does not start
        // monitoring: that needs location permission, and is asked for from
        // the profile screen.
        MoEngageSDKHelper.registerGeofenceCallbacks()

        // Registration is split from the permission ask on purpose.
        //
        // `registerForRemoteNotification()` presents the system permission alert
        // when the status is undetermined, and iOS presents that alert once per
        // install. Calling it here would spend it before the user has seen the
        // app. The call below therefore registers only for a user who has
        // already answered, which refreshes their push token without prompting;
        // the opt-in screen asks everyone else, once it has explained why.
        MoEngageSDKHelper.refreshPushTokenIfAlreadyAnswered()

        // Alternative (iOS 12+): provisional authorization — no permission dialog.
        //   MoEngageSDKMessaging.sharedInstance.registerForRemoteProvisionalNotification()

        // Order-tracking Live Activity: watches for push tokens so MoEngage's
        // backend can update/end an activity later. Must run at launch, not
        // just after starting one — see MoEngageLiveActivity.swift.
        if #available(iOS 18, *) {
            MoEngageSDKHelper.registerForLiveActivityTokenUpdates()
        }

        return true
    }

    // MARK: - OPTION B: configuring the Initialization of SDK in the code
    //
    // Use this instead of the Info.plist `MoEngage` dictionary. Uncomment the method and
    // call `setupSDK()` from `didFinishLaunchingWithOptions` above.
    //
    //    private func setupSDK() {
    //        let sdkConfig = MoEngageSDKConfig(appId: "YOUR_WORKSPACE_ID", dataCenter: .data_center_01)
    //        sdkConfig.appGroupID = "group.YOUR_BUNDLE_ID.moengage"
    //
    //        // Console logs — keep out of Release builds.
    //    #if DEBUG
    //        sdkConfig.consoleLogConfig = MoEngageConsoleLogConfig(isLoggingEnabled: true, loglevel: .verbose)
    //    #endif
    //
    //        // Separate initialization methods for Dev and Prod.
    //    #if DEBUG
    //        MoEngage.sharedInstance.initializeDefaultTestInstance(sdkConfig)
    //    #else
    //        MoEngage.sharedInstance.initializeDefaultLiveInstance(sdkConfig)
    //    #endif
    //    }

    private func setMessagingDelegate() {
        MoEngageSDKMessaging.sharedInstance.setMessagingDelegate(self)
    }

    // NOTE: When `MoEngageAppDelegateProxyEnabled` is YES (the SDK default), MoEngage swizzles
    // these methods.
    // Uncomment these and handle them yourself if you set `MoEngageAppDelegateProxyEnabled`
    // to NO in Info.plist, where these below calls are required.
    //
    //    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //        MoEngageSDKMessaging.sharedInstance.setPushToken(deviceToken)
    //    }
    //
    //    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    //        MoEngageSDKMessaging.sharedInstance.didFailToRegisterForPush()
    //    }

    // MARK: - Deeplinks
    //
    // In the SwiftUI lifecycle, deeplinks normally arrive via the `.onOpenURL` /
    // `.onContinueUserActivity` modifiers on the root view (see the App struct) rather
    // than through AppDelegate. Uncomment these only if you set
    // `MoEngageAppDelegateProxyEnabled` to NO and need to forward manually here instead.
    //
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    //        MoEngageSDKAnalytics.sharedInstance.processURL(url)
    //        return true
    //    }
}

// MARK: - UNUserNotificationCenterDelegate

// Uncomment the below methods — and pass `self` to `registerForRemoteNotification(andUserNotificationCenterDelegate:)`,
// or assign `UNUserNotificationCenter.current().delegate = self` — when your need the
// notification callbacks itself, or when you set `MoEngageAppDelegateProxyEnabled` to NO, where
// the forwarding calls below are required.
// extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        MoEngageSDKMessaging.sharedInstance.userNotificationCenter(center, willPresent: notification)
//
//        completionHandler([.banner, .list, .sound, .badge])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        MoEngageSDKMessaging.sharedInstance.userNotificationCenter(center, didReceive: response)
//
//        completionHandler()
//    }
// }

// MARK: - MoEngageMessagingDelegate

extension AppDelegate: MoEngageMessagingDelegate {

    // Notification Clicked Callback
    func notificationClicked(withScreenName screenName: String?, andKVPairs kvPairs: [AnyHashable: Any]?) {
        if let screenName = screenName {
            print("Navigate to Screen:\(screenName)")
        }

        if let actionKVPairs = kvPairs {
            print("Selected Action KVPair:\(actionKVPairs)")
        }
    }

    // Notification Clicked Callback with Push Payload
    func notificationClicked(withScreenName screenName: String?, kvPairs: [AnyHashable: Any]?, andPushPayload userInfo: [AnyHashable: Any]) {

        print("Push Payload: \(userInfo)")

        if let screenName = screenName {
            print("Navigate to Screen:\(screenName)")
        }

        if let actionKVPairs = kvPairs {
            print("Selected Action KVPair:\(actionKVPairs)")
        }
    }

    func notificationRegistered(withDeviceToken deviceToken: String) {
        print("||++++++++++++++++++++++++++++++++++++++||")
        print("Device Token : \(deviceToken)")
        print("||++++++++++++++++++++++++++++++++++++++||")
    }
}
