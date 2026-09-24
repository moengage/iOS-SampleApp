//
//  BrewOrderLiveActivityLiveActivity.swift
//  BrewOrderLiveActivity
//
//  The Lock Screen banner and Dynamic Island presentation for order
//  tracking. Pure display: every value here comes from BrewOrderAttributes'
//  ContentState, refreshed by MoEngage's backend — this file never decides
//  what the order's status is, only how to draw it.
//

import ActivityKit
import WidgetKit
import SwiftUI
import MoEngageLiveActivity

struct BrewOrderLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoEngageTransactionActivityAttributes<BrewOrderAttributes>.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color(red: 0.02, green: 0.2, blue: 0.23))
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.etaMinutes) min")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.status)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                }
            } compactLeading: {
                Image(systemName: "cup.and.saucer.fill")
            } compactTrailing: {
                Text("\(context.state.etaMinutes)m")
            } minimal: {
                Image(systemName: "cup.and.saucer.fill")
            }
            .keylineTint(Color(red: 0.02, green: 0.65, blue: 0.72))
        }
    }
}

/// The Lock Screen card's content.
private struct LockScreenView: View {
    let state: MoEngageTransactionActivityAttributes<BrewOrderAttributes>.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.title2)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(state.status)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(state.etaMinutes) min away")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer()
        }
        .padding(16)
    }
}

extension BrewOrderAttributes {
    fileprivate static var preview: BrewOrderAttributes {
        BrewOrderAttributes()
    }
}

extension BrewOrderAttributes.ContentState {
    fileprivate static var placed: BrewOrderAttributes.ContentState {
        .init(status: "Order Placed", etaMinutes: 12)
    }

    fileprivate static var outForDelivery: BrewOrderAttributes.ContentState {
        .init(status: "Out for delivery", etaMinutes: 5)
    }
}

#Preview("Notification", as: .content, using: BrewOrderAttributes.preview) {
    BrewOrderLiveActivityLiveActivity()
} contentStates: {
    BrewOrderAttributes.ContentState.placed
    BrewOrderAttributes.ContentState.outForDelivery
}
