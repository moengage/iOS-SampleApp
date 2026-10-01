//
//  MoEngageReporting.swift
//  MoEngageiOSSwiftUISampleApp
//

import Foundation
import MoEngageSDK

enum MoEngageReporting {

    /// Records that a named SDK call did not complete, with the SDK's reason.
    static func failure(_ call: String, _ failure: MoEngageRequestFailure) {
        print("MoEngage | \(call) skipped — \(failure.reason): \(failure.message)")
    }
}
