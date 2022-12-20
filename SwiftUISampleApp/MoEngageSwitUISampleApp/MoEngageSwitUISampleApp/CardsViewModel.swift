//
//  CardsViewModel.swift
//  InappSwiftUI
//
//  Created by Deepa on 18/12/22.
//

import Foundation
import MoEngageCards

class CardsViewModel {
    
    func getCardsCount(completion: @escaping (Int) -> Void) {
        MoEngageSDKCards.sharedInstance.getNewCardsCount(forAppID: "YOUR APP ID") { count, accountMeta in
            print("Card count is \(count)")
            completion(count)
        }
    }
    
    func getUnclickedCount(completion: @escaping (Int) -> Void) {
        MoEngageSDKCards.sharedInstance.getUnclickedCardsCount(forAppID: "YOUR APP ID") { count, accountMeta in
            print("UnClicked Card count is \(count)")
            completion(count)
        }
    }
}
