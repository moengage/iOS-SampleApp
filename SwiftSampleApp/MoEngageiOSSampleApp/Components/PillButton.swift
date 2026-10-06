//
//  PillButton.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/{TabPill,FilterPill,
//  SelectPill}.swift.
//
//  The three pills are not interchangeable in the shared design:
//  - `.tab` switches what is listed. Selected fills with the brand colour.
//  - `.filter` narrows a list. Selected fills neutral grey.
//  - `.select` chooses an option that changes a price. Selected takes a pale
//    brand tint with a brand border.
//
//  Modelled here as one capsule button whose colours change with `kind` and
//  selection, rather than three near-identical view types.
//

import UIKit

enum PillKind {
    case tab
    case filter
    case select
}

final class PillButton: UIButton {

    let kind: PillKind
    private(set) var isPillSelected = false

    init(kind: PillKind, title: String) {
        self.kind = kind
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerCurve = .continuous
        contentEdgeInsets = UIEdgeInsets(
            top: kind == .select ? 8 : 7,
            left: kind == .select ? 14 : 12,
            bottom: kind == .select ? 8 : 7,
            right: kind == .select ? 14 : 12
        )
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitle(title, for: .normal)
        setPillSelected(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    func setPillSelected(_ selected: Bool) {
        isPillSelected = selected

        switch kind {
        case .tab:
            titleLabel?.font = BrewTextStyle.captionMedium.font
            setTitleColor(selected ? BrewColor.onDarkPrimary : BrewColor.textSecondary, for: .normal)
            backgroundColor = selected ? BrewColor.primary : BrewColor.surface
            layer.borderWidth = selected ? 0 : 1
            layer.borderColor = BrewColor.borderDefault.cgColor

        case .filter:
            titleLabel?.font = BrewTextStyle.captionMedium.font
            setTitleColor(BrewColor.textPrimary, for: .normal)
            backgroundColor = selected ? BrewColor.componentFill : BrewColor.surface
            layer.borderWidth = selected ? 0 : 1
            layer.borderColor = BrewColor.borderDefault.cgColor

        case .select:
            titleLabel?.font = (selected ? BrewTextStyle.bodyMedium : BrewTextStyle.body).font
            setTitleColor(BrewColor.textPrimary, for: .normal)
            backgroundColor = selected ? BrewColor.primarySelectedTint : BrewColor.surface
            layer.borderWidth = 1
            layer.borderColor = (selected ? BrewColor.primary : BrewColor.borderSubtle).cgColor
        }

        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}
