//
//  SampleDataSource.swift
//  iosSampleApp
//
//  Created by Deepa on 05/09/22.
//

import Foundation

enum SampleDataSource: String, CaseIterable {
    case registerUser = "Register User"
    case unregisterUser = "UnRegister User"
    case currentRegistrationStatus = "Current Enroll status"
    case trackEvent = "Track Event"
    case trackUserAttribute = "Track User Attribute"
    case trackNonInteractiveEvent = "Track Non-Interactive Event"
    case realTimeTrigger = "Real Time Trigger"
    case showGeneralInapp = "Show General InApp"
    case showSelfHandledInApp = "Show General self-handled InApp"
    case inboxMessage = "Inbox Messages"
    case cards = "Cards"
    case geofence = "Initiate Geofence Campaign"
    case logout = "Logout"
 
}
