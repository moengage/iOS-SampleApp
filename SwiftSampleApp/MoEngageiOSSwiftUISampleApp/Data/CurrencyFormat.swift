//
//  CurrencyFormat.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Price formatting.
//

import Foundation

func rupees(_ amount: Int) -> String {
    let digits = String(abs(amount))
    let sign = amount < 0 ? "-" : ""

    guard digits.count > 3 else { return "\(sign)₹\(digits)" }

    let tail = String(digits.suffix(3))
    let head = String(digits.dropLast(3))

    let groupedHead = String(
        head
            .reversed()
            .map(String.init)
            .enumerated()
            .map { index, digit in
                index > 0 && index.isMultiple(of: 2) ? "\(digit)," : digit
            }
            .joined()
            .reversed()
    )

    return "\(sign)₹\(groupedHead),\(tail)"
}

/// Formats a price difference as `+₹20`, or as nothing when there is none, so a
/// free option reads as just its name rather than "Dairy +₹0".
func surcharge(_ amount: Int) -> String {
    amount == 0 ? "" : " +₹\(amount)"
}
