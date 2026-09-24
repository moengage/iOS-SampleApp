//
//  PushOptInView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Notification opt-in: the screen that explains what notifications are for,
//  before the system permission alert appears.
//
//  MoEngage moment: the call to action registers for push, which presents the
//  system alert. The answer is not reported anywhere — the SDK reads the
//  authorization status itself. See `MoEngagePush`.
//
//  iOS presents that alert once per install, so this screen exists to make the
//  ask land: the user sees the value before the decision, not after.
//
//  The screen moves on as soon as the alert has been answered, whichever way.
//  A system alert makes the app briefly inactive, so returning to the active
//  phase is the signal that an answer now exists to read.
//

import SwiftUI

struct PushOptInView: View {

    /// Called once the permission alert has been answered, or when the user
    /// declines to be asked. The caller decides where the flow continues.
    let onContinue: () -> Void

    @Environment(\.scenePhase) private var scenePhase

    /// Distinguishes a phone held in landscape, where vertical room is scarce.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// Set when the alert has been presented, so the app only re-reads the
    /// authorization status for a decision this screen actually asked for.
    @State private var didRequest = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                banner
                message
                actions
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BrewColor.pageBackground.ignoresSafeArea())
            .inAppContext(.permission)
            .task {
                // Nothing left to ask for if the user has answered already, whether
                // on an earlier run or in Settings.
                if await MoEngageSDKHelper.hasAnsweredPushPermission() {
                    onContinue()
                }
            }
            .onChange(of: scenePhase) { phase in
                guard phase == .active, didRequest else { return }
                Task {
                    if await MoEngageSDKHelper.hasAnsweredPushPermission() {
                        onContinue()
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var banner: some View {
        // Fitted, not filled. Filling crops whatever does not match the frame's
        // shape, which on a wide, short screen is most of the image. Fitting
        // keeps all of it and lets the tint show at the sides instead.
        Image("PermissionBanner")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: bannerMaxHeight)
            .background(BrewColor.primaryLightTint)
            .accessibilityHidden(true)
    }

    /// The banner is allowed less height where there is little to spare, so the
    /// headline and the call to action stay in view.
    private var bannerMaxHeight: CGFloat {
        verticalSizeClass == .compact
            ? BrewSize.bannerMaxHeightCompact
            : BrewSize.bannerMaxHeight
    }

    private var message: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Know the moment it's ready")
                    .brewTextStyle(.screenTitleSmall)
                    .foregroundColor(BrewColor.textPrimary)

                Text("We only send what's useful: your order, the bakes you like and the stars you're about to earn.")
                    .brewTextStyle(.subtitle)
                    .foregroundColor(BrewColor.textSecondary)

                ForEach(Self.valueProps, id: \.self) { line in
                    valueProp(line)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 26)
            .padding(.bottom, 22)
        }
    }

    private func valueProp(_ line: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(BrewColor.primary)
                .accessibilityHidden(true)

            Text(line)
                .brewTextStyle(.body)
                .foregroundColor(BrewColor.textPrimary)
        }
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button("Enable notifications") {
                didRequest = true
                MoEngageSDKHelper.requestPushPermission()
            }
            .buttonStyle(.brewPrimary)

            Button("Not now", action: onContinue)
                .buttonStyle(.brewQuiet)
        }
        .padding(.horizontal, BrewSize.screenPadding)
        .padding(.bottom, 22)
    }

    private static let valueProps = [
        "A ping the moment your order hits the bar",
        "Croissants out of the oven at 8:30 am",
        "Star milestones and free-drink reminders",
    ]
}

// MARK: - Previews

#Preview("Push opt-in") {
    PushOptInView(onContinue: {})
}

#Preview("Push opt-in · accessibility XXXL") {
    PushOptInView(onContinue: {})
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
