//
//  NotificationViewController.swift
//  PushTemplateExtension
//
//  Created by Deepa on 06/09/22.
//
//  Manual-integration alternative. Not embedded by default: the app targets use the
//  MoEngage Extensions Integrator build phase instead. See README.md to switch.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MoEngageRichNotification

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Must be the same App Group ID as `MoEngageSDKConfig.appGroupID` in the
        // app, so the extension and the app share MoEngage data.
        MoEngageSDKRichNotification.setAppGroupID("group.YOUR_BUNDLE_ID.moengage")
    }
    
    func didReceive(_ notification: UNNotification) {
        // Renders the MoEngage push template carried in the notification into
        // this view controller.
        MoEngageSDKRichNotification.addPushTemplate(toController: self, withNotification: notification)
    }

}
