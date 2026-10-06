//
//  LoginView.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Sign-in screen: mobile number and one-time code.
//
//  MoEngage moment: confirming sign-in establishes the user's identity through
//  `identifyUser`, sets their reserved profile attributes, and mirrors their
//  taste profile as custom attributes. See `MoEngageUser`.
//
//  The sample has no authentication backend, so the number and the code are
//  fixed values from `DemoUser` presented as read-only fields. There is no text
//  entry, and therefore no validation or error state on this screen. Both the
//  primary and the secondary action confirm sign-in identically.
//

import SwiftUI

struct LoginView: View {

    /// Returns to the previous screen.
    let onBack: () -> Void

    /// Sign-in confirmed. The caller reports identity and decides where to go.
    let onVerified: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                BackTile(action: onBack)

                heading
                fields

                Button("Verify & continue", action: onVerified)
                    .buttonStyle(.brewPrimary)

                separator

                Button("Continue with Google", action: onVerified)
                    .buttonStyle(.brewSecondary)

                Text("Signing in links this device to your Brew Bar identity so orders, stars and notifications follow you.")
                    .brewTextStyle(.micro)
                    .foregroundColor(BrewColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, BrewSize.screenPadding)
            .padding(.vertical, 24)
        }
        .background(BrewColor.surface.ignoresSafeArea())
        .inAppContext(.login)
    }

    // MARK: - Sections

    private var heading: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sign in for stars")
                .brewTextStyle(.screenTitle)
                .foregroundColor(BrewColor.textPrimary)

            Text("Every ₹100 earns a star. Ten stars, one free drink.")
                .brewTextStyle(.body)
                .foregroundColor(BrewColor.textSecondary)
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 14) {
            FieldGroup(label: "Mobile number") {
                ReadOnlyField(value: DemoUser.phone)
            }
            FieldGroup(label: "OTP") {
                OneTimeCodeRow(code: DemoUser.oneTimeCode)
            }
        }
    }

    /// Rule, label, rule — the two rules share the width left over by the label.
    private var separator: some View {
        HStack(spacing: 0) {
            ThinDivider(color: BrewColor.borderDefault)
            Text("or")
                .brewTextStyle(.caption)
                .foregroundColor(BrewColor.textTertiary)
                .padding(.horizontal, 12)
            ThinDivider(color: BrewColor.borderDefault)
        }
    }
}

// MARK: - Screen-private components

/// A label above its field.
private struct FieldGroup<Content: View>: View {

    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .brewTextStyle(.captionMedium)
                .foregroundColor(BrewColor.textSecondary)
            content
        }
    }
}

/// A field-shaped container presenting a fixed value. Not editable.
private struct ReadOnlyField: View {

    let value: String

    var body: some View {
        Text(value)
            .brewTextStyle(.body)
            .foregroundColor(BrewColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: BrewSize.inputHeight)
            .padding(.horizontal, 14)
            .overlay(
                RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
                    .stroke(BrewColor.borderDefault, lineWidth: 1)
            )
    }
}

/// The one-time code, one boxed digit each.
private struct OneTimeCodeRow: View {

    let code: String

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(code.prefix(4).enumerated()), id: \.offset) { _, digit in
                Text(String(digit))
                    .brewTextStyle(.otpDigit)
                    .foregroundColor(BrewColor.textPrimary)
                    .frame(width: BrewSize.otpBoxWidth, height: BrewSize.inputHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: BrewCorner.input, style: .continuous)
                            .stroke(BrewColor.borderDefault, lineWidth: 1)
                    )
            }
        }
        // Read as one value rather than four unrelated digits.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("One-time code")
        .accessibilityValue(code.prefix(4).map(String.init).joined(separator: " "))
    }
}
