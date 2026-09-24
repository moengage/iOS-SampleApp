//
//  RelativeTime.swift
//  MoEngageiOSSwiftUISampleApp
//
//  Timestamps as the inbox shows them.
//

import Foundation

/// Formats how long ago something happened: "just now", "12 min ago", "3 h
/// ago", and beyond a day the weekday alone — "Mon".
///
/// Written out rather than delegated to `RelativeDateTimeFormatter` so the
/// wording matches the Android sample exactly. The system formatter would say
/// "12 minutes ago" and would change with the user's locale, which would make
/// the two apps read differently side by side.
func relativeTime(since date: Date?, now: Date = Date()) -> String {
    guard let date else { return "" }

    let minutes = Int(now.timeIntervalSince(date) / 60)

    switch minutes {
    case ..<1:
        return "just now"
    case ..<60:
        return "\(minutes) min ago"
    case ..<(60 * 24):
        return "\(minutes / 60) h ago"
    default:
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
