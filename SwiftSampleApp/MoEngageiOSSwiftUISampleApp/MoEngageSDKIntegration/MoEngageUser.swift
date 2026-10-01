//
//  MoEngageUser.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Identity and user attributes. Reached through `MoEngageSDKHelper`.
//
//  Two kinds of attribute are set here, and the distinction matters:
//
//  - Reserved attributes have dedicated setters (`setMobileNumber`, `setName`,
//    `setEmailID`, `setDateOfBirthInISO`). MoEngage maps these onto known
//    dashboard fields.
//  - Custom attributes go through `setUserAttribute(_:withAttributeName:)` and
//    appear under the name given. The taste-profile values are custom.
//
//  Calls are not awaited. The SDK batches and flushes on its own schedule, so
//  sign-in proceeds immediately rather than blocking on analytics. Each call
//  reports its own failure through `MoEngageReporting`.
//

import Foundation
import MoEngageSDK

enum MoEngageUser {

    /// Names of the custom attributes this app writes.
    enum Attribute {
        static let favouriteDrink = "favourite_drink"
        static let milkPreference = "milk_preference"
        static let sweetness = "sweetness"
        static let homeStore = "home_store"
        static let offersOptIn = "offers_opt_in"
        static let marketingOptIn = "marketing_opt_in"
    }

    /// The in-app notification categories on the profile screen.
    ///
    /// These belong to the app, not to iOS: push permission says whether the
    /// app may notify at all, while these say which kinds the user wants. The
    /// SDK has no equivalent, so each is mirrored onto its own attribute.
    enum NotificationPreference {
        case offers
        case marketing

        var attributeName: String {
            switch self {
            case .offers: return Attribute.offersOptIn
            case .marketing: return Attribute.marketingOptIn
            }
        }
    }

    /// Establishes the signed-in identity and its reserved attributes.
    ///
    /// `identifyUser` comes first and must: it sets the unique identifier that
    /// every attribute below attaches to. Setting attributes before an identity
    /// exists writes them against the anonymous user instead.
    static func onLoginSucceeded() {

        MoEngageSDKAnalytics.sharedInstance.identifyUser(identity: DemoUser.id)
            .onFailure { MoEngageReporting.failure("identifyUser", $0) }

        MoEngageSDKAnalytics.sharedInstance.setMobileNumber(DemoUser.phoneE164)
            .onFailure { MoEngageReporting.failure("setMobileNumber", $0) }

        MoEngageSDKAnalytics.sharedInstance.setName(DemoUser.name)
            .onFailure { MoEngageReporting.failure("setName", $0) }

        MoEngageSDKAnalytics.sharedInstance.setFirstName(DemoUser.firstName)
            .onFailure { MoEngageReporting.failure("setFirstName", $0) }

        MoEngageSDKAnalytics.sharedInstance.setLastName(DemoUser.lastName)
            .onFailure { MoEngageReporting.failure("setLastName", $0) }

        MoEngageSDKAnalytics.sharedInstance.setEmailID(DemoUser.email)
            .onFailure { MoEngageReporting.failure("setEmailID", $0) }

        MoEngageSDKAnalytics.sharedInstance.setDateOfBirthInISO(DemoUser.taste.birthdayISO)
            .onFailure { MoEngageReporting.failure("setDateOfBirthInISO", $0) }
    }
    
    /// Ends the signed-in session.
    ///
    /// Invalidates the identity and its attributes, so everything tracked
    /// afterwards belongs to a new, anonymous user rather than to whoever just
    /// signed out.
    static func logout() {
        MoEngageSDKAnalytics.sharedInstance.resetUser()
            .onFailure { MoEngageReporting.failure("resetUser", $0) }
    }

    /// Records the user's answer for one notification category.
    static func setNotificationPreference(_ preference: NotificationPreference, enabled: Bool) {
        MoEngageSDKAnalytics.sharedInstance.setUserAttribute(enabled, withAttributeName: preference.attributeName)
            .onFailure { MoEngageReporting.failure(preference.attributeName, $0) }
    }

    static func syncTasteProfile() {

        let taste = DemoUser.taste

        MoEngageSDKAnalytics.sharedInstance.setUserAttribute(taste.favouriteDrink, withAttributeName: Attribute.favouriteDrink)
            .onFailure { MoEngageReporting.failure(Attribute.favouriteDrink, $0) }

        MoEngageSDKAnalytics.sharedInstance.setUserAttribute(taste.milk, withAttributeName: Attribute.milkPreference)
            .onFailure { MoEngageReporting.failure(Attribute.milkPreference, $0) }

        MoEngageSDKAnalytics.sharedInstance.setUserAttribute(taste.sweetness, withAttributeName: Attribute.sweetness)
            .onFailure { MoEngageReporting.failure(Attribute.sweetness, $0) }

        MoEngageSDKAnalytics.sharedInstance.setUserAttribute(taste.homeStore, withAttributeName: Attribute.homeStore)
            .onFailure { MoEngageReporting.failure(Attribute.homeStore, $0) }
    }
}
