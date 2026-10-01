//
//  NotificationService.swift
//  NotificationServices
//
//  Created by Deepa on 06/09/22.
//
//  Manual-integration alternative. Not embedded by default: the app targets use the
//  MoEngage Extensions Integrator build phase instead. See README.md to switch.
//

import UserNotifications

import MoEngageRichNotification

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        // Must be the same App Group ID as `MoEngageSDKConfig.appGroupID` in the
        // app, so the extension and the app share MoEngage data.
        MoEngageSDKRichNotification.setAppGroupID("group.YOUR_BUNDLE_ID.moengage")
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // Downloads the notification's media, tracks its impression and updates
        // the badge, then passes the updated content to `contentHandler`.
        MoEngageSDKRichNotification.handle(richNotificationRequest: request, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the system terminates the extension. Delivers the
        // unmodified content so the notification is still shown if rich content
        // processing has not finished in time.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
