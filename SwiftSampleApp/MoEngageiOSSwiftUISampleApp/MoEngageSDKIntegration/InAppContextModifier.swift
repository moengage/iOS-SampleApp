//
//  InAppContextModifier.swift
//  MoEngageiOSSwiftUISampleApp
//

import SwiftUI

extension View {

    /// Sets the in-app context while this screen is on display.
    ///
    /// Applied on appearance, which covers being pushed, being returned to by a
    /// pop, and being re-selected in the tab bar.
    func inAppContext(_ context: MoEngageInAppContext) -> some View {
        onAppear {
            MoEngageSDKHelper.setInAppContext(context)
        }
    }
}
