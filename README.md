![Logo](https://github.com/moengage/MoEngage-iOS-SDK/blob/master/Images/moe_logo_blue.png)
# MoEngage iOS SDK Integration Sample

A reference integration of the [MoEngage](https://www.moengage.com) iOS SDK, structured the way a production app would be.

[![Version](https://img.shields.io/cocoapods/v/MoEngage-iOS-SDK.svg?style=flat)](http://cocoapods.org/pods/MoEngage-iOS-SDK)
[![License](https://img.shields.io/cocoapods/l/MoEngage-iOS-SDK.svg?style=flat)](http://cocoapods.org/pods/MoEngage-iOS-SDK)

---

## Brew Bar

Brew Bar is a coffee-ordering app that demonstrates a complete MoEngage SDK integration in one realistic flow: sign in, browse the menu, build an order, pay, and track it.

It covers analytics events, user identity and attributes, push (permission, rich media, templates), in-app campaigns, nudges, self-handled in-apps, the notification inbox, geofencing, Personalize, Live Activities and deep links.

The same app ships as **three app targets** that compile the **same integration code**, so you can follow the one that matches your project setup:

| Scheme | UI | SDK via | Min iOS |
|---|---|---|---|
| `MoEngageiOSSwiftUISampleApp` | SwiftUI | Swift Package Manager | 15.0 |
| `MoEngageiOSSampleApp` | UIKit | Swift Package Manager | 13.0 |
| `MoEngageiOSCocoaSampleApp` | UIKit | CocoaPods | 13.0 |

The catalogue, orders and user are in-memory demo data. There is no backend, so all network traffic comes from the SDK.

### Contents

[Quick start](#quick-start) · [What it demonstrates](#what-it-demonstrates) · [Triggering each feature](#triggering-each-feature) · [Push and the notification extensions](#push-and-the-notification-extensions) · [Permissions](#permissions) · [Event dictionary](#event-dictionary) · [Screens and deep links](#screens-and-deep-links) · [Live Activities](#live-activities-ios-18) · [Project layout](#project-layout) · [Design decisions](#design-decisions) · [Troubleshooting](#troubleshooting) · [Test checklist](#test-checklist)

---

## Quick start

### 1. Install and open

```bash
cd SwiftSampleApp
pod install                                # only needed for MoEngageiOSCocoaSampleApp
open MoEngageiOSSampleApp.xcworkspace      # always open the workspace, not the .xcodeproj
```

The SPM targets resolve `https://github.com/moengage/MoEngage-iOS-SDK` automatically on first open.

### 2. Workspace ID and data centre

The SDK is configured **from Info.plist**, not from code. Each app's `Info.plist` has a `MoEngage` dictionary; `AppDelegate` calls:

```swift
MoEngage.sharedInstance.initializeDefaultInstance()
```

which reads that dictionary. Edit it in `MoEngageiOSSampleApp/Info.plist` (UIKit targets) and `MoEngageiOSSwiftUISampleApp/Info.plist` (SwiftUI target):

| Key | Sample value | What it does |
|---|---|---|
| `WorkspaceId` | `YOUR_WORKSPACE_ID` | **Required.** Dashboard → Settings → App → General. |
| `DataCenter` | `1` | **Required.** The data centre your workspace is on (1, 2, 3, 4, 5, 6). Must match the dashboard. |
| `IsTestEnvironment` | `$(SWIFT_ACTIVE_COMPILATION_CONDITIONS)` | A Bool, or a string that counts as *test* when it contains `DEBUG`. With this value, Debug builds go to the test environment and Release builds go to live, with no `#if DEBUG` in code. |
| `AppGroupName` | `group.YOUR_BUNDLE_ID.moengage` | Shared container between the app and its extensions. Must match the entitlements. |
| `LogLevel` | `5` | 0 none · 1 error · 2 warning · 3 info · 4 debug · 5 verbose. |
| `InAppShouldProvideDeeplinkCallback` | `true` | Sends in-app deep-link CTAs to the app's delegate instead of opening them. The app needs this to track `InApp_Cta_Clicked` and route the link itself. |
| `IsSdkAutoInitialisationEnabled` | `true` | Lets the SDK initialise itself on first use. This is a fallback only; the sample still initialises explicitly at launch. |
| `IsStorageEncryptionEnabled` / `KeychainGroupName` | `false` / `YOUR_TEAM_ID.YOUR_BUNDLE_ID.keychain` | Storage encryption. The keychain group is required only when encryption is on. |
| `IsNetworkEncryptionEnabled` / `EncryptionEncodedTestKey` / `EncryptionEncodedLiveKey` | `false` / `DASHBOARD_PROVIDED_BASE64_STRING` | Network encryption. Enable only after the dashboard setup. |
| `IsJwtEnabled` / `IsUserRegistrationEnabled` | `false` | JWT-authenticated requests and the user-registration flow. |

These keys sit at the top level of `Info.plist`, outside the `MoEngage` dictionary:

| Key | Default | Meaning |
|---|---|---|
| `MoEngageAppDelegateProxyEnabled` | `true` | The SDK swizzles the push callbacks on `UIApplicationDelegate` / `UNUserNotificationCenterDelegate`. Set to `false` for manual integration and uncomment the forwarding methods in `AppDelegate.swift`. |
| `MoEngageSceneDelegateProxyEnabled` | `true` | The SDK swizzles the scene URL callbacks to track deep links. If you set it to `false`, report links yourself with `processURL`. |
| `MoEngageBadgeUpdateEnabled` | `true` | Resets the badge on launch. Replaces the deprecated `disableBadgeReset(_:)`. |

> **Code-based initialisation.** `AppDelegate.swift` has a commented-out `setupSDK()` that builds a `MoEngageSDKConfig` and calls `initializeDefaultTestInstance` / `initializeDefaultLiveInstance`. Use **one** of the two approaches, not both.

### 3. Replace the placeholders

Nothing is hard-coded. Before you run, replace every placeholder:

| Placeholder | Where |
|---|---|
| `YOUR_WORKSPACE_ID` | Both `Info.plist` files (`WorkspaceId`) |
| `group.YOUR_BUNDLE_ID.moengage` | Both `Info.plist` files (`AppGroupName`); every `*.entitlements` file; **and in code** in `NotificationServices/NotificationService.swift` and `PushTemplateExtension/NotificationViewController.swift` |
| `YOUR_TEAM_ID.YOUR_BUNDLE_ID.keychain` / `$(AppIdentifierPrefix)YOUR_BUNDLE_ID.keychain` | `Info.plist` (`KeychainGroupName`) and app entitlements, if you use storage encryption |
| `com.companyName.moengage` | Bundle identifier of each target (Signing & Capabilities) |
| Development team | Empty on every target. Pick yours in Signing & Capabilities. |
| Live Activity campaign IDs | `MoEngageSDKIntegration/MoEngageLiveActivity.swift`; see [Live Activities](#live-activities-ios-18) |

> **The app group must be identical everywhere:** in the plist, in the app and extension entitlements, and in the two Swift extension files. A mismatch produces no error, but rich push media and impression tracking stop working.

### 4. Push (APNs)

1. Give the app a real bundle ID and team. Enable the **Push Notifications** and **App Groups** capabilities, and **Background Modes → Remote notifications** (already present in `Info.plist`).
2. Upload your APNs auth key (`.p8`) or certificate in the MoEngage dashboard under Settings → Channels → Push → iOS.
3. Run on a **physical device** for a real APNs token. The token is printed in the console by `notificationRegistered(withDeviceToken:)`.

See [Push and the notification extensions](#push-and-the-notification-extensions) for rich push and templates.

### 5. Toolchain

| | |
|---|---|
| Xcode | 16 or later (Live Activity code uses the iOS 18 SDK) |
| CocoaPods | 1.16.2 (`Podfile.lock`) |
| `MoEngage-iOS-SDK` | 11.02.0 in the Podfile (resolves `MoEngageSDK` 11.02.1, `MoEngageCore` 11.03.0); 11.2.0 via SPM |
| `MoEngagePersonalization` | 1.4.1 |
| Pod subspecs | InApps, Cards, GeoFence, RichNotification, Inbox, RealTimeTrigger, LiveActivity |
| Deployment targets | UIKit apps 13.0 · SwiftUI app 15.0 · Live Activity widgets 18.0 |

---

## What it demonstrates

Every SDK call the app makes goes through **one facade**, `MoEngageSDKIntegration/MoEngageSDKHelper.swift`. Screens call `MoEngageSDKHelper`. The helper is an index of one-line calls, and each one delegates to a per-feature file in the same folder.

All three app targets compile this folder, so the UIKit and SwiftUI apps make **exactly the same SDK calls**.

| Capability | SDK entry point | Helper | Fires from |
|---|---|---|---|
| Initialisation | `MoEngage.initializeDefaultInstance()` | — (`AppDelegate`) | App launch |
| Identity | `identifyUser(identity:)`, `setName`, `setEmailID`, `setMobileNumber`, `setDateOfBirthInISO`, … | `onLoginSucceeded()` | Login success |
| Custom attributes | `setUserAttribute(_:withAttributeName:)` | `syncTasteProfile()`, `setNotificationPreference(_:enabled:)` | Login, Profile toggles |
| Logout | `resetUser()` | `logout()` | Profile → Sign out |
| Events | `MoEngageSDKAnalytics.trackEvent(_:withProperties:)` | `track*` (see [Event dictionary](#event-dictionary)) | Across the order flow |
| Push permission and token | `MoEngageSDKMessaging.registerForRemoteNotification()`, `navigateToPushSettings()` | `requestPushPermission()`, `refreshPushTokenIfAlreadyAnswered()`, `openNotificationSettings()` | Opt-in screen, Profile, launch |
| Push click | `MoEngageMessagingDelegate.notificationClicked(withScreenName:kvPairs:andPushPayload:)` | `trackNotificationOpened` | Any push tap |
| Rich push and impressions | `MoEngageSDKRichNotification` | — (extension) | Notification Service extension |
| Push templates | `MoEngageSDKRichNotification.addPushTemplate` | — (extension) | Notification Content extension |
| In-app | `setCurrentInAppContexts`, `showInApp()` | `setInAppContext`, `showInApp()` | Menu, Item detail |
| Nudges | `showNudge(atPosition: .any)` | `showNudge()` | Orders |
| In-app callbacks and CTAs | `MoEngageInAppNativeDelegate` | `registerInAppCallbacks()`, `onInAppDeepLink`, `trackInAppCtaClicked` | Launch, any CTA |
| Self-handled in-app | `getSelfHandledInApp()`, `selfHandledShown/Clicked/Dismissed` | `fetchSelfHandledPromo`, `trackSelfHandled*` | Menu promo card |
| Inbox | `MoEngageSDKInbox.getInboxMessages`, `getUnreadNotificationCount`, `trackInboxClick`, `markInboxNotificationClicked` | `fetchInbox*`, `trackInboxMessageClicked`, `markInboxMessageRead` | Bell icon → Inbox |
| Geofence | `startGeofenceMonitoring()`, `stopGeofenceMonitoring()`, `MoEngageGeofenceDelegate` | `startGeofenceMonitoring()`, `registerGeofenceCallbacks()` | Profile → location toggle |
| Personalize | `MoEngageSDKPersonalize.fetchExperiencesMeta`, `fetchExperience`, `experienceShown`, `offeringsShown`, `offeringClicked` | `syncPersonalizeExperiences`, `fetchPersonalizeExperience`, `track*` | Profile → Personalize |
| Live Activities | `MoEngageSDKLiveActivity.monitorLiveActivities`, `createAttributes(withCampaign:)`, `trackStarted`, `moengageWidgetClickURL` | `registerForLiveActivityTokenUpdates()`, `startOrderTracking`, `trackOrderActivityOpened` | Launch, Payment, widget tap |
| Deep links | Scene-delegate swizzling (or `processURL`) | `Route(deeplink:)` | Push, in-app, inbox, widget |
| Cards (UIKit apps only) | `MoEngageSDKCards.getCardsViewController` (the SDK's own screen) | — (`MoEngageiOSSampleApp/MoEngageCardsTab.swift`) | Cards tab |

SDK calls that return a result handle failure through `.onFailure { MoEngageReporting.failure(...) }` in `MoEngageReporting.swift`, which logs the call name and the SDK's reason. None of them are awaited: the SDK batches and flushes on its own schedule, so screens never wait on analytics.

---

## Triggering each feature

| Feature | How to trigger it | Dashboard setup |
|---|---|---|
| **Identity** | Sign in on the Login screen | — (check the user's profile) |
| **Events** | Browse menu → item → add to cart → cart → pay | — (check Recent Events) |
| **Push permission** | Onboarding opt-in screen, or Profile | — |
| **Push** | Background the app | Push campaign to this user |
| **In-app** | Open the Menu, or any item | In-app with context `menu` or `item` |
| **Nudge** | Open the Orders tab | Nudge with context `orders` |
| **Self-handled in-app** | Open the Menu (card at the top) | Self-handled in-app with the JSON below |
| **Inbox** | Bell icon on the Menu | Any push received by this device |
| **Geofence** | Profile → enable location, then cross a fence | Geofence campaign with a fence |
| **Personalize** | Profile → Personalize, switch tabs | Experiences with the keys below |
| **Order Live Activity** | Place an order on iOS 18+ | Live Activity campaign (IDs in code) |
| **Cards** (UIKit apps) | Open the Cards tab | Cards campaign with at least one card |

### Feature notes

**Cards (UIKit only).** The UIKit apps show the SDK's ready-made cards screen in the Cards tab: `getCardsViewController` returns it, and `MainTabBarController` makes it the root of the tab's navigation controller. The SDK draws the categories and card templates and handles pull to refresh and delete. It also records impressions, clicks and deletions, so the app tracks nothing itself. A card's deep link is opened by the SDK and lands on the matching `Route` through `SceneDelegate`. To handle a click yourself, pass a `MoEngageCardsViewControllerDelegate` and return `false` from `cardClicked`. To restyle the screen, pass a `MoEngageCardsUIConfiguration`.

**In-app contexts.** Every screen sets a context when it appears, even screens no campaign targets: SwiftUI uses `.inAppContext(_:)` from `InAppContextModifier.swift`, and UIKit calls `setInAppContext` in each view controller. A context stays active until it is replaced, so a screen that set none would inherit the previous one. The context strings are listed in `MoEngageInAppContext`: `splash`, `login`, `permission`, `menu`, `category`, `item`, `cart`, `payment`, `order_status`, `orders`, `profile`, `personalize`, `inbox`. Setting a context shows nothing by itself; only the Menu and Item screens ask with `showInApp()`, and only Orders asks with `showNudge()`.

**In-app CTAs.** Because `InAppShouldProvideDeeplinkCallback` is `true`, a deep-link CTA reaches `inAppClicked(withCampaignInfo:andNavigationActionInfo:)`. The app reports `InApp_Cta_Clicked`, resolves the link with `Route(deeplink:)`, and switches to the right tab. A link that matches no route is opened with `UIApplication.open`. For custom-action CTAs, the app reports the sorted key names as the `cta` attribute.

> **The delegate must be retained.** The SDK holds in-app and geofence delegates **weakly**. The sample keeps them in a `static let`; if a temporary object is passed, the SDK does not deliver callbacks and no error is reported.

**Self-handled in-app.** The SDK returns raw JSON and draws nothing. The app decodes it into `PromoPayload`:

```json
{
  "title": "Members get more",
  "subtitle": "Tap to see today's offer",
  "code": "BREW20",
  "deeplink": "brewbar://item/flat-white"
}
```

`code` and `deeplink` are optional. A payload that is missing or fails to decode falls back to a default card. The app must report `selfHandledShown`, `selfHandledClicked` and `selfHandledDismissed` itself; the SDK does not record these events automatically.

**Inbox.** The app draws its own list from `getInboxMessages` rather than using the SDK's ready-made `presentInboxViewController`. Opening a message calls `trackInboxClick` **only**, because the SDK marks the message read and works out first-click vs repeat from its state at call time. "Mark all read" uses `markInboxNotificationClicked` so that nothing counts as a click. A fresh install has an empty inbox.

**Personalize.** The keys in `Screens/Personalize/PersonalizeContract.swift` are `brewbar_home_offer_with` (one offering), `brewbar_multi_offer` (several offerings) and `brewbar_home_rewards` (no offering, just content). The app calls `fetchExperiencesMeta` before the first fetch. The SDK validates experience keys against a locally cached list, so without this call a correctly configured experience returns `invalidExperienceKey` on a fresh install. `offeringClicked` also counts as the experience click, so do not call `experienceClicked` as well.

The call order for one experience, from `Screens/Personalize/PersonalizeState.swift` (used by both the UIKit and SwiftUI screens):

1. **Sync**: `fetchExperiencesMeta(status: [])` each time the screen opens. Repeated calls are inexpensive: within the sync interval, the SDK returns cached data without a network request.
2. **Fetch**: `fetchExperience(experienceKey:attributes:)`. The `attributes` (here `screen`, `demo_state`) go with this request only and are never written to the user's profile. A `nil` result is normal (no campaign, user outside the segment, control group), so the screen shows its fallback content.
3. **Shown**: once the result is on screen, call `experienceShown(campaign:)` once, then `offeringsShown(offeringPayloads:)` with the **whole, unmodified** offering dictionaries (the SDK reads `offering_context` from them). The SDK does not deduplicate offering impressions, so the app keeps track of which offerings it has already reported.
4. **Click**: `offeringClicked(campaign:offeringPayload:)` when an offering is tapped, then follow its deep link.

---

## Push and the notification extensions

There are **two ways** to add rich push and templates. The sample uses the first and keeps the second as a reference.

### Default: MoEngage Extensions Integrator (no extension code)

Each app target has a **"MoEngage Extensions Integrator"** Run Script build phase:

```bash
# CocoaPods target
"${PODS_ROOT}/MoEngageExtensionsIntegration/moengage-extensions-integration.artifactbundle/moengage-extensions-integration/bin/moengage-extensions-integration" --enable-push-notification-templates

# SPM targets
"${OBJROOT}/../../SourcePackages/artifacts/moengage-ios-sdk/moengage-extensions-integration/moengage-extensions-integration.artifactbundle/moengage-extensions-integration/bin/moengage-extensions-integration" --enable-push-notification-templates
```

At build time this tool copies MoEngage's prebuilt extensions into the app's `PlugIns/` folder and code-signs them:

| Extension | Bundle ID it is given | When |
|---|---|---|
| `MoEngageNotificationService.appex` (rich media, impressions) | `<app bundle id>.MoEngageNotificationService` | Always (turn off with `--disable-push-notification-service-extension`) |
| `MoEngageNotificationContent.appex` (push templates) | `<app bundle id>.MoEngageNotificationContent` | With `--enable-push-notification-templates` |

The tool reads `AppGroupName` and `KeychainGroupName` from the app's `MoEngage` plist dictionary to build the extensions' entitlements. With **Automatic** signing it generates them from the app's profile. With **Manual** signing you need provisioning profiles for the two bundle IDs above; set `MOENGAGE_NOTIFICATION_SERVICE_EXTENSION_PROFILE` / `MOENGAGE_NOTIFICATION_CONTENT_EXTENSION_PROFILE` if the tool cannot find them.

### Optional: embed your own extension targets

The Integrator is the default and needs no extension code. `NotificationServices/` and `PushTemplateExtension/` are hand-written extension targets, included as a reference. They are in the project but **not embedded** in any app by default. Embed them if you need to maintain the extensions yourself, for example to add custom code.

Use your own identifiers. Give each extension your own bundle ID (under your app's, e.g. `com.yourcompany.app.NotificationServices`), your own App Group, and your own keychain group. The values in this project are placeholders.

```swift
// NotificationService.swift
MoEngageSDKRichNotification.setAppGroupID("group.YOUR_BUNDLE_ID.moengage")
MoEngageSDKRichNotification.handle(richNotificationRequest: request, withContentHandler: contentHandler)

// NotificationViewController.swift
MoEngageSDKRichNotification.setAppGroupID("group.YOUR_BUNDLE_ID.moengage")
MoEngageSDKRichNotification.addPushTemplate(toController: self, withNotification: notification)
```

To switch:
1. Remove the "MoEngage Extensions Integrator" build phase from the app target.
2. Add both extensions under the app target's **Frameworks, Libraries and Embedded Content / Embed App Extensions**.
3. In Signing & Capabilities, set each extension's bundle ID and team to your own. Add **your** App Group to both extensions, and **your** keychain group to the service extension if you use storage encryption.
4. Replace `group.YOUR_BUNDLE_ID.moengage` in both Swift files with your App Group. It must match `AppGroupName` in the app's `Info.plist` and the app's entitlements.

> **Use one approach only.** If an app embeds two Notification Service extensions, iOS runs only one of them, and which one is not defined.

### Push clicks

`AppDelegate` implements only the payload variant `notificationClicked(withScreenName:kvPairs:andPushPayload:)`. The SDK calls both click callbacks on every tap, so implementing both would report `Notification_Opened` twice. The SDK opens the deep link itself, and it then reaches the app like any other URL.

---

## Permissions

### Push

`registerForRemoteNotification()` shows the system alert when permission is undetermined, and iOS shows that alert **once per install**. So:

- At launch, `refreshPushTokenIfAlreadyAnswered()` registers **only** if the user has already answered. This keeps the token current without prompting the user.
- The opt-in screen (`PushOptInView` / `PushOptInViewController`) asks after explaining why.
- Once the user has declined, `openNotificationSettings()` (`navigateToPushSettings`) is the only way for the user to re-enable notifications.
- Provisional authorisation counts as authorised. For a prompt-free start, call `registerForRemoteProvisionalNotification()`; the line is commented out in `AppDelegate`.

### Location (geofence)

The `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` and `NSLocationAlwaysUsageDescription` strings are set in the target build settings. Monitoring is **not** started at launch. Profile asks for permission first and only then calls `startGeofenceMonitoring()`.

> **Location permission is required first.** If monitoring is started without it, no fences are monitored and no error is reported. Fences are drawn in the dashboard, not in the app.

---

## Event dictionary

Defined once in `MoEngageSDKIntegration/MoEngageEvents.swift`. Campaigns and segments match these names exactly: renaming an event stops them from matching, and no error is reported.

| Event | Attributes | Fired from |
|---|---|---|
| `Menu_Viewed` | `store`, `category` | Menu |
| `Category_Browsed` | `category` | Menu category change |
| `Item_Viewed` | `item`, `price`, `category` | Item detail |
| `Add_To_Cart` | `item`, `size`, `milk`, `addons`, `amount` | Item detail → Add |
| `Cart_Viewed` | `items_count`, `amount` | Cart |
| `Checkout_Started` | `amount`, `fulfilment`, `coupon` | Payment |
| `Order_Placed` | `order_id`, `amount`, `mode`, `items_count` | Payment success |
| `Order_Picked_Up` | `order_id` | Order Live Activity tap |
| `Reorder_Tapped` | `item`, `order_id` | Orders / Home "usual" |
| `Notification_Opened` | `campaign_id`, `deeplink` | Push tap, order Live Activity tap |
| `InApp_Cta_Clicked` | `campaign_id`, `cta` | In-app CTA |

**Value conventions.** A missing value is sent as a placeholder rather than omitted, so the attribute is always present: `coupon` → `"none"`, `addons` → `"none"`, `campaign_id` → `"unknown"`, `deeplink` → `"none"`. Add-ons are sent as one comma-joined string. `items_count` counts cart lines, not total quantity.

`InApp_Cta_Clicked` is the app's own event. It is separate from the SDK's automatic `MOE_IN_APP_CLICKED`, which is what the dashboard's click-through figures use.

### User attributes

Defined in `MoEngageSDKIntegration/MoEngageUser.swift`.

| Key | Type | Set from |
|---|---|---|
| Unique ID, name, first/last name, email, mobile, date of birth | Reserved | `onLoginSucceeded()` |
| `favourite_drink`, `milk_preference`, `sweetness`, `home_store` | String | `syncTasteProfile()` at login |
| `offers_opt_in`, `marketing_opt_in` | Bool | Profile notification toggles |

### Identity calls

```swift
// Login: identity first, so the attributes attach to this user and not the anonymous one
MoEngageSDKAnalytics.sharedInstance.identifyUser(identity: DemoUser.id)
MoEngageSDKAnalytics.sharedInstance.setEmailID(DemoUser.email)

// Logout: everything tracked after this belongs to a new anonymous user
MoEngageSDKAnalytics.sharedInstance.resetUser()
```

---

## Screens and deep links

Splash → Login → Push opt-in → tabs (**Menu**, **Orders**, **Profile**). Menu leads to Category → Item → Cart → Payment → Order status, plus Inbox. Profile leads to Personalize.

Links resolve through `Route(deeplink:)` in `MoEngageiOSSwiftUISampleApp/Navigation/Route.swift`, which picks the right tab and pushes the screen onto it. URL schemes are `brewbar` (all apps), `deeplinkscheme` (UIKit) and `moengageswiftuisample` (SwiftUI).

| Link | Route |
|---|---|
| `brewbar://login` | Login |
| `brewbar://permission` | Push opt-in |
| `brewbar://category/<id>` | Category (unknown id falls back to the default category) |
| `brewbar://item/<id>` | Item detail (ignored without an id) |
| `brewbar://cart` | Cart |
| `brewbar://payment` | Payment |
| `brewbar://status/<orderId>` or `order_status/<orderId>` | Order status (no id → latest order) |
| `brewbar://orders` | Orders tab |
| `brewbar://inbox` | Inbox |
| `brewbar://personalize` | Personalize |

Deep-link tracking is automatic through scene-delegate swizzling. If you set `MoEngageSceneDelegateProxyEnabled` to `false`, uncomment the `processURL` calls in `MoEngageiOSSwiftUISampleAppApp.swift` (`.onOpenURL`) or `SceneDelegate.swift`.

---

## Live Activities (iOS 18)

The widget extension lives in `BrewOrderLiveActivity/`. It has two targets: `BrewOrderLiveActivityExtension` (SPM) and `BrewOrderLiveActivityCocoaExtension` (CocoaPods). Both are embedded in their app and compile the shared attribute types from `MoEngageiOSSwiftUISampleApp/Data/`.

| Activity | Attributes | Type | How it starts |
|---|---|---|---|
| Order tracking | `BrewOrderAttributes` (`status`, `etaMinutes`) | Transactional, per-activity push token | Locally, when an order is placed (Payment) |
| Sale broadcast | `SaleBroadcastAttributes` (`saleName`; `discountText`, `timeRemaining`) | Broadcast, APNs channel | Push-to-start from the server (primary), or locally with `startSaleBroadcast` (helper provided, not wired to a screen) |

**Before running**, fill in the constants at the top of `MoEngageSDKIntegration/MoEngageLiveActivity.swift` with values from your dashboard campaign: `campaignId`, `campaignName`, `saleCampaignId`, `saleChannelId`.

How the code fits together:

1. **At launch**, `monitorLiveActivities(types: [BrewOrderAttributes.self])` starts watching for push tokens. It must run at launch, not only after starting an activity, so that activities from an earlier session are picked up.
2. **Start (order)**: build a `TransactionCampaign` with `transactionId` = order ID, call `createAttributes(withCampaign:)`, then `Activity.request(..., pushType: .token)`. Do **not** call `trackStarted` here. The monitor calls it when the token arrives. A second call fails the SDK's duplicate-tracking validation, which raises a fatal error in the test environment when a debugger is attached.
3. **Start (broadcast)**: use `pushType: .channel(saleChannelId)` and **do** call `trackStarted(activity:)`, because no monitor covers broadcasts.
4. **Update and end** happen **only from the server**, through MoEngage's Inform API with the same `transactionId`. There is no client-side API for either.
5. **Tap**: the widget wraps its link in `.moengageWidgetClickURL(URL, context:, widgetId:)`, which adds `moe_transaction_id` and `cid`. The SDK tracks the click; `trackOrderActivityOpened(url)` also reports `Order_Picked_Up` and `Notification_Opened`.

`Info.plist` sets `NSSupportsLiveActivities = true`. To debug the widget, select its scheme. If it is missing, create it in Product → Manage Schemes, since the widget targets have no shared scheme.

> **Track only after init.** Live Activity tracking calls (`trackStarted`, click tracking) must run after the SDK is initialised. A call made earlier, or a duplicate `trackStarted`, raises a fatal error in the test environment when a debugger is attached; otherwise the call is ignored and logged.

### The contract between your server and your widget

The keys your server sends must match the Swift structs **exactly**. A mismatched key produces no error; the widget cannot decode the update, so it is not displayed.

| Server JSON | Swift (this sample) | Changes? |
|---|---|---|
| `attribute_type` | The struct's name: `"BrewOrderAttributes"` / `"SaleBroadcastAttributes"` | Never |
| `attribute_info` | Stored properties of the struct: none for `BrewOrderAttributes`; `saleName` for `SaleBroadcastAttributes` | Fixed at start |
| `content_state` | Properties of `ContentState`: `status`, `etaMinutes` / `discountText`, `timeRemaining` | Every update |

The SDK adds its own metadata alongside your keys and manages it internally; your server does not send it. As received on the device:

```json
// attributes (static)
{ "moengage": { "cid": "…", "moe_campaign_name": "…", "moe_delivery_type": "…",
                "moe_attribute_type": "BrewOrderAttributes", "app_id": "<workspace id>",
                "moe_liveactivity_source": "app", "moe_transaction_id": "ORD-1042" } }

// content-state (dynamic): your keys at the top level, plus the SDK's instance id
{ "status": "Being prepared", "etaMinutes": 8,
  "moengage": { "moe_instance_id": "…" } }
```

This is also why the widget reads `context.attributes.campaign.transactionId`: the order ID lives in the SDK's `moengage` block, not in your struct.

### Order tracking: Inform API (transactional)

1. On the dashboard, create an **Inform** alert with a **Push** channel whose message type is **Live Activity** (or **Live Activity with Push Fallback**). Put its campaign ID and name in `campaignId` / `campaignName` in `MoEngageLiveActivity.swift`.
2. The app starts the activity locally at Payment with `transactionId = order.id`. Your backend then drives its lifecycle with the **same `transaction_id`** through [`POST /alerts/send`](https://www.moengage.com/docs/api/transactional-alerts/send-transactional-alert).

**Update** (call it for each stage of the order):

```json
{
  "alert_id": "<your alert id>",
  "user_id": "<the user's unique id, as passed to identifyUser>",
  "transaction_id": "ORD-1042",
  "payloads": {
    "PUSH": {
      "live_activity_attributes": {
        "la_type": "update",
        "content_state": { "status": "Ready for pickup", "etaMinutes": 0 }
      }
    }
  }
}
```

**End** — same body with `"la_type": "end"` and the final `content_state`. Add `dismissal_date` (and optionally `stale_date`) under `personalized_attributes` to control when iOS removes it; the activity also ends by itself at `dismissal_date`.

**Start from the server** is possible as well (`"la_type": "start"`, with `attribute_info` and the first `content_state`), for orders placed outside the app. `monitorLiveActivities` at launch is what picks up such remotely started activities and reports their tokens. No extra code is needed.

> Use the **test** alert ID on the staging endpoint and the **live** one in production, matching the environment your build reports to (`IsTestEnvironment`). The Inform API also deduplicates on `transaction_id` for 5 minutes, so check its current docs for how to send several updates for one order in quick succession.

Suggested stages for Brew Bar:

| Stage | `la_type` | `content_state` |
|---|---|---|
| Order placed (started by the app) | — | `{ "status": "Order Placed", "etaMinutes": 12 }` |
| Barista started | `update` | `{ "status": "Being prepared", "etaMinutes": 8 }` |
| Ready | `update` | `{ "status": "Ready for pickup", "etaMinutes": 0 }` |
| Collected | `end` | `{ "status": "Collected", "etaMinutes": 0 }` |

### Sale broadcast: Live Activity API (broadcast)

1. Create the campaign with the [Create Push Campaigns API](https://www.moengage.com/docs/api/create-campaigns/create-campaign) using the `BROADCAST_LIVE_ACTIVITY` delivery type. The response returns the **APNs channel ID**: put it in `saleChannelId`, and the campaign ID in `saleCampaignId`.
2. Start, update and end it for the whole audience with the broadcast endpoints. All three require the `X-MOE-APPKEY: <workspace id>` header.

**Start**: [`POST /live-activity/broadcast/start`](https://www.moengage.com/docs/api/live-activities/start-broadcast-live-activity)

```json
{
  "broadcast_live_activity_id": "<campaign id>",
  "ios": {
    "attribute_type": "SaleBroadcastAttributes",
    "attribute_info": { "saleName": "Weekend Brew Sale" },
    "content_state": { "discountText": "30% off all lattes", "timeRemaining": "2h left" },
    "alert": { "title": "Weekend Brew Sale is live", "body": "30% off all lattes" }
  }
}
```

**Update**: [`POST /live-activity/broadcast/update`](https://www.moengage.com/docs/api/live-activities/update-broadcast-live-activity). Same shape without `attribute_type` / `attribute_info`:

```json
{
  "broadcast_live_activity_id": "<campaign id>",
  "ios": {
    "content_state": { "discountText": "30% off all lattes", "timeRemaining": "15m left" },
    "alert": { "title": "Last call", "body": "15 minutes left on the sale" }
  }
}
```

**End**: [`POST /live-activity/broadcast/end`](https://www.moengage.com/docs/api/live-activities/end-broadcast-live-activity), with the final `content_state`, an `alert`, and optionally `dismissal_date` (epoch seconds; a past time ends it immediately).

Devices outside the campaign's audience can still join with `startSaleBroadcast(...)`, which subscribes to the same channel and calls `trackStarted` itself. iOS limits the payload to about 5 KB.

---

## Project layout

```
SwiftSampleApp/
├── Podfile                             # CocoaPods target + Cocoa Live Activity extension
├── MoEngageiOSSampleApp.xcworkspace    # open this
├── MoEngageiOSSwiftUISampleApp/
│   ├── AppDelegate.swift               # init, messaging delegate, launch-time registration
│   ├── MoEngageiOSSwiftUISampleAppApp.swift
│   ├── Info.plist                      # MoEngage config dictionary
│   ├── MoEngageSDKIntegration/         # ← the whole integration; shared by all 3 apps
│   │   ├── MoEngageSDKHelper.swift     #   the facade / index
│   │   ├── MoEngageEvents.swift        #   event dictionary
│   │   ├── MoEngageUser.swift          #   identity + attributes
│   │   ├── MoEngagePush.swift
│   │   ├── MoEngageInApp.swift         #   contexts, delegate, self-handled
│   │   ├── InAppContextModifier.swift  #   .inAppContext(_:) for SwiftUI
│   │   ├── MoEngageInbox.swift
│   │   ├── MoEngageGeofence.swift
│   │   ├── MoEngagePersonalize.swift
│   │   ├── MoEngageLiveActivity.swift
│   │   └── MoEngageReporting.swift     #   failure logging
│   ├── Data/                           # demo catalogue, models, Live Activity attributes
│   ├── Navigation/                     # Route, Router, tabs
│   └── Screens/                        # SwiftUI screens
├── MoEngageiOSSampleApp/               # UIKit app (SPM + CocoaPods targets)
│   ├── AppDelegate.swift / SceneDelegate.swift
│   ├── Info.plist                      # MoEngage config dictionary
│   ├── Navigation/                     # RootCoordinatorController
│   ├── Screens/                        # UIKit view controllers
│   ├── MoEngageCardsTab.swift          # Cards tab: the SDK's cards screen (UIKit only)
│   └── ViewController.swift            # legacy all-in-one API demo
├── BrewOrderLiveActivity/              # widget extension (iOS 18)
├── NotificationServices/               # manual Notification Service extension (not embedded)
└── PushTemplateExtension/              # manual Notification Content extension (not embedded)
```

---

## Design decisions

- **Init from Info.plist.** The config is data, not code. You can change workspace or data centre without touching Swift, and the Extensions Integrator reads the same dictionary.
- **One facade.** The full SDK surface is visible in one file, and swapping or auditing a feature never touches a screen.
- **Contexts on every screen.** This prevents a campaign meant for one screen from showing on another.
- **Push permission is never requested at launch.** The single system alert is saved for the opt-in screen.
- **Placeholder values for missing attributes.** Every event attribute is always sent (for example `coupon` = `"none"`), so segments and filters built on it remain consistent.

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Nothing reaches the dashboard | `WorkspaceId` / `DataCenter` wrong, or you are looking at the live environment with a Debug build (it reports to the test environment) |
| No push on device | APNs key not uploaded; push capability missing; running on a simulator without a token; permission declined |
| Push arrives but no image / no impression | App group mismatch between plist, entitlements and extension; or both the integrator and a manual service extension are embedded |
| Integrator build phase fails | Manual signing without profiles for `<bundle id>.MoEngageNotificationService` / `.MoEngageNotificationContent` |
| In-app never shows | No campaign for the current context, or the screen never calls `showInApp()` |
| In-app CTA does nothing | Delegate not retained; or the link matches no `Route` before sign-in |
| Personalize returns `invalidExperienceKey` | `fetchExperiencesMeta` has not run on this device, or the key is wrong |
| Geofence never fires | Location permission not granted before `startGeofenceMonitoring()`; no fence in the dashboard |
| Live Activity never updates | Placeholder campaign IDs; `monitorLiveActivities` not called at launch; device below iOS 18 |
| `pod install` / version mismatch | Run `pod repo update`; the Podfile and SPM pin the SDK separately, so keep them aligned |

---

## Test checklist

- [ ] App launches; console shows SDK logs and `Device Token : …` on a device
- [ ] Login → user profile shows identity, reserved and taste attributes
- [ ] Order flow fires all events in the [Event dictionary](#event-dictionary)
- [ ] Opt-in screen shows the system alert once; Profile opens Settings after a decline
- [ ] Rich push shows media; template push renders; tap fires `Notification_Opened`
- [ ] In-app on Menu/Item and nudge on Orders; CTA deep link lands on the right tab
- [ ] Self-handled card renders; shown/clicked/dismissed appear in campaign stats
- [ ] Inbox lists received pushes; badge count updates; open counts one click
- [ ] Personalize tabs render one offering, several offerings, and no offering
- [ ] Logout → subsequent events attach to a new anonymous user
- [ ] iOS 18: order Live Activity starts on payment; tap opens Order status

---

## Resources

- Developer docs: [MoEngage iOS SDK integration](https://www.moengage.com/docs/developer-guide/ios-sdk/sdk-integration/basic/sdk-integration)
- Changelog: [iOS SDK release notes](https://www.moengage.com/docs/release-notes/sdks/ios)
- Support: `support@moengage.com`
