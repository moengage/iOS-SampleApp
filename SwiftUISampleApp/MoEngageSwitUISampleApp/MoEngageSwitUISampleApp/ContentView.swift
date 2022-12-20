//
//  ContentView.swift
//  MoEngageSwitUISampleApp
//
//  Created by Deepa on 20/12/22.
//

import SwiftUI

import MoEngageSDK
import MoEngageCards
import MoEngageInApps

struct ContentView : View {
    @State private var showInappView = false
    @State private var presentCardView = false
    @State private var pushCardView = false
    
    var body: some View {
        NavigationView {
        VStack {
            Button("Show Inapp") {
                showInappView.toggle()
            }
            Divider().frame(width: 100, height: 10, alignment: .center)
            Button("Show Nudge View") {
                MoEngageSDKInApp.sharedInstance.showNudge(atPosition: NudgePositionTop)
            }
            Divider().frame(width: 100, height: 10, alignment: .center)
            Button("Present Cards Viewcontroller") {
                // For a simple cards viewcontroller presentation without any action
                MoEngageSDKCards.sharedInstance.presentCardsViewController()
            }
            Divider().frame(width: 100, height: 10, alignment: .center)
        
            NavigationLink(destination: CardsListView()) {
                Text("Push To Cards Viewcontroller")
            }
           
            if showInappView {
                InappControllerView { inappCamp, accountMeta  in
                    print("Is shown")
                } clickedCom: { inappCamp, customAction, accountMeta in
                    print("isClicked")
                } dismissedCom: { inappCampaign, accountMeta in
                    print("isDismissed")
                    showInappView.toggle()
                }
                .frame(width: .zero, height: .zero, alignment: .center)
                .hidden()
            }
        }
        }
        .onAppear {
            // If show some inapp popup without any action
            MoEngageSDKInApp.sharedInstance.showInApp()

            // If show inapp nudge without any action
            MoEngageSDKInApp.sharedInstance.showNudge(atPosition: NudgePositionTop)
            
            // Get info for self handled inapp
            MoEngageSDKInApp.sharedInstance.getSelfHandledInApp { (campaignInfo, accountMeta) in
                  if let campaignInfo = campaignInfo{ print("Self-Hanled InApp Content \(campaignInfo.campaignContent)")
                      // Update UI with Self Handled InApp Content
                            
                  } else{
                      print("No Self Handled campaign available")
                            
                  }
            }
        }
    }
}


struct InappControllerView: UIViewControllerRepresentable {
    private let shownCom: ((_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?
    private let clickedCom: ((_ inappCampaign: MoEngageInAppCampaign, _ customAction: MoEngageInAppAction, _ accountMeta: MoEngageAccountMeta) -> Void)?
    private let dismissedCom: ((_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?
 
    
    init(shownCom: ((_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?,
         clickedCom: ((_ inappCampaign: MoEngageInAppCampaign, _ customAction: MoEngageInAppAction, _ accountMeta: MoEngageAccountMeta) -> Void)?,
         dismissedCom: ((_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?) {
        self.dismissedCom = dismissedCom
        self.clickedCom = clickedCom
        self.shownCom = shownCom
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(shown: shownCom!, clicked: clickedCom!, dismissed: dismissedCom!)
    }
        
    func makeUIViewController(context: Context) -> InappViewController {
        let controller = InappViewController(nibName: "InappViewController", bundle: nil)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: InappViewController, context: Context) {}
}

extension InappControllerView {
    
    class Coordinator: NSObject, InappControllerDelegate {
       
  
        private let shownCom: (_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void
        private let clickedCom: (_ inappCampaign: MoEngageInAppCampaign, _ customAction: MoEngageInAppAction, _ accountMeta: MoEngageAccountMeta) -> Void
        private let dismissedCom: (_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void
     
        func shown(withCampaignInfo inappCampaign: MoEngageInAppCampaign, for accountMeta: MoEngageAccountMeta) {
            shownCom(inappCampaign, accountMeta)
        }
        
        func clicked(withCampaignInfo inappCampaign: MoEngageInAppCampaign, andCustomActionInfo customAction: MoEngageInAppAction, for accountMeta: MoEngageAccountMeta) {
            clickedCom(inappCampaign, customAction, accountMeta)
        }
        
        func dismissed(withCampaignInfo inappCampaign: MoEngageInAppCampaign, for accountMeta: MoEngageAccountMeta) {
            dismissedCom(inappCampaign, accountMeta)
        }
        
        init(shown: @escaping (_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void, clicked: @escaping (_ inappCampaign: MoEngageInAppCampaign, _ customAction: MoEngageInAppAction, _ accountMeta: MoEngageAccountMeta) -> Void,
             dismissed: @escaping (_ inappCampaign: MoEngageInAppCampaign, _ accountMeta: MoEngageAccountMeta) -> Void) {
            self.shownCom = shown
            self.clickedCom = clicked
            self.dismissedCom = dismissed
        }
    }
}
