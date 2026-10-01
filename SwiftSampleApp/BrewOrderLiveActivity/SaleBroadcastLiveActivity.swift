//
//  SaleBroadcastLiveActivity.swift
//  BrewOrderLiveActivity
//
//  The Lock Screen banner and Dynamic Island presentation for a broadcast
//  sale — the same card shown to every subscribed user at once. Display
//  only: values come from SaleBroadcastAttributes' ContentState.
//
//  The attributes type here is MoEngageActivityAttributes<T>, not
//  MoEngageTransactionActivityAttributes<T>. The two wrap the app's struct
//  with different campaign data, and the widget's type must match the type
//  the activity was started with.
//

import ActivityKit
import WidgetKit
import SwiftUI
import MoEngageLiveActivity

struct SaleBroadcastLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoEngageActivityAttributes<SaleBroadcastAttributes>.self) { context in
            SaleLockScreenView(
                saleName: context.attributes.appAttributes.saleName,
                state: context.state
            )
            .activityBackgroundTint(Color(red: 0.6, green: 0.05, blue: 0.15))
            .activitySystemActionForegroundColor(.white)
            .moengageWidgetClickURL(URL(string: "brewbar://sale"), context: context, widgetId: 1)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "tag.fill")
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.timeRemaining)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.discountText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                }
            } compactLeading: {
                Image(systemName: "tag.fill")
            } compactTrailing: {
                Text(context.state.timeRemaining)
            } minimal: {
                Image(systemName: "tag.fill")
            }
            .keylineTint(Color(red: 0.8, green: 0.1, blue: 0.25))
            .moengageWidgetClickURL(URL(string: "brewbar://sale"), context: context, widgetId: 1)
        }
    }
}

/// The Lock Screen card's content.
private struct SaleLockScreenView: View {
    let saleName: String
    let state: MoEngageActivityAttributes<SaleBroadcastAttributes>.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.title2)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(saleName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(state.discountText) — \(state.timeRemaining)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer()
        }
        .padding(16)
    }
}

extension SaleBroadcastAttributes {
    fileprivate static var preview: SaleBroadcastAttributes {
        SaleBroadcastAttributes(saleName: "Big Brew Sale")
    }
}

extension SaleBroadcastAttributes.ContentState {
    fileprivate static var justStarted: SaleBroadcastAttributes.ContentState {
        .init(discountText: "40% off", timeRemaining: "4h left")
    }

    fileprivate static var endingSoon: SaleBroadcastAttributes.ContentState {
        .init(discountText: "40% off", timeRemaining: "15m left")
    }
}

#Preview("Notification", as: .content, using: SaleBroadcastAttributes.preview) {
    SaleBroadcastLiveActivity()
} contentStates: {
    SaleBroadcastAttributes.ContentState.justStarted
    SaleBroadcastAttributes.ContentState.endingSoon
}
