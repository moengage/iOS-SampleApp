//
//  MoEngageGeofence.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Location-triggered campaigns. Reached through `MoEngageSDKHelper`.
//
//  A fence is a circle drawn in the MoEngage dashboard, not in the app. The app
//  only asks the SDK to start watching; the SDK fetches the workspace's fences
//  and registers them with CoreLocation, which is what actually does the
//  watching. Nothing here polls, and no coordinates are handled.
//
//  Monitoring is deliberately not started at launch. It needs location
//  permission, and starting before the user has granted any fails silently —
//  no error, no exception, simply nothing watched. The app grants first and
//  then starts, which is why this is driven from the profile screen.
//
//  Two things outside this file are required or nothing will ever fire:
//  `NSLocationWhenInUseUsageDescription` and its "always" counterpart in
//  Info.plist, and at least one fence configured in the dashboard.
//

import Foundation
import CoreLocation
import MoEngageGeofence

enum MoEngageGeofenceModule {

    /// Starts fetching and monitoring the workspace's fences.
    ///
    /// Call only once location permission has been granted.
    static func startMonitoring() {
        MoEngageSDKGeofence.sharedInstance.startGeofenceMonitoring()
    }

    /// Stops monitoring. The counterpart to `startMonitoring`, for a user who
    /// withdraws permission.
    static func stopMonitoring() {
        MoEngageSDKGeofence.sharedInstance.stopGeofenceMonitoring()
    }

    /// Registers the crossing callbacks. Called once at launch.
    ///
    /// Optional: the SDK delivers the campaign attached to a fence whether or
    /// not a delegate exists. These callbacks are purely informational: they
    /// return nothing, so the app cannot stop the SDK handling a hit.
    static func registerCallbacks() {
        MoEngageSDKGeofence.sharedInstance.setGeofenceDelegate(delegate)
    }

    /// Held here for the same reason as the in-app delegate: the SDK keeps
    /// only a weak reference.
    private static let delegate = Delegate()
}

// MARK: - Callbacks

extension MoEngageGeofenceModule {

    final class Delegate: NSObject, MoEngageGeofenceDelegate {

        func geofenceEnterTriggered(
            withLocationManager locationManager: CLLocationManager?,
            andRegion region: CLRegion?,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            print("MoEngage | geofence entered: \(region?.identifier ?? "unknown")")
        }

        func geofenceExitTriggered(
            withLocationManager locationManager: CLLocationManager?,
            andRegion region: CLRegion?,
            forAccountMeta accountMeta: MoEngageAccountMeta
        ) {
            print("MoEngage | geofence exited: \(region?.identifier ?? "unknown")")
        }
    }
}
