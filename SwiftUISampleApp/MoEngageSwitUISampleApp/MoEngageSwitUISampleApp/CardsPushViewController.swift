//
//  CardsPresentationViewController.swift
//  InappSwiftUI
//
//  Created by Deepa on 15/12/22.
//

import UIKit
import MoEngageCards
import MoEngageSDK

protocol CardsPushViewControllerDelegate: AnyObject {
    func cardClicked(withCardInfo card: MoEngageCardCampaign, andAction action: MoEngageCardAction, forAccountMeta accountMeta: MoEngageAccountMeta) -> Bool
    func cardDeleted(withCardInfo card: MoEngageCardCampaign, forAccountMeta accountMeta: MoEngageAccountMeta)
}

class CardsPushViewController: UIViewController, MoEngageCardsViewControllerDelegate, MoEngageCardsDelegate {
    
    weak var delegate: CardsPushViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        MoEngageSDKCards.sharedInstance.setCardsDelegate(delegate: self)
        // Either present or push cards
//        MOCards.sharedInstance.presentCardsViewController(withUIConfiguration: nil, withCardsViewControllerDelegate: self, forAppID: "DAO6UGZ73D9RTK8B5W96TPYN")
        
        MoEngageSDKCards.sharedInstance.getCardsViewController(withCardsViewControllerDelegate: self, withCompletionBlock: { cardsVC in
            cardsVC?.title = "Inbox"

            self.view.addSubview(cardsVC!.view)
            self.addChild(cardsVC!)
            cardsVC!.didMove(toParent: self)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func cardsSyncedSuccessfully(forAccountMeta accountMeta: MoEngageAccountMeta) {
        print(accountMeta)
    }
    
    func cardsViewControllerDismissed(forAccountMeta accountMeta: MoEngageAccountMeta) {
        print("Dismissed!!!")
    }
    
    func cardDeleted(withCardInfo card: MoEngageCardCampaign, forAccountMeta accountMeta: MoEngageAccountMeta){
        print("Cards Deleted!!!")
        print("Card Info \(card.cardID) \(card.category) \(card.metaData)")
    }
    
    func cardClicked(withCardInfo card: MoEngageCardCampaign, andAction action:MoEngageCardAction, forAccountMeta accountMeta: MoEngageAccountMeta) -> Bool{
        print("Cards Clicked!!!")
        print("Card Info \(card.cardID) \(card.category) \(card.metaData)")
        print("Action Info \(action.type) \(action.value) \(action.kvPairs)")
        return true
    }
}


