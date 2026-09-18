//
//  AppDelegate.swift
//  iosSampleApp
//
//  Created by Deepa on 05/09/22.
//

import UIKit
import MoEngageSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

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

        MoEngageSDKMessaging.sharedInstance.registerForRemoteNotification()

        // Alternative (iOS 12+): provisional authorization — no permission dialog.
        //   MoEngageSDKMessaging.sharedInstance.registerForRemoteProvisionalNotification()

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
    //        // ---------------------------------------------------------------------------
    //        // OPTIONAL security features — enable only after the matching dashboard setup,
    //        // and replace every placeholder. Enabling them with placeholder values makes
    //        // the SDK log fatal-level validation errors at init, and an invalid keychain
    //        // access group breaks device-ID persistence.
    //        // ---------------------------------------------------------------------------
    //
    //        // Storage encryption — requires a valid keychain access group.
    //        // let teamId = "YOUR_TEAM_ID"
    //        // sdkConfig.storageConfig = MoEngageStorageConfig(encryptionConfig: MoEngageStorageEncryptionConfig(isEncryptionEnabled: true))
    //        // sdkConfig.keyChainConfig = MoEngageKeyChainConfig(groupName: "\(teamId).YOUR_BUNDLE_ID.keychain")
    //
    //        // Network encryption — raw keys issued by MoEngage. Do not commit real keys.
    //        // sdkConfig.networkConfig = MoEngageNetworkRequestConfig(dataSecurityConfig: MoEngageNetworkDataSecurityConfig(isEncryptionEnabled: true, encryptionKeyDebug: "YOUR_DEBUG_KEY", encryptionKeyRelease: "YOUR_RELEASE_KEY"))
    //
    //        // JWT — meaningful only together with the user registration flow.
    //        // sdkConfig.networkConfig.authorizationConfig = MoEngageNetworkAuthorizationConfig(isJwtEnabled: true)
    //        // sdkConfig.userRegistrationConfig = MoEngageUserRegistrationConfig(isUserRegistrationEnabled: true)
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

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
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
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    //
    //        MoEngageSDKAnalytics.sharedInstance.processURL(url)
    //        return true
    //    }
    //
    //    func application(_ application: UIApplication,
    //                     continue userActivity: NSUserActivity,
    //                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    //        guard let incomingURL = userActivity.webpageURL else { return false}
    //        MoEngageSDKAnalytics.sharedInstance.processURL(incomingURL)
    //        return true
    //    }

}

// MARK: - UNUserNotificationCenterDelegate

// Uncomment the below methods  — and pass `self` to `registerForRemoteNotification(andUserNotificationCenterDelegate:)`,
// or assign `UNUserNotificationCenter.current().delegate = self` — when your need the
// notification callbacks itself, or when you set `MoEngageAppDelegateProxyEnabled` to NO, where
// the forwarding calls below are required.
// extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        MoEngageSDKMessaging.sharedInstance.userNotificationCenter(center, willPresent: notification)
//
//        if #available(iOS 14.0, *) {
//            completionHandler([.banner, .list, .sound, .badge])
//        } else {
//            completionHandler([.alert, .sound, .badge])
//        }
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
    func notificationClicked(withScreenName screenName: String?, andKVPairs kvPairs: [AnyHashable : Any]?) {
        if let screenName = screenName {
            print("Navigate to Screen:\(screenName)")
        }
        
        if let actionKVPairs = kvPairs {
            print("Selected Action KVPair:\(actionKVPairs)")
        }
    }
    
    // Notification Clicked Callback with Push Payload
    func notificationClicked(withScreenName screenName: String?, kvPairs: [AnyHashable : Any]?, andPushPayload userInfo: [AnyHashable : Any]) {
        
        print("Push Payload: \(userInfo)")
        
        if let screenName = screenName {
            print("Navigate to Screen:\(screenName)")
        }
        
        if let actionKVPairs = kvPairs {
            print("Selected Action KVPair:\(actionKVPairs)")
        }
    }
    
    func notificationRegistered(withDeviceToken deviceToken: String){
        print("||++++++++++++++++++++++++++++++++++++++||")
        print("Device Token : \(deviceToken)")
        print("||++++++++++++++++++++++++++++++++++++++||")
    }
}

