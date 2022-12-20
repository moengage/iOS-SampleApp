//
//  InappViewController.swift
//  InappSwiftUI
//
//  Created by Deepa on 14/12/22.
//

import UIKit
import MoEngageInApps

protocol InappControllerDelegate: AnyObject {
    func shown(withCampaignInfo inappCampaign: MoEngageInAppCampaign, for accountMeta: MoEngageAccountMeta)
    func clicked(withCampaignInfo inappCampaign: MoEngageInAppCampaign, andCustomActionInfo customAction: MoEngageInAppAction, for accountMeta: MoEngageAccountMeta)
    func dismissed(withCampaignInfo inappCampaign: MoEngageInAppCampaign, for accountMeta: MoEngageAccountMeta)
}

class InappViewController: UIViewController, MoEngageInAppNativeDelegate {
    func selfHandledInAppTriggered(withInfo inappCampaign: MoEngageInApps.MoEngageInAppSelfHandledCampaign, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
        
    }
    
    weak var delegate: InappControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MoEngageSDKInApp.sharedInstance.showInApp()
        MoEngageSDKInApp.sharedInstance.showNudge(atPosition: NudgePositionTop)
        MoEngageSDKInApp.sharedInstance.setInAppDelegate(self)
    }
    
    func showNudge() {
        
        MoEngageSDKInApp.sharedInstance.getNudgeView { nudgeView, campaignInfo, accountInfo in
                  if let nudgeView = nudgeView {
                      // Campaign Info
                      // Set Frame
                      var frame = nudgeView.frame
                      frame.origin.y = (UIScreen.main.bounds.size.height - frame.height)/2.0
                      frame.origin.x = 0.0
                      nudgeView.frame = frame
                      
                      // Attach the nudge view
                      self.view.addSubview(nudgeView)
                      
                      // Track Impression
                      MoEngageSDKInApp.sharedInstance.nudgeCampaignShown(campaignInfo!);
                  }
         }
    }
    
    
    func inAppShown(withCampaignInfo inappCampaign: MoEngageInAppCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
        print("Inappshown")
        delegate?.shown(withCampaignInfo: inappCampaign, for: accountMeta)
    }
    
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInApps.MoEngageInAppCampaign, andNavigationActionInfo navigationAction: MoEngageInApps.MoEngageInAppAction, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
        print("Inappclicked")
        delegate?.clicked(withCampaignInfo: inappCampaign, andCustomActionInfo: navigationAction, for: accountMeta)
    }
    
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInApps.MoEngageInAppCampaign, andCustomActionInfo customAction: MoEngageInApps.MoEngageInAppAction, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
        print("Inappclicked")
    }
    
    func inAppDismissed(withCampaignInfo inappCampaign: MoEngageInAppCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
        delegate?.dismissed(withCampaignInfo: inappCampaign, for: accountMeta)
    }
}


