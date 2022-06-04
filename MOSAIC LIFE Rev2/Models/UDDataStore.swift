//
//  UDDataStore.swift
//  Models
//
//  Created by Toshiki Hanakawa on 2022/04/19.
//

import Foundation

public enum UDDataStoreError : Error {
    case unknown
}

public struct UDDataStore {
    public enum Key: String {
        // Point
        case currentPt = "CURRENT_POINTS"
        case ptPerHour = "POINTS_PER_HOUR"
        case taskRate = "TASK_RATE"
        case shopRate = "SHOP_RATE"
        case rateOption = "RATE_OPTION"
        // Date
        case dateBorder = "DATEBORDER"
        case lastHour = "LAST_HOUR"
        // Spt
        case spt = "CURRENT_SPT"
        case sptRank = "SPT_RANK"
        case sptCount = "SPT_COUNT"
        // Effect
        case effectsCount = "EFFECTS_COUNT"
        // Log
        case activityLogText = "ACTIVITYLOGTEXT"
    }
    
    private let userDefaults = UserDefaults.standard
    
    public init() {
        userDefaults.register(defaults: [
            // Point
            Key.currentPt.rawValue : 0,
            Key.ptPerHour.rawValue : 0,
            Key.taskRate.rawValue : 1,
            Key.shopRate.rawValue : 1,
            Key.rateOption.rawValue : true,
            // Date
            Key.dateBorder.rawValue : Calendar(identifier: .gregorian).date(from: DateComponents(year: 2022, month: 4, day: 1))!,
            Key.lastHour.rawValue : 4,
            // Spt
            Key.spt.rawValue : 0,
            Key.sptRank.rawValue : 0,
            Key.sptCount.rawValue : 0,
            // Effect
            Key.effectsCount.rawValue : [[0,0,0],[0,0,0],[0,0,0]],
            // Log
            Key.activityLogText.rawValue : Data()
        ])
    }
    
    public func set (_ key : Key, _ value : Any) -> Void {
        userDefaults.set(value, forKey: key.rawValue)
//        if userDefaults.synchronize() {
//            return .success(value)
//        }
//        return .failure(.unknown)
    }
    
    public func fetchObject (key : Key) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    public func fetchInt (key : Key) -> Int {
        return userDefaults.integer(forKey: key.rawValue)
    }
    
    public func fetchDouble (key: Key) -> Double {
        return userDefaults.double(forKey: key.rawValue)
    }
    
    public func fetchBoolean (key: Key) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }
    
}
