//
//  BrewMetrics.swift
//  MoEngageiOSSwiftUISampleApp
//
import CoreGraphics

/// Fixed heights, widths and diameters.
enum BrewSize {

    /// Standard horizontal inset applied to screen content.
    static let screenPadding: CGFloat = 20

    /// The rounded brand tile on the splash screen.
    static let brandTile: CGFloat = 52

    /// Minimum height of a primary call to action.
    static let buttonHeight: CGFloat = 52

    /// Height of a form field, and the side of a single one-time-code box.
    static let inputHeight: CGFloat = 48

    /// Height of the menu search field.
    static let searchHeight: CGFloat = 46

    /// The circular notification bell.
    static let bellButton: CGFloat = 38

    /// The unread-count circle on the bell.
    static let badge: CGFloat = 17

    /// The rounded square holding a single icon.
    static let iconTile: CGFloat = 44

    /// The smaller icon tile, on a notification row.
    static let iconTileSmall: CGFloat = 34

    /// Height of the image at the top of an item's detail screen.
    static let heroImageHeight: CGFloat = 220

    /// The circular back control floating over that image.
    static let heroBackButton: CGFloat = 34

    /// The profile avatar.
    static let avatar: CGFloat = 56

    /// The confirmation circle at the top of the order-status screen.
    static let statusCircle: CGFloat = 60

    /// The stripe marking an order as in progress.
    static let activeStripe: CGFloat = 3

    /// One segment of the order-progress bar.
    static let progressSegmentHeight: CGFloat = 5

    /// The square thumbnail on a cart line.
    static let cartThumb: CGFloat = 52

    /// The checkbox on an add-on row.
    static let checkbox: CGFloat = 20

    /// Height of a category-list row. Fixed: the rows are uniform and the
    /// image fills the row's full height.
    static let listRowHeight: CGFloat = 112

    /// Width of that row's image.
    static let listRowImageWidth: CGFloat = 100

    /// Width-to-height ratio of the image banner on a featured card.
    ///
    /// A ratio rather than a fixed height: the card's width changes with the
    /// device, the orientation and the number of grid columns, and a fixed
    /// height would letterbox the banner as the card widened — cropping more
    /// and more of the image away.
    static let featuredImageAspect: CGFloat = 170 / 104

    /// The square outlined back control.
    static let backTile: CGFloat = 36

    /// Greatest height of the banner above a full-screen message.
    ///
    /// A maximum rather than a fixed height. The banner is laid out to fit
    /// rather than to fill, so it takes this height only when the width allows
    /// it; on a short screen it shrinks and keeps its proportions instead of
    /// being cropped to a letterbox slot.
    static let bannerMaxHeight: CGFloat = 290

    /// The same banner on a screen with little vertical room — a phone held
    /// in landscape — where the full height would leave nothing for the copy.
    static let bannerMaxHeightCompact: CGFloat = 170

    /// The minimum comfortable touch target.
    static let touchTarget: CGFloat = 44
}

/// Corner radii, applied with `RoundedRectangle(cornerRadius:style: .continuous)`.
enum BrewCorner {

    /// Cards, and the splash brand tile.
    static let card: CGFloat = 14

    /// Buttons.
    static let button: CGFloat = 12

    /// Form fields, the back control and icon tiles.
    static let input: CGFloat = 10

    /// Chips and small fills.
    static let chip: CGFloat = 8

    /// The add-on checkbox.
    static let checkbox: CGFloat = 5

    /// A progress segment.
    static let track: CGFloat = 3

    /// A notification shade.
    static let notification: CGFloat = 22

    /// The icon tile inside one.
    static let iconTile: CGFloat = 9
}
