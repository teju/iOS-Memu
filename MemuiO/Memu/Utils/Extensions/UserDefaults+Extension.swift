//
//  UserDefaults+Extension.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation

extension UserDefaults {

    /// first launch flag
    static var firstLaunch: Bool {
        get {
            return standard.bool(forKey: "firstLaunch")
        }
        set {
            standard.set(newValue, forKey: "firstLaunch")
            standard.synchronize()
        }
    }
    
    static var isAuthenticated: Bool {
        get {
            return standard.bool(forKey: "isAuthenticated")
        }
        set {
            standard.set(newValue, forKey: "isAuthenticated")
            standard.synchronize()
        }
    }
    static var isFirstTime: Bool {
        get {
            return standard.bool(forKey: "isFirstTime")
        }
        set {
            standard.set(newValue, forKey: "isFirstTime")
            standard.synchronize()
        }
    }
    static var name: String? {
        get {
            if let name = standard.value(forKey: "name") as? String {
                 return name
             } else {
                 return ""
             }
        }
        set {
            standard.set(newValue, forKey: "name")
            standard.synchronize()
        }
    }
    static var accessToken: String? {
        get {
            if let name = standard.value(forKey: "accessToken") as? String {
                 return name
             } else {
                 return ""
             }
        }
        set {
            standard.set(newValue, forKey: "accessToken")
            standard.synchronize()
        }
    }
    
    static var latitude: Double? {
        get {
            if let latitude = standard.value(forKey: "latitude") as? Double {
                 return latitude
             } else {
                return 0.0
             }
        }
        set {
            standard.set(newValue, forKey: "latitude")
            standard.synchronize()
        }
    }
    
    static var longitude: Double? {
        get {
            if let longitude = standard.value(forKey: "longitude") as? Double {
                 return longitude
             } else {
                return 0.0
             }
        }
        set {
            standard.set(newValue, forKey: "longitude")
            standard.synchronize()
        }
    }
    static var user_id: String? {
        get {
            if let user_id = standard.value(forKey: "user_id") as? String {
                 return user_id
             } else {
                return ""
             }
        }
        set {
            standard.set(newValue, forKey: "user_id")
            standard.synchronize()
        }
    }
    static var referel_code: String? {
        get {
            if let referel_code = standard.value(forKey: "referel_code") as? String {
                 return referel_code
             } else {
                return ""
             }
        }
        set {
            standard.set(newValue, forKey: "referel_code")
            standard.synchronize()
        }
    }
    static var profile_picture: String? {
        get {
            if let user_id = standard.value(forKey: "profile_picture") as? String {
                 return user_id
             } else {
                return ""
             }
        }
        set {
            standard.set(newValue, forKey: "profile_picture")
            standard.synchronize()
        }
    }
}
