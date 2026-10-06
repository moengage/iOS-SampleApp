//
//  UIControl+TapAction.swift
//  MoEngageiOSSampleApp
//
//  Closure-based tap handling that works down to this target's iOS 13.0
//  minimum. UIKit's own closure-based `UIAction`/`addAction(_:for:)` needs
//  iOS 14+, so this is a plain target-action wrapper instead: the closure is
//  kept alive for the control's lifetime via an associated object.
//

import UIKit
import ObjectiveC

private final class ControlActionTarget {
    private let handler: () -> Void
    init(_ handler: @escaping () -> Void) { self.handler = handler }
    @objc func invoke() { handler() }
}

private var associatedActionTargetsKey: UInt8 = 0

extension UIControl {

    /// Adds `handler`, called on `event` (default `.touchUpInside`).
    func addTapAction(for event: UIControl.Event = .touchUpInside, _ handler: @escaping () -> Void) {
        let target = ControlActionTarget(handler)

        var targets = (objc_getAssociatedObject(self, &associatedActionTargetsKey) as? [ControlActionTarget]) ?? []
        targets.append(target)
        objc_setAssociatedObject(self, &associatedActionTargetsKey, targets, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        addTarget(target, action: #selector(ControlActionTarget.invoke), for: event)
    }
}
