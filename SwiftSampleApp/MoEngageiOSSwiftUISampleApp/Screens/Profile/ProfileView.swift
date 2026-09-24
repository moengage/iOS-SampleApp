//
//  ProfileView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Who the user is, and what they have allowed.
//
//  Most of this screen is about the MoEngage integration rather than about the
//  user: what notifications are permitted, what location is permitted, whether
//  fences are being watched, and the way into the personalized offers MoEngage
//  has picked. That is the point of the screen in a sample app — it shows the
//  integration's state rather than hiding it.
//
//  MoEngage moment: signing out invalidates the identity, so everything
//  tracked afterwards belongs to a new anonymous user. No events are reported
//  from this screen.
//

import SwiftUI
import CoreLocation

struct ProfileView: View {

    @ObservedObject var state: ProfileState

    /// Opens the personalized offers screen.
    let onPersonalize: () -> Void

    let onLogout: () -> Void

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    tasteProfile
                    personalize
                    notifications
                    location

                    Button("Log out", action: onLogout)
                        .buttonStyle(.brewSecondary)
                }
                .padding(.horizontal, BrewSize.screenPadding)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .background(BrewColor.pageBackground.ignoresSafeArea())
        .inAppContext(.profile)
        .task { await state.refresh() }
        // Both permissions can be changed in Settings while the app is away,
        // so what is displayed is re-read rather than remembered.
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            Task { await state.refresh() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            Text(DemoUser.initials)
                .brewTextStyle(.initials)
                .foregroundColor(BrewColor.onDarkPrimary)
                .frame(width: BrewSize.avatar, height: BrewSize.avatar)
                .background(BrewColor.primary)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(DemoUser.name)
                    .brewTextStyle(.titleBoldSmall)
                    .foregroundColor(BrewColor.textPrimary)

                Text(DemoUser.phone)
                    .brewTextStyle(.support)
                    .foregroundColor(BrewColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TierPill(label: DemoUser.tier)
        }
        .padding(BrewSize.screenPadding)
        .background(BrewColor.surface)
    }

    // MARK: - Taste profile

    private var tasteProfile: some View {
        let taste = DemoUser.taste
        let rows = [
            ("Favourite drink", taste.favouriteDrink),
            ("Milk", taste.milk),
            ("Sweetness", taste.sweetness),
            ("Home store", taste.homeStore),
            ("Birthday", taste.birthday),
        ]

        return CardSection("Taste profile") {
            BrewCard {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    if index > 0 {
                        ThinDivider()
                    }

                    DetailRow(label: row.0, value: row.1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }
            }
        }
    }

    // MARK: - Personalize

    /// The way into offers the app asks MoEngage for and draws itself.
    ///
    /// On the profile because it is about this user rather than about the menu:
    /// what is shown there is chosen from who they are.
    private var personalize: some View {
        CardSection("Personalize") {
            BrewCard {
                Button(action: onPersonalize) {
                    HStack(spacing: 12) {
                        IconTile(systemImage: "sparkles", size: BrewSize.iconTileSmall, symbolSize: 16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Personalized offers")
                                .brewTextStyle(.body)
                                .foregroundColor(BrewColor.textPrimary)

                            Text("Picked for you from your orders and tier")
                                .brewTextStyle(.caption)
                                .foregroundColor(BrewColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(BrewColor.textTertiary)
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Personalized offers")
                .accessibilityHint("Opens offers picked for you")
            }
        }
    }

    // MARK: - Notifications

    private var notifications: some View {
        CardSection("Notifications") {
            BrewCard {
                Button(action: onNotificationsTapped) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Order updates")
                                .brewTextStyle(.body)
                                .foregroundColor(BrewColor.textPrimary)

                            Text(pushStatusLine)
                                .brewTextStyle(.caption)
                                .foregroundColor(
                                    state.isPushBlocked
                                        ? BrewColor.unreadBadge
                                        : BrewColor.textSecondary
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Shown, not operated. No app can switch notifications
                        // on or off — only the OS can — so the switch reports
                        // the answer and the row leads to wherever that answer
                        // can still be changed.
                        Toggle("", isOn: .constant(state.isPushGranted))
                            .labelsHidden()
                            .tint(BrewColor.primary)
                            .allowsHitTesting(false)
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Order updates")
                .accessibilityValue(pushStatusLine)
                .accessibilityHint(notificationsHint)
            }
        }
    }

    /// Asks the OS where it can still be asked, and opens Settings once it
    /// cannot.
    ///
    /// iOS presents the permission alert once per install. Before that answer
    /// exists the app can still prompt; afterwards — allowed or refused — the
    /// only way to change it is Settings.
    private func onNotificationsTapped() {
        if state.hasAnsweredPush {
            MoEngageSDKHelper.openNotificationSettings()
        } else {
            MoEngageSDKHelper.requestPushPermission()
        }
    }

    private var pushStatusLine: String {
        if state.isPushBlocked { return "Blocked at OS level · tap to open settings" }
        if state.isPushGranted { return "Allowed · token registered" }
        return "Not requested yet · tap to allow"
    }

    private var notificationsHint: String {
        state.hasAnsweredPush ? "Opens notification settings" : "Asks for permission"
    }

    // MARK: - Location

    private var location: some View {
        CardSection("Location") {
            BrewCard {
                PermissionRow(
                    label: "Location access",
                    caption: locationCaption,
                    value: locationValue,
                    isGranted: state.locationStatus == .authorizedAlways,
                    action: locationAction,
                    onAction: locationActionHandler
                )

                ThinDivider()

                PermissionRow(
                    label: "Precise location",
                    caption: "A fence needs full accuracy to be reliable",
                    value: state.isPreciseLocation ? "On" : "Off",
                    isGranted: state.isPreciseLocation,
                    action: nil,
                    onAction: {}
                )

                ThinDivider()

                DetailRow(
                    label: "Geofence monitoring",
                    value: state.isMonitoringGeofences ? "Active" : "Inactive",
                    valueColor: state.isMonitoringGeofences
                        ? BrewColor.successText
                        : BrewColor.textTertiary
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }

    /// iOS asks once and answers on two axes, where Android has three separate
    /// permissions. The caption names which of ours is in play.
    private var locationCaption: String {
        switch state.locationStatus {
        case .authorizedAlways: return "Fences can fire with the app closed"
        case .authorizedWhenInUse: return "Fences fire only while the app is open"
        case .denied, .restricted: return "Changeable in Settings only"
        default: return "Needed before fences can be watched"
        }
    }

    private var locationValue: String {
        switch state.locationStatus {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "While using"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        default: return "Not requested"
        }
    }

    /// The next step available, or `nil` when there is nothing left to ask.
    private var locationAction: String? {
        switch state.locationStatus {
        case .notDetermined: return "Allow"
        case .authorizedWhenInUse: return "Allow always"
        case .denied, .restricted: return "Open settings"
        default: return nil
        }
    }

    private var locationActionHandler: () -> Void {
        switch state.locationStatus {
        case .denied, .restricted: return state.openAppSettings
        default: return state.requestLocation
        }
    }
}

// MARK: - Section

/// A titled group. Private: only this screen labels its cards this way.
private struct CardSection<Content: View>: View {

    private let title: String
    private let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .brewTextStyle(.cardTitle)
                .foregroundColor(BrewColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            content()
        }
    }
}

// MARK: - Permission row

/// One grant: what it is, what it means, where it stands, and the next step.
private struct PermissionRow: View {

    let label: String
    let caption: String
    let value: String
    let isGranted: Bool
    let action: String?
    let onAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .brewTextStyle(.body)
                    .foregroundColor(BrewColor.textPrimary)

                Text(caption)
                    .brewTextStyle(.caption)
                    .foregroundColor(BrewColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let action {
                LinkButton(action, action: onAction)
            } else {
                Text(value)
                    .brewTextStyle(.captionMedium)
                    .foregroundColor(isGranted ? BrewColor.successText : BrewColor.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Small parts

/// An inline text action inside a card.
private struct LinkButton: View {

    private let label: String
    private let action: () -> Void

    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .brewTextStyle(.captionMedium)
                .foregroundColor(BrewColor.link)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// The loyalty tier beside the user's name.
private struct TierPill: View {

    let label: String

    var body: some View {
        Text(label)
            .brewTextStyle(.microMedium)
            .foregroundColor(BrewColor.warmIcon)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(BrewColor.warmTint)
            .clipShape(Capsule(style: .continuous))
    }
}

