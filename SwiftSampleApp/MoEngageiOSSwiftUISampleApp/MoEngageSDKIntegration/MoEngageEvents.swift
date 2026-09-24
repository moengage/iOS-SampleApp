//
//  MoEngageEvents.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The event dictionary: every event this app reports, with its attributes.
//  Reached through `MoEngageSDKHelper`.
//
//  Names and attribute keys are the contract with the MoEngage dashboard, and
//  are identical to the Android sample's — one campaign definition then matches
//  both platforms. Changing a string here silently breaks whatever targets it,
//  which is why they are declared once and never written inline.
//
//  Calls are not awaited. The SDK batches and flushes on its own schedule, so a
//  screen never waits on analytics; each call reports its own failure through
//  `MoEngageReporting`.
//

import Foundation
import MoEngageSDK

enum MoEngageEvents {

    /// Event names. These must match the campaign definitions in the dashboard.
    enum Name {
        static let menuViewed = "Menu_Viewed"
        static let categoryBrowsed = "Category_Browsed"
        static let itemViewed = "Item_Viewed"
        static let addToCart = "Add_To_Cart"
        static let cartViewed = "Cart_Viewed"
        static let checkoutStarted = "Checkout_Started"
        static let orderPlaced = "Order_Placed"
        static let orderPickedUp = "Order_Picked_Up"
        static let reorderTapped = "Reorder_Tapped"
        static let notificationOpened = "Notification_Opened"
        static let inAppCtaClicked = "InApp_Cta_Clicked"
    }

    /// Event-attribute keys.
    enum Attribute {
        static let store = "store"
        static let category = "category"
        static let item = "item"
        static let price = "price"
        static let size = "size"
        static let milk = "milk"
        static let addOns = "addons"
        static let amount = "amount"
        static let itemsCount = "items_count"
        static let fulfilment = "fulfilment"
        static let coupon = "coupon"
        static let orderID = "order_id"
        static let mode = "mode"
        static let campaignID = "campaign_id"
        static let cta = "cta"
        static let deeplink = "deeplink"
    }

    /// Reports that the user arrived at the menu.
    static func trackMenuViewed(_ category: MenuCategory) {
        let properties = MoEngageProperties()
        properties.addAttribute(Store.name, withName: Attribute.store)
        properties.addAttribute(category.label, withName: Attribute.category)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.menuViewed, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.menuViewed, $0) }
    }

    /// Reports that the user moved to a different part of the menu.
    static func trackCategoryBrowsed(_ category: MenuCategory) {
        let properties = MoEngageProperties()
        properties.addAttribute(category.label, withName: Attribute.category)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.categoryBrowsed, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.categoryBrowsed, $0) }
    }

    /// Reports that the user opened an item.
    static func trackItemViewed(_ item: MenuItem) {
        let properties = MoEngageProperties()
        properties.addAttribute(item.name, withName: Attribute.item)
        properties.addAttribute(item.price, withName: Attribute.price)
        properties.addAttribute(item.category.label, withName: Attribute.category)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.itemViewed, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.itemViewed, $0) }
    }

    /// Reports an item added to the order, with how it was configured.
    ///
    /// Add-ons are joined into one string rather than sent as a list, and an
    /// empty selection is reported as `"none"` rather than as an empty string
    /// — both matching the Android sample, so one dashboard segment written
    /// against this attribute behaves the same on either platform.
    static func trackAddToCart(item: MenuItem, selection: ItemSelection) {
        let addOns = selection.addOns.isEmpty ? "none" : selection.addOns.joined(separator: ", ")

        let properties = MoEngageProperties()
        properties.addAttribute(item.name, withName: Attribute.item)
        properties.addAttribute(selection.size, withName: Attribute.size)
        properties.addAttribute(selection.milk, withName: Attribute.milk)
        properties.addAttribute(addOns, withName: Attribute.addOns)
        properties.addAttribute(selection.amount, withName: Attribute.amount)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.addToCart, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.addToCart, $0) }
    }

    /// Reports that the user opened the order.
    ///
    /// `items_count` is the number of lines, not the total quantity — two of
    /// the same drink is one line, matching the Android sample.
    static func trackCartViewed(lines: [CartLine], amount: Int) {
        let properties = MoEngageProperties()
        properties.addAttribute(lines.count, withName: Attribute.itemsCount)
        properties.addAttribute(amount, withName: Attribute.amount)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.cartViewed, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.cartViewed, $0) }
    }

    /// Reports that the user reached payment.
    ///
    /// A bill with no coupon reports `"none"` rather than an absent attribute,
    /// matching the Android sample so one segment covers both platforms.
    static func trackCheckoutStarted(amount: Int, fulfilment: Fulfilment, coupon: String?) {
        let properties = MoEngageProperties()
        properties.addAttribute(amount, withName: Attribute.amount)
        properties.addAttribute(fulfilment.label, withName: Attribute.fulfilment)
        properties.addAttribute(coupon ?? "none", withName: Attribute.coupon)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.checkoutStarted, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.checkoutStarted, $0) }
    }

    /// Reports a placed order.
    static func trackOrderPlaced(_ order: Order) {
        let properties = MoEngageProperties()
        properties.addAttribute(order.id, withName: Attribute.orderID)
        properties.addAttribute(order.amount, withName: Attribute.amount)
        properties.addAttribute(order.mode.label, withName: Attribute.mode)
        properties.addAttribute(order.itemsCount, withName: Attribute.itemsCount)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.orderPlaced, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.orderPlaced, $0) }
    }

    /// Reports an order collected.
    ///
    /// Nothing calls this yet. On Android it fires when the simulated push
    /// preview on the status screen is tapped, and that preview — along with
    /// the order-tracking Live Activity — is not part of this build.
    static func trackOrderPickedUp(orderID: String) {
        let properties = MoEngageProperties()
        properties.addAttribute(orderID, withName: Attribute.orderID)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.orderPickedUp, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.orderPickedUp, $0) }
    }

    /// Reports a past order sent back to the cart.
    static func trackReorderTapped(item: String, orderID: String) {
        let properties = MoEngageProperties()
        properties.addAttribute(item, withName: Attribute.item)
        properties.addAttribute(orderID, withName: Attribute.orderID)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.reorderTapped, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.reorderTapped, $0) }
    }

    /// Reports that the user opened a notification.
    ///
    /// Absent values are reported as `"none"` rather than omitted, so the
    /// attribute is always present and a segment written against it behaves
    /// the same on both platforms.
    static func trackNotificationOpened(campaignID: String?, deeplink: String?) {
        let properties = MoEngageProperties()
        properties.addAttribute(campaignID ?? "none", withName: Attribute.campaignID)
        properties.addAttribute(deeplink ?? "none", withName: Attribute.deeplink)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.notificationOpened, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.notificationOpened, $0) }
    }

    /// Reports that the user acted on an in-app campaign's call to action.
    ///
    /// The app's own record of the click. Distinct from the SDK's
    /// `MOE_IN_APP_CLICKED`, which is sent automatically and is what the
    /// dashboard's click-through figures are built from — this one names the
    /// control, so a CTA can be segmented on like any other app event.
    ///
    /// - Parameters:
    ///   - campaignID: The campaign the call to action belonged to.
    ///   - cta: What was acted on — a navigation's destination, or the keys a
    ///     custom action carried.
    static func trackInAppCtaClicked(campaignID: String, cta: String) {
        let properties = MoEngageProperties()
        properties.addAttribute(campaignID, withName: Attribute.campaignID)
        properties.addAttribute(cta, withName: Attribute.cta)

        MoEngageSDKAnalytics.sharedInstance
            .trackEvent(Name.inAppCtaClicked, withProperties: properties)
            .onFailure { MoEngageReporting.failure(Name.inAppCtaClicked, $0) }
    }
}
