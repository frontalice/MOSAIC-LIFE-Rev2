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
        case currentPt = "CURRENT_POINTS"
    }
    
    private let userDefaults = UserDefaults.standard
    
    public init() {
        userDefaults.register(defaults: [
            Key.currentPt.rawValue : 0
        ])
    }
    
    public func set (_ key : Key, _ value : Any) -> Void {
        userDefaults.set(value, forKey: key.rawValue)
//        if userDefaults.synchronize() {
//            return .success(value)
//        }
//        return .failure(.unknown)
    }
    
    public func fetchInt (_ key : Key) -> Int {
        return userDefaults.integer(forKey: key.rawValue)
    }
    
}
