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
        format.calendar = calendar
        format.dateFormat = "yyyy年M月d日 H時m分s秒"
    }
    
    public func fetchCurrentTime(type: TimeType) -> String {
        now = Date()
        switch type {
        case .normal:
            return format.string(from: japanCurrentTime)
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: type.rawValue, options: 0, locale: Locale(identifier: "ja_JP"))
            if type == .yesterday {
                return dateFormatter.string(from: Date(timeIntervalSinceNow: -60*60*24))
            } 
            return dateFormatter.string(from: now)
        }
    }
    
    public func reloadDateBorder() -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: japanCurrentTime)!
        let border = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: tomorrow)!
        userDefaults.set(.dateBorder, border)
        print("DateManager: 日付変更線を\(format.string(from: border))で設定")
        return border
    }
    
    public func judgeIsDayChanged() -> Bool {
        print("judge/現在時刻:\(format.string(from: now))")
        print("judge/更新時間:\(format.string(from: dateBorder))")
        if now > dateBorder {
            dateBorder = reloadDateBorder()
            return true
        } else {
            return false
        }
    }
}

public enum TimeType : String {
    case normal = "yyyy年M月d日 H時m分s秒"
    case yesterday = "yyyy年M月d日"
    case year = "y"
    case yearAndMonthAndDay = "yMMdd"
    case month = "MM"
    case day = "dd"
    case hour = "H"
    case hourAndMinute = "HHmm"
}
