//
//  ViewController.swift
//  iosSampleApp
//
//  Created by Deepa on 05/09/22.
//

import UIKit
import MoEngageSDK
import MoEngageGeofence
import MoEngageInbox
import MoEngageCards
import MoEngageInApps

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let viewModel = SampleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Moengage Sample App"
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 100
        MOInApp.sharedInstance().setInAppDelegate(self)
    }
}

// MARK: UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentRow = viewModel.dataSource[indexPath.row]
        switch currentRow {
        case .trackEvent:
            trackEvents()
        case .trackUserAttribute:
            trackUserAttributes()
        case .inboxMessage:
            getInboxMessages()
        case .showGeneralInapp:
            showInapp()
        case .showSelfHandledInApp:
            showSelfHandledInapp()
        case .cards:
            showCards()
        case .geofence:
            geofenceMonitoring()
        case .realTimeTrigger:
            MOAnalytics.sharedInstance.trackEvent("Product Purchased")
        case .trackNonIteractiveEvent:
            trackNonInteractiveEvents()
        case .logout:
            logout()
        }
    }
    
    // MARK: - TRACK EVENTS
    /// Track events to track user behavior in an app
    /// Create a dictionary of event attributes and pass that to generate an instance of MOProperties. MOProperties also allows you to add additinal attributes.
    /// It supports tracking of Int, Double, Float, String, Bool, Date, Location value types
    private func trackEvents () {
        var eventAttrDict : Dictionary<String,Any> = Dictionary()
        eventAttrDict["ProductName"] = "iPhone XS Max"
        eventAttrDict["BrandName"] = "Apple"
        eventAttrDict["Items In Stock"] = 109

        let eventProperties = MOProperties(withAttributes: eventAttrDict)

        eventProperties.addAttribute(87000.00, withName: "price")
        eventProperties.addAttribute("Rupees", withName: "currency")
        eventProperties.addAttribute(true, withName: "in_stock")
        eventProperties.addDateEpochAttribute(1439322197, withName: "Time added to cart")
        eventProperties.addDateISOStringAttribute("2020-02-22T12:37:56Z", withName: "Time of checkout")
        eventProperties.addDateAttribute(Date(), withName: "Time of purchase")

        eventProperties.addLocationAttribute(MOGeoLocation.init(withLatitude: 12.23, andLongitude: 9.23), withName: "Pickup Location")
        MOAnalytics.sharedInstance.trackEvent("Successfully Purchase", withProperties: eventProperties)
    }
    
    /// User attributes are specific traits of a user, like an email, username, mobile, gender, etc.
    /// Available User attributes: Unique Id, name, lastname, firstname, emailId, mobileNumber, gender, dateOfBirth, date, iso date and locaion
    private func trackUserAttributes () {
        let uniqueID = "test\(Int(Date().timeIntervalSince1970))@gmail.com"
        MOAnalytics.sharedInstance.setUniqueID(uniqueID)
                
        MOAnalytics.sharedInstance.setName("userName")
        MOAnalytics.sharedInstance.setLastName("userLastname")
        MOAnalytics.sharedInstance.setFirstName("userFirstName")
        MOAnalytics.sharedInstance.setEmailID("userEmailID@gmail.com")
        MOAnalytics.sharedInstance.setMobileNumber("8888888888")
        MOAnalytics.sharedInstance.setGender(.male) //Use UserGender enumerator for this
        MOAnalytics.sharedInstance.setDateOfBirth(Date())
        MOAnalytics.sharedInstance.setUserAttributeDate(Date(), withAttributeName: "Date Attr 1")
        MOAnalytics.sharedInstance.setUserAttributeISODate("2020-01-12T18:45:59Z", withAttributeName: "Date Attr 2")
        MOAnalytics.sharedInstance.setUserAttributeISODate("2020-01-12T18:45:59.333Z", withAttributeName: "Date Attr 3")
        MOAnalytics.sharedInstance.setLocation(MOGeoLocation.init(withLatitude: 72.90909, andLongitude: 12.34567))
        MOAnalytics.sharedInstance.setLocation(MOGeoLocation.init(withLatitude: 72.90909, andLongitude: 12.34567), withAttributeName: "loc 1")
    }
    
    private func trackNonInteractiveEvents() {
        //Set Attributes
        let dict = ["NewsCategory":"Politics"]
        let properties = MOProperties(withAttributes: dict)
        properties.addDateAttribute(Date(), withName:"refreshTime")

        //Set the Event as Non-Interactive
        properties.setNonInteractive()

        //Track event
        MOAnalytics.sharedInstance.trackEvent("App Content Refreshed", withProperties: properties)
    }
    
    // MARK: - INBOX MESSAGES
    // To get inbox messages from MoEngage
    func getInboxMessages () {
        MOInbox.sharedInstance.pushInboxViewController(toNavigationController: self.navigationController!, withInboxWithControllerDelegate: self)
        
    }
    
    // MARK: - GEOFENCE
    func geofenceMonitoring(){
        MOGeofence.sharedInstance.startGeofenceMonitoring()
    }
    
    // MARK: - INAPPs
    
    private func showInapp() {
        MOInApp.sharedInstance().showCampaign()
    }
    
    private func showSelfHandledInapp() {
        MOInApp.sharedInstance().getSelfHandledInApp { (campaignInfo, accountMeta) in
              if let campaignInfo = campaignInfo{ print("Self-Hanled InApp Content \(campaignInfo.campaignContent)")
                  // Update UI with Self Handled InApp Content
                        
              } else{
                  print("No Self Handled campaign available")
              }
        }
    }
    
    // MARK: - CARDS
    
    private func showCards() {
        MOCards.sharedInstance.pushCardsViewController(toNavigationController: self.navigationController!)
    }
    
    // MARK: - LOGOUT
    private func logout() {
        MOAnalytics.sharedInstance.resetUser()
    }
}

// MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        let currentRow = viewModel.dataSource[indexPath.row]
        cell?.textLabel?.text = currentRow.rawValue
        return cell!
    }
}

// MARK: - MOInboxViewControllerDelegate
extension ViewController: MOInboxViewControllerDelegate {
    func inboxEntryClicked(_ inboxItem: MOInboxEntry) {
        print("Inbox Clicked")
    }
    
    func inboxEntryDeleted(_ inboxItem: MOInboxEntry) {
        print("Inbox item deleted")
    }
    
    func inboxViewControllerDismissed() {
         print("Dismissed")
    }
}

// MARK: - MOInAppNativDelegate
extension ViewController: MOInAppNativDelegate {
    // Called when an inApp is shown on the screen
    func inAppShown(withCampaignInfo inappCampaign: MOInAppCampaign, for accountMeta: MOAccountMeta) {
       print("InApp shown callback for Campaign ID(\(inappCampaign.campaign_id)) and CampaignName(\(inappCampaign.campaign_name))")
       print("Account Meta AppID: \(accountMeta.appID)")
    }

    // Called when an inApp is dismissed by the user
    func inAppDismissed(withCampaignInfo inappCampaign: MOInAppCampaign, for accountMeta: MOAccountMeta) {
        print("InApp dismissed callback for Campaign ID(\(inappCampaign.campaign_id)) and CampaignName(\(inappCampaign.campaign_name))")
        print("Account Meta AppID: \(accountMeta.appID)")
    }

    // Called when an inApp is clicked by the user, and it has been configured with a custom action
    func inAppClicked(withCampaignInfo inappCampaign: MOInAppCampaign, andCustomActionInfo customAction: MOInAppAction, for accountMeta: MOAccountMeta) {
         print("InApp Clicked with Campaign ID \(inappCampaign.campaign_id)")
         print("Custom Actions Key Value Pairs: \(customAction.keyValuePairs)")
    }

    // Called when an inApp is clicked by the user, and it has been configured with a navigation action
    func inAppClicked(withCampaignInfo inappCampaign: MOInAppCampaign, andNavigationActionInfo navigationAction: MOInAppAction, for accountMeta: MOAccountMeta) {
         print("InApp Clicked with Campaign ID \(inappCampaign.campaign_id)")
         print("Navigation Action Screen Name \(navigationAction.screenName) Key Value Pairs: \((navigationAction.keyValuePairs))")
    }
}
