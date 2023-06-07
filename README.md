![Logo](https://github.com/moengage/MoEngage-iOS-SDK/blob/master/Images/moe_logo_blue.png)
# MoEngage-iOS-SDK

[![Version](https://img.shields.io/cocoapods/v/MoEngage-iOS-SDK.svg?style=flat)](http://cocoapods.org/pods/MoEngage-iOS-SDK)
[![License](https://img.shields.io/cocoapods/l/MoEngage-iOS-SDK.svg?style=flat)](http://cocoapods.org/pods/MoEngage-iOS-SDK)

MoEngage provides a platform which enables companies to deliver personalized interactions to their users through push notifications, in-app campaigns, email campaigns and other re-targeting channels.

## Integration

### Integration through CocoaPods
CocoaPods is a dependency manager for Objective C & Swift projects and makes integration easier.

1. If you don't have CocoaPods installed, you can do it by executing the following line in your terminal.

    ```sudo gem install cocoapods```
    
2. If you don't have a Podfile, create a plain text file named Podfile in the Xcode project directory with the following content, making sure to set the platform and version that matches your app.

    ```pod 'MoEngage-iOS-SDK'```
    
3. Install MoEngage SDK by executing the following in the Xcode project directory.

    ```pod install```
    
4. Now, open your project workspace and check if MoEngage SDK is properly added.
    

## SDK Initialization

Login to your MoEngage account, go to **Settings** in the left panel of the dashboard. Under App Settings, you will find your **APP ID**. Provide this APP ID along with DataCente while initializing the SDK with **initializeDefaultTestInstance:** and **initializeDefaultLiveInstance:** methods as shown below.

### In Swift:

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:     [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        //Create a config object
        let sdkConfig = MoEngageSDKConfig(appId: "YOUR APPID", dataCenter: "DATA_CENTER")
        sdkConfig.enableLogs = true
        
        // Separate initialization methods for Test and Live Environments
        #if DEBUG
             MoEngage.sharedInstance.initializeDefaultTestInstance(sdkConfig)
        #else
            MoEngage.sharedInstance.initializeDefaultLiveInstance(sdkConfig))
        #endif
        
        //Rest of the implementation of method
        //-------
    }

### Data Center
Following details of the different data centers you need to set based on the dashboard hosts

    Data Center     | Dashboard host
    -------------   | -------------
    data_center_01  | dashboard-01.moengage.com
    data_center_02  | dashboard-02.moengage.com
    data_center_03  | dashboard-03.moengage.com
    data_center_04  | dashboard-04.moengage.com
    data_center_05  | dashboard-05.moengage.com

Thats it!! SDK is successfully integrated and initialized in the project, and ready to use. 

## Developer Docs
Please refer to our developer docs to know how to make use of our SDK to track Events and User Attributes, to implement Push Notification and InApps: [link](https://developers.moengage.com/hc/en-us/articles/4403905883796-Tracking-user-attributes).

## Change Log
See [SDK Change Log](https://developers.moengage.com/hc/en-us/articles/4404198236564-Changelog) for information on every released version.

## Support
For any issues you face with the SDK and for any help with the integration contact us at `support@moengage.com`.