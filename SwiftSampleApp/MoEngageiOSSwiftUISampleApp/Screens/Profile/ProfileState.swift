//
//  ProfileState.swift
//  MoEngageiOSSwiftUISampleApp
//
//  What the profile screen can report about permissions, and the only place
//  the app asks for location.
//
//  Both grants shown here can be changed in Settings while the app is
//  backgrounded, so nothing is cached: the screen re-reads on every
//  appearance and whenever the app becomes active again.
//
//  Geofence monitoring is started from here rather than at launch, because it
//  needs location permission first — see `MoEngageGeofence`.
//

import Foundation
import CoreLocation
import UIKit

@MainActor
final class ProfileState: NSObject, ObservableObject {

    // MARK: - Notifications

    /// The user has allowed notifications.
    @Published private(set) var isPushGranted = false

    /// The user has refused, or has switched notifications off in Settings.
    /// Distinct from simply not having been asked, because only one of those
    /// two can still be resolved inside the app.
    @Published private(set) var isPushBlocked = false

    /// The permission alert has been answered, either way.
    ///
    /// What decides whether the app can still prompt: iOS presents that alert
    /// once per install, so after an answer exists only Settings can change it.
    @Published private(set) var hasAnsweredPush = false

    // MARK: - Notification preferences

    /// The user wants offers and new-menu notifications. Kept on this device
    /// and mirrored onto the `offers_opt_in` attribute on every change.
    @Published private(set) var isOffersOptedIn = false

    /// The user wants marketing campaigns. Mirrored onto `marketing_opt_in`.
    @Published private(set) var isMarketingOptedIn = false

    private enum PreferenceKey {
        static let offers = "profile.offersOptIn"
        static let marketing = "profile.marketingOptIn"
    }

    // MARK: - Location

    @Published private(set) var locationStatus: CLAuthorizationStatus = .notDetermined

    /// False when the user chose "Precise: Off" on the prompt. Without full
    /// accuracy iOS does not monitor fences at all.
    @Published private(set) var isPreciseLocation = false

    /// True once the SDK has been asked to watch the workspace's fences.
    @Published private(set) var isMonitoringGeofences = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        readLocation()
        readNotificationPreferences()
    }

    // MARK: - Reading

    func refresh() async {
        isPushGranted = await MoEngageSDKHelper.isPushAuthorized()
        hasAnsweredPush = await MoEngageSDKHelper.hasAnsweredPushPermission()
        isPushBlocked = hasAnsweredPush && !isPushGranted
        readLocation()
    }

    private func readLocation() {
        if #available(iOS 14.0, *) {
            locationStatus = locationManager.authorizationStatus
            isPreciseLocation = locationManager.accuracyAuthorization == .fullAccuracy
        } else {
            // iOS 13 has no per-app precise-location toggle — full accuracy
            // is simply what "authorized" means there.
            locationStatus = CLLocationManager.authorizationStatus()
            isPreciseLocation = true
        }
    }

    // MARK: - Asking

    /// Advances location permission by one step.
    ///
    /// iOS does not allow jumping straight to "always": the app must hold
    /// when-in-use before it can ask to extend it. So this asks for whichever
    /// is next, and the screen calls it again for the second step.
    ///
    /// iOS may also defer the "always" prompt and present it later on its own
    /// schedule, which is expected rather than a failure.
    func requestLocation() {
        switch locationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func setOffersOptIn(_ enabled: Bool) {
        isOffersOptedIn = enabled
        UserDefaults.standard.set(enabled, forKey: PreferenceKey.offers)
        MoEngageSDKHelper.setNotificationPreference(.offers, enabled: enabled)
    }

    func setMarketingOptIn(_ enabled: Bool) {
        isMarketingOptedIn = enabled
        UserDefaults.standard.set(enabled, forKey: PreferenceKey.marketing)
        MoEngageSDKHelper.setNotificationPreference(.marketing, enabled: enabled)
    }

    /// Forgets both answers, for sign-out. Nothing is sent: signing out resets
    /// the MoEngage user, so the attributes go with it, and the next user
    /// starts opted out until they choose otherwise.
    func resetNotificationPreferences() {
        isOffersOptedIn = false
        isMarketingOptedIn = false
        UserDefaults.standard.removeObject(forKey: PreferenceKey.offers)
        UserDefaults.standard.removeObject(forKey: PreferenceKey.marketing)
    }

    private func readNotificationPreferences() {
        isOffersOptedIn = UserDefaults.standard.bool(forKey: PreferenceKey.offers)
        isMarketingOptedIn = UserDefaults.standard.bool(forKey: PreferenceKey.marketing)
    }

    /// Opens this app's page in Settings, for a permission the app can no
    /// longer ask about itself.
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Geofence

    /// Starts monitoring, if location now allows it.
    ///
    /// Called after every grant rather than once: the first grant may be
    /// when-in-use, and the user may extend it to always later.
    ///
    /// The SDK accepts either grant, but they are not equivalent:
    ///
    /// - With when-in-use, iOS delivers fence crossings only while the app is
    ///   in use. Entering or leaving a fence in the background, which is what
    ///   a "greet you near the store" campaign relies on, needs always. That
    ///   is why MoEngage's docs list always as required.
    /// - With approximate location (precise location off), iOS does not
    ///   monitor regions at all, whatever the grant. The SDK does not check for
    ///   this, so the profile screen surfaces it instead.
    private func startMonitoringIfPermitted() {
        guard locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse else {
            return
        }
        guard !isMonitoringGeofences else { return }

        MoEngageSDKHelper.startGeofenceMonitoring()
        isMonitoringGeofences = true
    }
}

// MARK: - CLLocationManagerDelegate

extension ProfileState: CLLocationManagerDelegate {

    /// Fires for the answer to a prompt, and also when the user changes the
    /// grant in Settings while the app is running. iOS 14+ only — the system
    /// calls `locationManager(_:didChangeAuthorization:)` below instead on
    /// iOS 13, never both.
    @available(iOS 14.0, *)
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange()
    }

    /// The pre-iOS-14 counterpart of `locationManagerDidChangeAuthorization(_:)`,
    /// kept only so this target's iOS 13.0 minimum still gets the callback.
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationChange()
    }

    private nonisolated func handleAuthorizationChange() {
        Task { @MainActor in
            readLocation()

            if locationStatus == .denied || locationStatus == .restricted {
                if isMonitoringGeofences {
                    MoEngageSDKHelper.stopGeofenceMonitoring()
                    isMonitoringGeofences = false
                }
            } else {
                startMonitoringIfPermitted()
            }
        }
    }
}
