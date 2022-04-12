//
//  AuthenticationUtil.swift
//  Attendee
//
//  Created by TCCODER on 1/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON
//import RxCocoa
import RxSwift
//import FBSDKCoreKit
//import FBSDKLoginKit
//import GoogleSignIn

/// the constants used to store profile data
let kAuthenticatedUserInfo = "kAuthenticatedUserInfo"

/**
 * Utility for storing and getting current user profile data
 *
 * - author: TCCODER
 * - version: 1.0
 */
final class AuthenticationUtil {

    /// flag: true - need to remember password, false - else
    var rememberPassword = false

    /// the user info
    var userInfo: UserInfo? {
        didSet {
            if let userInfo = userInfo {
                if rememberPassword { // persist only if need to save password
                    _ = userInfo.toJson.saveFile(kAuthenticatedUserInfo)
                }
                
                fetchRegistrations()
            }
            else {
                FileUtil.removeFile(kAuthenticatedUserInfo)
                registeredSessions.value.removeAll()
            }
        }
    }
    
    /// fetch registrations
     func fetchRegistrations() {
        guard let userInfo = userInfo,
            TokenUtil.accessToken != nil else { return }
        _ = RestDataSource.getSessionAttendees(offset: nil, pageSize: 1000, userId: userInfo.id)
            .subscribe(onNext: { [weak self] value in
                self?.registeredSessions.value = value.entities.filter { $0.status != "Deleted" }
                }, onError: { _ in
            })
    }
    
    /// sessions user is registered to
    var registeredSessions = Variable([Attendee]())

    static let sharedInstance = AuthenticationUtil()

    // This prevents others from using the default '()' initializer for this class.
    private init() {
        if let json = JSON.contentOfFile(kAuthenticatedUserInfo) {
            self.rememberPassword = true
            self.userInfo = UserInfo.fromJson(json)
            fetchRegistrations()
        }
    }

    /**
     Check if user is already authenticated

     - returns: true - is user is authenticated, false - else
     */
    func isAuthenticated() -> Bool {
        return userInfo != nil
    }

    /**
     Clean up any stored user information
     */
    func cleanUp() {
        userInfo = nil
        registeredSessions.value.removeAll()
    }

    /**
     Get value by key

     - parameter key: the key

     - returns: the value
     */
    func getValueByKey(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }

    /**
     Save value to local preferences

     - parameter value: the value to save
     - parameter key:   the key
     */
    func saveValueForKey(_ value: String?, key: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }

}

