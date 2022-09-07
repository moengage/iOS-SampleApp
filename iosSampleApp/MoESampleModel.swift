//
//  MoESampleModel.swift
//  MoESwiftSample
//
//  Created by Deepa on 05/09/22.
//

import Foundation

enum SDKData: String, CaseIterable {
    case trackEvent = "Track Event"
    case trackUserAttribute = "Track User Attribute"
    case trackNonIteractiveEvent = "Track Non-Interactive Event"
    case realTimeTrigger = "Real Time Trigger"
    case showGeneralInapp = "Show General InApp"
    case showSelfHandledInApp = "Show General self-handled InApp"
    case inboxMessage = "Inbox Messages"
    case cards = "Cards"
    case geofence = "Initiate Geofences Campaign"
    case logout = "Logout"
}
