//
//  DateManager.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/25.
//

import Foundation

class DateManager {
    public static let shared: DateManager = DateManager()
    private var now : Date = Date()
    private var japanCurrentTime : Date
    private var format : DateFormatter
    private let calendar = Calendar(identifier: .gregorian)
    private lazy var dateBorder: Date = UserDefaults.standard.object(forKey: "DATEBORDER") as! Date? ?? reloadDateBorder()
    
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
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.calendar = Calendar(identifier: .gregorian)
//        dateFormatter.locale = Locale(identifier: "ja_JP")
//        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
//
//        dateFormatter.dateFormat = "yyyy"
//        let year: Int = Int(dateFormatter.string(from: now))!
//
//        dateFormatter.dateFormat = "M"
//        let month: Int = Int(dateFormatter.string(from: now))!
//
//        dateFormatter.dateFormat = "d"
//        var day: Int = Int(dateFormatter.string(from: now))!
//
//        dateFormatter.dateFormat = "H"
//        let hour: Int = Int(dateFormatter.string(from: now))!
//        print("DateManager: 現在時を\(hour)時で取得")
//
//        if hour >= 4 {
//            day += 1
//        }
//
//        let calendar = Calendar(identifier: .gregorian)
//        let db = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 4, minute: 0, second: 0))!
        
        
        UserDefaults.standard.set(border, forKey: "DATEBORDER")
        print("DateManager: 日付変更線を\(border)で設定")
        return border
    }
    
    public func judgeIsDayChanged() -> Bool {
        // 日付変更線に関する処理
        if now > dateBorder {
            
            // 日付変更線更新
            dateBorder = reloadDateBorder()
            
            // dateBorderを日本時間で取得
//            format.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMdHm", options: 0, locale: Locale(identifier: "ja_JP"))
            
            return true
        } else {
            return false
        }
    }
}

public enum TimeType {
    case normal
    case hour
    case hourAndMinute
}
