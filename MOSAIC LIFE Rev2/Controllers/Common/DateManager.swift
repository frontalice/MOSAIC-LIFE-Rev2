//
//  DateManager.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/25.
//

import Foundation

class DateManager {
    public static let shared: DateManager = DateManager()
    let userDefaults = UDDataStore()
    private var now : Date = Date()
    private var japanCurrentTime : Date
    private var format : DateFormatter
    private let calendar = Calendar(identifier: .gregorian)
    private lazy var dateBorder: Date = userDefaults.fetchObject(key: .dateBorder) as! Date
    
    private init() {
        japanCurrentTime = Date(timeIntervalSinceNow: 60*60*9)
        format = DateFormatter()
        format.locale = Locale(identifier: "ja_JP")
        format.timeZone = TimeZone(identifier:  "Asia/Tokyo")
    }
    
    public func fetchCurrentTime(type: TimeType) -> String {
        now = Date()
        switch type {
        case .normal:
            return format.string(from: japanCurrentTime)
        case .year:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "y", options: 0, locale: Locale(identifier: "ja_JP"))
            return dateFormatter.string(from: now)
        case .yearAndMonthAndDay:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
            return dateFormatter.string(from: now)
        case .month:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM", options: 0, locale: Locale(identifier: "ja_JP"))
            return dateFormatter.string(from: now)
        case .day:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd", options: 0, locale: Locale(identifier: "ja_JP"))
            return dateFormatter.string(from: now)
        case .hour:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H"
            return dateFormatter.string(from: now)
        case .hourAndMinute:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HHmm", options: 0, locale: Locale(identifier: "ja_JP"))
            return dateFormatter.string(from: now)
        }
    }
    
    public func reloadDateBorder() -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: japanCurrentTime)!
        let border = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: tomorrow)!
        userDefaults.set(.dateBorder, border)
        print("DateManager: 日付変更線を\(border)で設定")
        return border
    }
    
    public func judgeIsDayChanged() -> Bool {
        print("judge/現在時刻:\(now)")
        print("judge/更新時間:\(dateBorder)")
        if now > dateBorder {
            dateBorder = reloadDateBorder()
            return true
        } else {
            return false
        }
    }
}

public enum TimeType {
    case normal
    case year
    case yearAndMonthAndDay
    case month
    case day
    case hour
    case hourAndMinute
}
