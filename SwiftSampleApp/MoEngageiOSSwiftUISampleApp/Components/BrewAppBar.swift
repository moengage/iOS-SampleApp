//
//  BrewAppBar.swift
//  MoEngageiOSSwiftUISampleApp
//
//  The app bar used by every pushed screen: a back tile, a title with an
//  optional subtitle, an optional trailing control, and a bottom rule.
//
//  Ordinary content rather than a system navigation bar. The design specifies a
//  subtitle and an exact type ramp, neither of which `.toolbar` can express, and
//  the app already hides the system bar everywhere.
//

import SwiftUI

struct BrewAppBar<Trailing: View>: View {

    private let title: String
    private let subtitle: String?
    private let onBack: (() -> Void)?
    private let trailing: () -> Trailing

    init(
        title: String,
        subtitle: String? = nil,
        onBack: (() -> Void)? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onBack = onBack
        self.trailing = trailing
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let onBack {
                    BackTile(action: onBack)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .brewTextStyle(.cardTitle)
                        .foregroundColor(BrewColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    if let subtitle {
                        Text(subtitle)
                            .brewTextStyle(.caption)
                            .foregroundColor(BrewColor.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                trailing()
            }
            .padding(.horizontal, BrewSize.screenPadding)
            .padding(.vertical, 14)

            ThinDivider()
        }
        .background(BrewColor.surface)
    }
}

extension BrewAppBar where Trailing == EmptyView {

    /// An app bar with no trailing control.
    init(title: String, subtitle: String? = nil, onBack: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, onBack: onBack) { EmptyView() }
    }
}

extension View {

    /// Styles a button as an inline text action, for an app bar's trailing
    /// slot.
    func brewInlineLink() -> some View {
        buttonStyle(.plain)
            .brewTextStyle(.captionMedium)
            .foregroundColor(BrewColor.link)
    }
}

#Preview {
    BrewAppBar(
        title: "Coffee · hot & cold",
        subtitle: Store.pickupLine,
        onBack: {}
    )
}
