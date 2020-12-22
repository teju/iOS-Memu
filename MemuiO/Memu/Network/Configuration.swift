//
//  Configuration.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/30/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

/**
 * A helper class to get the configuration data in the plist file.
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
public final class Configuration: NSObject {
   
    
    // data
    var dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource:configurationPlistName , ofType: "plist")!)
    
    // singleton
    public static let shared = Configuration()
    
//    // apiBaseUrl
//    public static var appBaseUrl: String { return value(for: "appBaseUrl") }
//
//    // apiUrl
//    public static var appBaseUrl: String { return value(for: "appBaseUrl") }

    // apiUrl
    public static var appBaseUrl: String { return value(for: "appBaseUrl") }

    /// the timeout interval
    public static var timeoutInterval: TimeInterval { return value(for: "timeoutInterval") ?? 60 }


    /// Get String value from configuration for given key
    ///
    /// - Parameter key: the key
    /// - Returns: the value
    static func value(for key: String) -> String {
        return shared.dict![key] as? String ?? ""
    }

    /// Get Int value from configuration for given key
    ///
    /// - Parameter key: the key
    /// - Returns: the value
    static func value(for key: String) -> Int? {
        return shared.dict![key] as? Int
    }

    /// Get Double value from configuration for given key
    ///
    /// - Parameter key: the key
    /// - Returns: the value
    static func value(for key: String) -> TimeInterval? {
        return shared.dict![key] as? TimeInterval
    }

    /// Get Bool value from configuration for given key
    ///
    /// - Parameter key: the key
    /// - Returns: the value
    static func value(for key: String) -> Bool? {
        return shared.dict![key] as? Bool
    }
}
