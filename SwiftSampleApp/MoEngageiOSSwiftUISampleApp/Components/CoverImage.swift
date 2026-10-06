//
//  CoverImage.swift
//  MoEngageiOSSwiftUISampleApp
//
//  An image that fills its container, cropping any overflow rather than
//  distorting the aspect ratio.
//
//  `scaledToFill()` does not clip on its own: it reports the scaled-up size and
//  draws beyond its bounds, over adjacent views. This view reads the space it has
//  actually been given, constrains the image to exactly that size and clips, so
//  call sites cannot omit that step.
//
//  A fixed frame derived from the measured size is used in preference to a
//  flexible one: it clamps the image itself rather than only the container, which
//  keeps the reported size stable for the surrounding layout.
//

import SwiftUI

struct CoverImage: View {

    private let name: String
    private let accessibilityLabel: String?

    /// - Parameters:
    ///   - name: Asset catalog image name.
    ///   - accessibilityLabel: VoiceOver description. Pass `nil`, the default,
    ///     for decorative imagery; the image is then hidden from VoiceOver.
    init(_ name: String, accessibilityLabel: String? = nil) {
        self.name = name
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        GeometryReader { proxy in
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel ?? "")
        .accessibilityHidden(accessibilityLabel == nil)
    }
}

