//
//  NotificationViewController.swift
//  PushTemplateExtension
//
//  Created by Deepa on 06/09/22.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MoEngageRichNotification

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set App Group ID
        MoEngageSDKRichNotification.setAppGroupID("group.com.alphadevs.MoEngage.NotificationServices")
    }
    
    func didReceive(_ notification: UNNotification) {
        // Method to add template to UI
        MoEngageSDKRichNotification.addPushTemplate(toController: self, withNotification: notification)
    }

}
