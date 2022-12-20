//
//  CardsListView.swift
//  InappSwiftUI
//
//  Created by Deepa on 15/12/22.
//

import SwiftUI
import MoEngageCards
import MoEngageSDK
struct CardsListView: View {
    @State var count: Int = 0
    @State var unclickedCount: Int = 0
    var body: some View {
        CardsListUIView { card, action, accountMeta in
            let _ = print("card clicked")
        } cardDeleted: { card, accountMeta in
            let _ = print("Card deleted \(card)")
        }
        .onAppear {
            getCardsCount()
            getUnclickedCardsCount()
        }
        
        Text("Cards count \(count)")
        Text("Cards Unclicked count \(unclickedCount)")
            .navigationBarTitle("Inbox", displayMode: .inline)
    }
    
    func getCardsCount() {
        CardsViewModel().getCardsCount { count in
            self.count = count
        }
    }
    
    func getUnclickedCardsCount() {
        CardsViewModel().getUnclickedCount { count in
            self.unclickedCount = count
        }
    }
}

struct CardsListView_Previews: PreviewProvider {
    static var previews: some View {
        CardsListView()
    }
}

struct CardsListUIView: UIViewControllerRepresentable {
    private let cardClicked: ((_ card: MoEngageCardCampaign, _ action: MoEngageCardAction, _ accountMeta: MoEngageAccountMeta) -> Void)?
    private let cardDeleted: ((_ card: MoEngageCardCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?
    
    init(cardClicked: ((_ card: MoEngageCardCampaign, _ action: MoEngageCardAction, _ accountMeta: MoEngageAccountMeta) -> Void)?, cardDeleted: ((_ card: MoEngageCardCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?) {
        self.cardClicked = cardClicked
        self.cardDeleted = cardDeleted
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(cardClicked: cardClicked, cardDeleted: cardDeleted)
    }
        
    func makeUIViewController(context: Context) -> CardsPushViewController {
        let controller = CardsPushViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CardsPushViewController, context: Context) {}
}

extension CardsListUIView {
    
    class Coordinator: NSObject, CardsPushViewControllerDelegate {
        func cardClicked(withCardInfo card: MoEngageCardCampaign, andAction action: MoEngageCardAction, forAccountMeta accountMeta: MoEngageAccountMeta) -> Bool {
            self.cardClickedCom!(card, action, accountMeta)
            return true
        }
        
        func cardDeleted(withCardInfo card: MoEngageCardCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
            cardDeletedCom!(card, accountMeta)
        }
  
        private let cardClickedCom: ((_ card: MoEngageCardCampaign, _ action: MoEngageCardAction, _ accountMeta: MoEngageAccountMeta) -> Void)?
        private let cardDeletedCom: ((_ card: MoEngageCardCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?
        
        
        init(cardClicked: ((_ card: MoEngageCardCampaign, _ action: MoEngageCardAction, _ accountMeta: MoEngageAccountMeta) -> Void)?, cardDeleted: ((_ card: MoEngageCardCampaign, _ accountMeta: MoEngageAccountMeta) -> Void)?) {
            self.cardClickedCom = cardClicked
            self.cardDeletedCom = cardDeleted
        }
    }
}
