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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupSDK(didFinishLaunchingWithOptions: launchOptions)
        setMessagingDelegate()
        MoEngageSDKMessaging.sharedInstance.registerForRemoteNotification(withCategories: nil, andUserNotificationCenterDelegate: self)
        disableBadgeReset()
        
        return true
    }
    
    private func setupSDK(didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let sdkConfig = MoEngageSDKConfig(appId: "APPID", dataCenter: .data_center_01)
        sdkConfig.appGroupID = "group.com.alphadevs.MoEngage.NotificationServices"
        // Enable logs to see the api calls happening in moengage
        sdkConfig.consoleLogConfig = MoEngageConsoleLogConfig(isLoggingEnabled: true, loglevel: .verbose)
        
        // storage  encryption
        sdkConfig.storageConfig = MoEngageStorageConfig(encryptionConfig: MoEngageStorageEncryptionConfig(isEncryptionEnabled: true))
        let teamId = "YOUR TEAM ID"
        sdkConfig.keyChainConfig = MoEngageKeyChainConfig(groupName: "\(teamId).com.alphadevs.MoEngage.keychain")
        
        // network encryption
        sdkConfig.networkConfig = MoEngageNetworkRequestConfig(authorizationConfig: MoEngageNetworkAuthorizationConfig(isJwtEnbaled: true), dataSecurityConfig: MoEngageNetworkDataSecurityConfig(isEncryptionEnabled: true, encryptionKeyDebug: "DEBUG KEY", encryptionKeyRelease: "RELEASE KEY"))
        
        // set true if user must be part of registration flow
        sdkConfig.userRegistrationConfig = MoEngageUserRegistrationConfig(isUserRegistrationEnabled: true)
        
        // Separate initialization methods for Dev and Prod initializations
#if DEBUG
        MoEngage.sharedInstance.initializeDefaultTestInstance(sdkConfig)
#else
        MoEngage.sharedInstance.initializeDefaultLiveInstance(sdkConfig)
#endif
        MoEngageSDKCore.sharedInstance.enableAllLogs()
    }
    
    private func setMessagingDelegate() {
        MoEngageSDKMessaging.sharedInstance.setMessagingDelegate(self)
    }
    
    private func disableBadgeReset() {
        // Uncomment the below line to disable resetting of badge count on every launch. By default value is set to false.
        MoEngageSDKMessaging.sharedInstance.disableBadgeReset(true)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //Remote notification Registration callback methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Call only if MoEngageAppDelegateProxyEnabled is NO
        MoEngageSDKMessaging.sharedInstance.setPushToken(deviceToken)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //Call only if MoEngageAppDelegateProxyEnabled is NO
        MoEngageSDKMessaging.sharedInstance.didFailToRegisterForPush()
    }

}

// MARK:- UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK:- UserNotifications Framework callback method
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //Call only if MoEngageAppDelegateProxyEnabled is NO
        MoEngageSDKMessaging.sharedInstance.userNotificationCenter(center, didReceive: response)
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //This is to only to display Alert and enable notification sound
        completionHandler([.sound, .badge, .alert])
    }
}

// MARK: - MOMessagingDelegate
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

