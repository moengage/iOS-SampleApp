//
//  PersonalizeState.swift
//  MoEngageiOSSwiftUISampleApp
//
//  What the Personalize screen is showing, and the only place it reaches the
//  SDK — through `MoEngageSDKHelper`, like every other screen.
//
//  The three tabs are three business stories, each backed by its own campaign,
//  so switching tabs re-fetches a different experience key rather than
//  switching between canned local data. Every tab therefore exercises the real
//  round trip, which is the point of demonstrating it at all.
//

import Foundation

// MARK: - Demo state

/// The three shapes a personalization answer can take, as three business
/// scenarios rather than three response formats.
enum OfferDemoState: String, CaseIterable, Identifiable {

    /// A single offering: the one loyalty tier this user qualifies for.
    case loyalty

    /// Several offerings at once: a coupon list.
    case coupons

    /// No offering at all — no Offering and no Decision Policy behind it, just
    /// an authored spend nudge.
    case rewards

    var id: String { rawValue }

    var label: String {
        switch self {
        case .loyalty: return "Loyalty offer program"
        case .coupons: return "Coupons/offers"
        case .rewards: return "Rewards"
        }
    }

    var experienceKey: String {
        switch self {
        case .loyalty: return PersonalizeContract.loyaltyKey
        case .coupons: return PersonalizeContract.couponsKey
        case .rewards: return PersonalizeContract.rewardsKey
        }
    }
}

// MARK: - State

@MainActor
final class PersonalizeState: ObservableObject {

    /// The tab on screen.
    @Published private(set) var demoState: OfferDemoState = .loyalty

    /// The offers to draw. Empty is a valid answer, not an error.
    @Published private(set) var offers: [PersonalizedOffer] = []

    /// The campaign's own wording for the no-offers panel.
    @Published private(set) var fallbackCopy: ExperienceCopy = .none

    @Published private(set) var isLoading = true

    /// Whether an answer has arrived yet.
    ///
    /// Distinct from `isLoading`: before the first answer an empty list means
    /// "not known", and showing the no-offers panel then would claim something
    /// the screen has not yet been told.
    @Published private(set) var hasFetched = false

    /// The campaign behind what is on screen. Held because every tracking call
    /// needs it, and because a click attributes to it as well as to the
    /// offering.
    private var experience: PersonalizedExperience?

    /// Offering ids already reported shown for the tab on screen. The SDK does
    /// not deduplicate impressions, so this does.
    private var reportedShown: Set<String> = []

    // MARK: - Screen lifecycle

    func onAppear() {
        fetch(demoState)
    }

    func select(_ state: OfferDemoState) {
        guard state != demoState else { return }
        // Scoped to the tab: returning to a tab is a fresh render and should
        // record a fresh impression.
        reportedShown.removeAll()
        fetch(state)
    }

    // MARK: - Fetching

    private func fetch(_ state: OfferDemoState) {
        demoState = state
        isLoading = true

        // Sync first, always. The SDK checks a key against a locally cached
        // catalogue before it ever reaches the network, so a live key still
        // fails on a device that has never synced. Cheap to repeat — inside
        // the sync interval the SDK answers from cache without a request.
        MoEngageSDKHelper.syncPersonalizeExperiences { [weak self] in
            self?.fetchExperience(state)
        }
    }

    private func fetchExperience(_ state: OfferDemoState) {
        let key = state.experienceKey

        MoEngageSDKHelper.fetchPersonalizeExperience(
            key: key,
            attributes: ["screen": "personalize", "demo_state": state.rawValue]
        ) { [weak self] experience in
            guard let self else { return }
            // A tab switched while the request was in flight: this answer is
            // for a screen the user has already left.
            guard state == self.demoState else { return }

            self.apply(experience)
        }
    }

    private func apply(_ experience: PersonalizedExperience?) {
        self.experience = experience
        offers = experience?.offers ?? []
        fallbackCopy = experience?.copy ?? .none
        isLoading = false
        hasFetched = true

        guard let experience else { return }

        // Impressions belong after the answer is committed to state — they
        // report what is about to be drawn, and nothing is drawn without it.
        MoEngageSDKHelper.trackExperienceShown(experience)

        let unreported = offers.filter { reportedShown.insert($0.id).inserted }
        MoEngageSDKHelper.trackOfferingsShown(unreported.map(\.rawPayload))
    }

    // MARK: - Interaction

    /// Reports the click and returns the link to follow, if the offer carries
    /// one.
    ///
    /// The SDK's offering click fires the parent experience's click too, so
    /// nothing else is reported here — doing both would count one tap twice.
    func offerTapped(_ offer: PersonalizedOffer) -> URL? {
        guard let experience else { return offer.deeplink }
        MoEngageSDKHelper.trackOfferingClicked(experience: experience, offeringPayload: offer.rawPayload)
        return offer.deeplink
    }
}
