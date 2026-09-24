//
//  PersonalizeContract.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Every dashboard linkage the Personalize screen depends on, in one file, and
//  the parsing that turns a campaign payload into something the screen can draw.
//
//  Nothing here is enforced by the SDK. A personalization payload is
//  author-defined JSON — the SDK hands back exactly what the dashboard put
//  there and never looks inside — so the names below are an agreement between
//  this app and whoever authors the campaign, not a schema. That is why they
//  live together, documented, rather than scattered through the screen: a
//  mismatch does not fail loudly, it returns nothing.
//
//  Two kinds of string appear here, and they fail very differently:
//
//  - An **experience key** that does not match fails *loudly* — the SDK reports
//    `invalidExperienceKey` and the reason is in the log.
//  - A **KV pair name** that does not match fails *silently* — the unwrap below
//    finds nothing and returns an empty list, which is indistinguishable from a
//    campaign that genuinely carries no offerings. `offers(from:)` logs the
//    names it did find, so the mistake is visible rather than mysterious.
//

import Foundation
import MoEngagePersonalization

// MARK: - Dashboard contract

enum PersonalizeContract {

    // MARK: Experience keys

    /// Loyalty offer program — a single offering.
    ///
    /// The Decision Policy behind this key carries one Offering per loyalty
    /// tier, each aimed at the segment eligible for it, with the output count
    /// set to 1 — so it always resolves to the one tier this user qualifies
    /// for, never several at once.
    static let loyaltyKey = "brewbar_home_offer_with"

    /// Coupons and offers — several offerings at once.
    ///
    /// The same call and the same parsing as `loyaltyKey`; only the policy's
    /// output count differs. That is the point of demonstrating both: a
    /// marketer changing that one number changes this screen's layout, with no
    /// app release.
    static let couponsKey = "brewbar_multi_offer"

    /// Rewards — deliberately no offering at all.
    ///
    /// No Offering, no Decision Policy: just a dashboard-authored spend nudge.
    /// A real and useful shape, not a broken campaign, and the reason the
    /// screen must treat an empty offerings list as an answer rather than a
    /// failure.
    static let rewardsKey = "brewbar_home_rewards"

    // MARK: Content payload KV pairs

    /// The KV pair carrying the experience's offerings.
    ///
    /// Named on the dashboard by whoever authored the campaign, and matching
    /// the Android sample so both apps can run against the same workspace.
    static let offersPair = "offer_payload"

    /// The two KV pairs carrying the copy for the no-offerings panel, so its
    /// wording is campaign-driven rather than hardcoded — a campaign with
    /// nothing to offer can still say why.
    static let titlePair = "title"
    static let messagePair = "message"

    // MARK: Offering content fields

    /// The fields this app expects inside `offering_content.payload`.
    ///
    /// Invented here, not by MoEngage — the dashboard would store `headline`
    /// just as happily. Only `title` is required; everything else degrades, so
    /// a half-authored offering still renders rather than vanishing.
    enum Field {
        static let offeringKey = "offering_key"
        static let title = "title"
        static let subtitle = "subtitle"
        static let imageURL = "image_url"
        static let ctaLabel = "cta_label"
        static let deeplink = "deeplink"
    }
}

// MARK: - Screen model

/// One offer as the screen draws it, paired with the payload the SDK needs back.
struct PersonalizedOffer: Identifiable {

    /// Identifies the offering for impression deduplication. Prefers the
    /// authored key, falling back to MoEngage's own offering id.
    let id: String

    let title: String
    let subtitle: String
    let imageURL: URL?
    let ctaLabel: String
    let deeplink: URL?

    /// The offering dictionary exactly as it arrived.
    ///
    /// Kept whole rather than rebuilt from the fields above: the SDK attributes
    /// an impression or click to the `offering_context` it reads out of this,
    /// so anything reconstructed would track nothing. It is the one piece of
    /// this struct that must not be tidied away.
    let rawPayload: [String: Any]
}

/// The campaign's own copy for the no-offerings panel.
///
/// Either field is `nil` when the campaign does not carry it, which leaves the
/// screen's own wording in place for that half rather than rendering a blank
/// line.
struct ExperienceCopy {
    let title: String?
    let message: String?

    static let none = ExperienceCopy(title: nil, message: nil)
}

// MARK: - Parsing

extension MoEngageExperienceCampaign {

    /// The campaign's authored copy, read from its top-level KV pairs.
    var copy: ExperienceCopy {
        ExperienceCopy(
            title: stringValue(forPair: PersonalizeContract.titlePair),
            message: stringValue(forPair: PersonalizeContract.messagePair)
        )
    }

    /// The offerings this campaign carries, mapped onto the screen's shape.
    ///
    /// Three unwrappings, and the shape at each step is the server's, not a
    /// choice this app makes:
    ///
    /// 1. `payload[pair]` is an **envelope** — `{ "value": …, "data_type": … }`
    ///    — not the value itself. Every KV pair arrives wrapped this way.
    /// 2. `value` is a **String containing JSON**, so it is parsed a second
    ///    time.
    /// 3. It decodes to a **bare array**, not an object with an `offerings`
    ///    key — the shape the iOS SDK's own fixtures carry. The Android sample
    ///    reads `{"offerings": [...]}` instead; this app follows iOS.
    ///
    /// A missing pair, a blank value, malformed JSON, or an empty array all
    /// return an empty list rather than throwing. Every one of those is a
    /// campaign that has nothing to show, which is the screen's fallback and
    /// not an error.
    var offers: [PersonalizedOffer] {
        guard let envelope = payload[PersonalizeContract.offersPair] as? [String: Any] else {
            // Worth saying out loud. A KV pair named differently on the
            // dashboard produces an empty screen and no error anywhere, so the
            // names that *are* present are the fastest way to the answer.
            if !payload.isEmpty {
                print("""
                MoEngage | personalize: no KV pair named '\(PersonalizeContract.offersPair)' \
                on '\(experienceKey)'. Present: \(Array(payload.keys))
                """)
            }
            return []
        }

        guard let raw = (envelope["value"] as? String)?.trimmed, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let offerings = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]]
        else {
            return []
        }

        return offerings.enumerated().compactMap { index, offering in
            offer(from: offering, at: index)
        }
    }

    // MARK: Private

    /// Maps one offering. Returns `nil` when it carries no title — there is
    /// nothing to draw — rather than rendering an empty card.
    private func offer(from offering: [String: Any], at index: Int) -> PersonalizedOffer? {
        let content = (offering["offering_content"] as? [String: Any])?["payload"] as? [String: Any]
        guard let title = (content?[PersonalizeContract.Field.title] as? String)?.trimmed,
              !title.isEmpty
        else {
            return nil
        }

        let context = offering["offering_context"] as? [String: Any]

        let id = (content?[PersonalizeContract.Field.offeringKey] as? String)?.nonEmpty
            ?? (context?["moe_offering_id"] as? String)?.nonEmpty
            ?? "\(experienceKey)_offer_\(index)"

        return PersonalizedOffer(
            id: id,
            title: title,
            subtitle: (content?[PersonalizeContract.Field.subtitle] as? String) ?? "",
            imageURL: (content?[PersonalizeContract.Field.imageURL] as? String)?.nonEmpty
                .flatMap(URL.init(string:)),
            ctaLabel: (content?[PersonalizeContract.Field.ctaLabel] as? String)?.nonEmpty ?? "View",
            deeplink: (content?[PersonalizeContract.Field.deeplink] as? String)?.nonEmpty
                .flatMap(URL.init(string:)),
            // Passed through untouched — see `PersonalizedOffer.rawPayload`.
            rawPayload: offering
        )
    }

    /// Reads a plain String KV pair, unwrapping the same `{ value, data_type }`
    /// envelope the offerings arrive in.
    private func stringValue(forPair pair: String) -> String? {
        guard let envelope = payload[pair] as? [String: Any] else { return nil }
        return (envelope["value"] as? String)?.nonEmpty
    }
}

// MARK: - String helpers

private extension String {

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The string, or `nil` when it is blank — so an authored-but-empty field
    /// falls back the same way an absent one does.
    var nonEmpty: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}
