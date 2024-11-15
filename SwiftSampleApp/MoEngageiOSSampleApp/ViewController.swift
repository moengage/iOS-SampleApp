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
        
        navigationItem.title = "MoEngage Sample App"
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 100
        MoEngageSDKInApp.sharedInstance.setInAppDelegate(self)
    }
}

// MARK: UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentRow = viewModel.dataSource[indexPath.row]
        switch currentRow {
        case .registerUser:
            registerUser()
        case .unregisterUser:
            unRegisterUser()
        case .currentRegistrationStatus:
             getCurrentRegisterStatus()
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
            MoEngageSDKAnalytics.sharedInstance.trackEvent("Product Purchased")
        case .trackNonInteractiveEvent:
            trackNonInteractiveEvents()
        case .logout:
            logout()
        
        }
    }
    
    // MARK: - TRACK EVENTS
    /// Track events to track user behavior in an app
    /// Create a dictionary of event attributes and pass that to generate an instance of MOProperties. MOProperties also allows you to add additinal attributes.
    /// It supports tracking of Int, Double, Float, String, Bool, Date, Location value types
    private func trackEvents() {
        var eventAttrDict : Dictionary<String,Any> = Dictionary()
        eventAttrDict["ProductName"] = "iPhone XS Max"
        eventAttrDict["BrandName"] = "Apple"
        eventAttrDict["Items In Stock"] = 109
        
        let eventProperties = MoEngageProperties(withAttributes: eventAttrDict)
        
        eventProperties.addAttribute(87000.00, withName: "price")
        eventProperties.addAttribute("Rupees", withName: "currency")
        eventProperties.addAttribute(true, withName: "in_stock")
        eventProperties.addAttribute([1,2, 3], withName: "sample")
        eventProperties.addDateEpochAttribute(1439322197, withName: "Time added to cart")
        eventProperties.addDateISOStringAttribute("2020-02-22T12:37:56Z", withName: "Time of checkout")
        eventProperties.addDateAttribute(Date(), withName: "Time of purchase")
        eventProperties.addLocationAttribute(MoEngageGeoLocation(withLatitude: 12.23, andLongitude: 9.23), withName: "Pickup Location")
        MoEngageSDKAnalytics.sharedInstance.trackEvent("Successfully Purchase", withProperties: eventProperties)
    }
    
    /// User attributes are specific traits of a user, like an email, username, mobile, gender, etc.
    /// Available User attributes: Unique Id, name, lastname, firstname, emailId, mobileNumber, gender, dateOfBirth, date, iso date and locaion
    private func trackUserAttributes() {
        let uniqueID = "test\(Int(Date().timeIntervalSince1970))@gmail.com"
        MoEngageSDKAnalytics.sharedInstance.setUniqueID(uniqueID)
        
        MoEngageSDKAnalytics.sharedInstance.setName("userName")
        MoEngageSDKAnalytics.sharedInstance.setLastName("userLastname")
        MoEngageSDKAnalytics.sharedInstance.setFirstName("userFirstName")
        MoEngageSDKAnalytics.sharedInstance.setEmailID("userEmailID@gmail.com")
        MoEngageSDKAnalytics.sharedInstance.setMobileNumber("8888888888")
        MoEngageSDKAnalytics.sharedInstance.setGender(.male) //Use UserGender enumerator for this
        MoEngageSDKAnalytics.sharedInstance.setDateOfBirth(Date())
        MoEngageSDKAnalytics.sharedInstance.setUserAttributeDate(Date(), withAttributeName: "Date Attr 1")
        MoEngageSDKAnalytics.sharedInstance.setUserAttributeISODate("2020-01-12T18:45:59Z", withAttributeName: "Date Attr 2")
        MoEngageSDKAnalytics.sharedInstance.setUserAttributeISODate("2020-01-12T18:45:59.333Z", withAttributeName: "Date Attr 3")
        MoEngageSDKAnalytics.sharedInstance.setLocation(MoEngageGeoLocation(withLatitude: 72.90909, andLongitude: 12.34567))
        MoEngageSDKAnalytics.sharedInstance.setLocation(MoEngageGeoLocation(withLatitude: 72.90909, andLongitude: 12.34567), withAttributeName: "loc 1")
    }
    
    private func trackNonInteractiveEvents() {
        //Set Attributes
        let dict = ["NewsCategory":"Politics"]
        let properties = MoEngageProperties(withAttributes: dict)
        properties.addDateAttribute(Date(), withName:"refreshTime")

        //Set the Event as Non-Interactive
        properties.setNonInteractive()

        //Track event
        MoEngageSDKAnalytics.sharedInstance.trackEvent("App Content Refreshed", withProperties: properties)
    }
    
    // MARK: - INBOX MESSAGES
    // To get inbox messages from MoEngage
    func getInboxMessages() {
        MoEngageSDKInbox.sharedInstance.pushInboxViewController(toNavigationController: self.navigationController!, withInboxWithControllerDelegate: self)
        
    }
    
    // MARK: - GEOFENCE
    func geofenceMonitoring(){
        MoEngageSDKGeofence.sharedInstance.startGeofenceMonitoring()
    }
    
    // MARK: - INAPPs
    
    private func showInapp() {
        MoEngageSDKInApp.sharedInstance.showInApp()
    }
    
    private func showSelfHandledInapp() {
        MoEngageSDKInApp.sharedInstance.getSelfHandledInApp { (campaignInfo, accountMeta) in
              if let campaignInfo = campaignInfo{ print("Self-Hanled InApp Content \(campaignInfo.campaignContent)")
                  // Update UI with Self Handled InApp Content
                        
              } else{
                  print("No Self Handled campaign available")
              }
        }
    }
    
    // MARK: - CARDS
    
    private func showCards() {
        MoEngageSDKCards.sharedInstance.pushCardsViewController(toNavigationController: self.navigationController!)
    }
    
    // MARK: - LOGOUT
    private func logout() {
        MoEngageSDKAnalytics.sharedInstance.resetUser()
    }
    
    private func registerUser() {
        UserRegistrationUtils().getJwtId { data in
            guard let data = data
            else {
                return
            }
            
            MoEngageSDKCore.sharedInstance.registerUser(data: data) { registrationData in
                print("Account Id - ", registrationData.accountMeta.appID)
                print("Registration result - ", registrationData.result.rawValue)
            }
        }
    }
    
    private func unRegisterUser() {
        UserRegistrationUtils().getJwtId { data in
            guard let data = data
            else {
                return
            }
            
            MoEngageSDKCore.sharedInstance.unregisterUser(data: data) { registrationData in
                print("Account Id - ", registrationData.accountMeta.appID)
                print("Registration result - ", registrationData.result.rawValue)
            }
        }

    }
    
    private func getCurrentRegisterStatus() {
        MoEngageSDKCore.sharedInstance.getUserRegistrationStatus { status in
            print("Account Id - ", status.accountMeta.appID)
            print("Is user registered - ", status.isUserRegistered)
        }
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
extension ViewController: MoEngageInboxViewControllerDelegate {
    func inboxEntryClicked(_ inboxItem: MoEngageInboxEntry) {
        print("Inbox Clicked")
    }
    
    func inboxEntryDeleted(_ inboxItem: MoEngageInboxEntry) {
        print("Inbox item deleted")
    }
    
    func inboxViewControllerDismissed() {
         print("Dismissed")
    }
}

// MARK: - MOInAppNativDelegate
extension ViewController: MoEngageInAppNativeDelegate {

    func selfHandledInAppTriggered(withInfo inappCampaign: MoEngageInApps.MoEngageInAppSelfHandledCampaign, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
            }
    
    // Called when an inApp is shown on the screen
    func inAppShown(withCampaignInfo inappCampaign: MoEngageInAppCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
       print("InApp shown callback for Campaign ID(\(inappCampaign.campaignId)) and CampaignName(\(inappCampaign.campaignName))")
       print("Account Meta AppID: \(accountMeta.appID)")
    }
    
    // Called when an inApp is dismissed by the user
    func inAppDismissed(withCampaignInfo inappCampaign: MoEngageInAppCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
        print("InApp dismissed callback for Campaign ID(\(inappCampaign.campaignId)) and CampaignName(\(inappCampaign.campaignName))")
        print("Account Meta AppID: \(accountMeta.appID)")
    }
    
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInAppCampaign, andCustomActionInfo navigationAction: MoEngageInAppAction, forAccountMeta accountMeta: MoEngageAccountMeta) {
        print("InApp Clicked with Campaign ID \(inappCampaign.campaignId)")
        print("Account Meta AppID: \(accountMeta.appID)")
    }
    
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInApps.MoEngageInAppCampaign, andNavigationActionInfo navigationAction: MoEngageInApps.MoEngageInAppNavigationAction, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
        print("InApp clicked navigation action callback for Campaign ID(\(inappCampaign.campaignId)) and CampaignName(\(inappCampaign.campaignName)) ❄️")
        print("Navigation Action value : \(navigationAction.navigationUrl) K-V pairs: \(navigationAction.keyValuePairs)")
        print("Navigation Action Type : \(navigationAction.navigationType)")
        print("Account Meta AppID: \(accountMeta.appID)")
    }
}
