//
//  MoEngagePush.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Push registration and notification permission. Reached through
//  `MoEngageSDKHelper`.
//

import Foundation
import UserNotifications
import MoEngageSDK

enum MoEngagePush {

    /// Registers with APNs only when the user has already answered the
    /// permission alert, so the token stays current without prompting.
    ///
    /// Called at launch. Does nothing while the status is undetermined; the
    /// opt-in screen owns that case.
    static func refreshTokenIfAlreadyAnswered() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus != .notDetermined else { return }
            DispatchQueue.main.async {
                MoEngageSDKMessaging.sharedInstance.registerForRemoteNotification()
            }
        }
    }

    /// Presents the system permission alert and registers for a push token.
    ///
    /// Call in response to a deliberate user action. Has no visible effect once
    /// the user has already answered.
    static func requestPermission() {
        MoEngageSDKMessaging.sharedInstance.registerForRemoteNotification()
    }

    /// Whether notifications are currently permitted.
    ///
    /// Provisional authorization counts as permitted: notifications are
    /// delivered, quietly, without the user having been asked.
    static func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    /// Whether the user has answered the permission alert, either way.
    ///
    /// Distinct from `isAuthorized()`: it separates "declined" from "not yet
    /// asked", which the opt-in screen needs in order to know when to move on.
    static func hasBeenAsked() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus != .notDetermined
    }

    /// Opens this app's notification settings, the only route back once the
    /// user has declined.
    static func openNotificationSettings() {
        MoEngageSDKMessaging.sharedInstance.navigateToPushSettings()
    }
}
