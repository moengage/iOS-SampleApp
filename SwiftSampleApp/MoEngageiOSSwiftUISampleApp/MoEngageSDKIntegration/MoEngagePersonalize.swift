//
//  MoEngagePersonalize.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Personalization — the "ask MoEngage what to show here" API. Reached through
//  `MoEngageSDKHelper`.
//
//  Every other channel in this app pushes content at the user: MoEngage decides
//  when a push or an in-app appears, and draws it. Personalization is the other
//  direction. The app asks a question — "what belongs in this slot, for this
//  user, right now?" — and the SDK answers with data. Nothing is drawn for us;
//  rendering is entirely the app's job, the same contract as a self-handled
//  in-app or a self-handled card.
//
//  Three dashboard concepts sit behind it:
//
//  - An **Experience** is a named slot, addressed by an *experience key*. It is
//    the only thing the app names.
//  - An **Offering** is one piece of content that could fill it.
//  - A **Decision Policy** chooses which Offering(s) a given user gets. It never
//    appears here as an object — it runs on the server and leaves only its name
//    behind, inside each offering's `offering_context`.
//
//  So there is no API to fetch offerings. `fetchExperience` returns the
//  Experience, and whatever the policy chose arrives embedded in its payload —
//  see `PersonalizeContract` for the unwrapping, which is where the real work is.
//

import Foundation
import MoEngagePersonalization

/// One experience campaign, decoupled from the SDK's own type so the screen can
/// hold one without importing `MoEngagePersonalization`.
///
/// `campaign` stays `fileprivate` for that reason: it exists only so this file
/// can hand it back to the SDK when reporting impressions and clicks.
struct PersonalizedExperience {
    let experienceKey: String

    /// The campaign's KV pairs, untouched — `PersonalizeContract` reads the
    /// offerings and copy out of them.
    let payload: [String: Any]

    fileprivate let campaign: MoEngageExperienceCampaign

    fileprivate init(campaign: MoEngageExperienceCampaign) {
        self.experienceKey = campaign.experienceKey
        self.payload = campaign.payload
        self.campaign = campaign
    }
}

enum MoEngagePersonalize {

    // MARK: - Metadata

    /// Syncs this workspace's experience-key catalogue.
    ///
    /// Required before the first fetch, and the single most common reason a
    /// correctly configured campaign appears not to work. The SDK validates a
    /// key against a *locally cached* list before it ever reaches the network,
    /// so on a device that has never synced, a live dashboard key still comes
    /// back `invalidExperienceKey`. It works on the developer's phone, which
    /// synced days ago, and fails on a fresh install.
    ///
    /// Safe to call on every screen entry: the SDK rate-limits the network call
    /// itself and returns cache inside the sync interval — `metadata.source`
    /// says which was used.
    ///
    /// The status filter narrows only what is handed back; the SDK caches the
    /// full unfiltered list regardless. `[]` asks for everything, which is what
    /// a sample app wants — a paused campaign is worth seeing rather than
    /// hiding.
    static func syncExperiencesMeta(_ completion: @escaping () -> Void) {
        MoEngageSDKPersonalize.sharedInstance.fetchExperiencesMeta(
            status: [],
            onSuccess: { metadata in
                let names = metadata.experienceCampaignMeta
                    .map { "\($0.experienceKey) [\($0.status)]" }
                    .joined(separator: ", ")
                print("MoEngage | personalize meta (\(metadata.source)): \(names)")
                completion()
            },
            onFailure: { failure in
                report("fetchExperiencesMeta", failure)
                // Reported, not propagated as fatal: a previous sync may still
                // be cached, so the fetch that follows is still worth trying.
                completion()
            }
        )
    }

    // MARK: - Fetch

    /// Fetches one experience campaign.
    ///
    /// `attributes` travel with this request only, as `custom_attribute`. They
    /// are never written to the user's profile, which is what makes them safe
    /// for transient context — the screen being viewed, the time of day — and
    /// what lets a demo steer which variation answers without altering real
    /// user data.
    ///
    /// `nil` is a normal outcome, not an error: nothing configured
    /// for the key, no eligible campaign, the user outside the segment, or the
    /// user held back in a control group all arrive this way. The screen falls
    /// back rather than treating any of them as a failure.
    static func fetchExperience(
        key: String,
        attributes: [String: String] = [:],
        _ completion: @escaping (PersonalizedExperience?) -> Void
    ) {
        MoEngageSDKPersonalize.sharedInstance.fetchExperience(
            experienceKey: key,
            attributes: attributes,
            onSuccess: { result in
                // A success can still carry failures: the backend may satisfy
                // some keys and reject others, and several rejections are
                // informational rather than faults.
                result.failures.forEach { report("fetchExperience(\(key))", $0) }
                let campaign = result.experiences.first { $0.experienceKey == key }
                completion(campaign.map(PersonalizedExperience.init(campaign:)))
            },
            onFailure: { failure in
                // Reads to the screen exactly as "nothing configured" does —
                // both end in the same fallback panel.
                report("fetchExperience(\(key))", failure)
                completion(nil)
            }
        )
    }

    // MARK: - Tracking

    /// Impression on the experience as a whole. Report once per render.
    static func experienceShown(_ experience: PersonalizedExperience) {
        MoEngageSDKPersonalize.sharedInstance.experienceShown(campaign: experience.campaign)
    }

    /// Impressions on the offerings actually rendered.
    ///
    /// Takes the whole offering dictionaries, untouched, rather than the app's
    /// own mapped shape: the SDK reads `offering_context` out of them itself,
    /// and attributes the impression to that.
    ///
    /// Nothing here is deduplicated by the SDK — calling it twice records two
    /// impressions — so the caller tracks what it has already reported.
    static func offeringsShown(_ offeringPayloads: [[String: Any]]) {
        guard !offeringPayloads.isEmpty else { return }
        MoEngageSDKPersonalize.sharedInstance.offeringsShown(offeringPayloads: offeringPayloads)
    }

    /// Click on one offering.
    ///
    /// Fires both the offering click and its parent experience's click, so
    /// `experienceClicked` must not also be called — that would count the same
    /// interaction twice.
    static func offeringClicked(
        experience: PersonalizedExperience,
        offeringPayload: [String: Any]
    ) {
        MoEngageSDKPersonalize.sharedInstance.offeringClicked(
            campaign: experience.campaign,
            offeringPayload: offeringPayload
        )
    }

    // MARK: - Reporting

    /// Records a personalization failure with the SDK's own reason.
    ///
    /// Separate from `MoEngageReporting.failure`, which takes the core SDK's
    /// `MoEngageRequestFailure`; this module has its own richer error model.
    ///
    /// Several of these codes are not faults at all — a user outside the
    /// segment, or held back in a control group, is the system working — so
    /// they are labelled rather than dressed as errors.
    private static func report(_ call: String, _ failure: MoEngageExperienceFailureReason) {
        let note: String
        switch failure.code {
        case .userInCampaignControlGroup, .userInGlobalControlGroup:
            note = "expected — user held back to measure lift"
        case .userNotInSegment:
            note = "expected — user outside this campaign's audience"
        case .invalidExperienceKey:
            note = "check the key, and that metadata has synced on this device"
        case .campaignNotActive, .campaignExpired:
            note = "campaign is not live on the dashboard"
        case .featureDisabled:
            note = "Personalization is switched off for this workspace"
        default:
            note = failure.message
        }
        print("MoEngage | \(call) — \(failure.displayCode): \(note)")
    }
}
