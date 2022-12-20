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
        let sdkConfig = MoEngageSDKConfig(withAppID: "YOUR APP ID")
        sdkConfig.moeDataCenter = MoEngageDataCenter.data_center_01
        sdkConfig.appGroupID = "YOUR APP GROUP ID"
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
