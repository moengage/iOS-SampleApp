//
//  MoEngageSwitUISampleAppApp.swift
//  MoEngageSwitUISampleApp
//
//  Created by Deepa on 20/12/22.
//

import SwiftUI
import MoEngageSDK

@main
struct MoEngageSwitUISampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            let _ = enableSDK()
            ContentView()
        }
    }
    
    func enableSDK() {
        let sdkConfig = MoEngageSDKConfig(withAppID: "DAO6UGZ73D9RTK8B5W96TPYN")
        sdkConfig.moeDataCenter = MoEngageDataCenter.data_center_01
        sdkConfig.appGroupID = "group.com.alphadevs.MoEngage.NotificationServices"
        sdkConfig.analyticsDisablePeriodicFlush = false
        sdkConfig.analyticsPeriodicFlushDuration = 60
        sdkConfig.encryptNetworkRequests = false
        sdkConfig.enableLogs = true
        
        
#if DEBUG
        MoEngage.sharedInstance.initializeDefaultTestInstance(sdkConfig, sdkState: .enabled)
#else
        MoEngage.sharedInstance.initializeDefaultLiveInstance(sdkConfig, sdkState: .enabled)
#endif
        
        MoEngage.sharedInstance.enableSDK()
    }
}
