//
//  LoginDataSource.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/30/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON

// MARK: - login related methods
extension RestDataSource {

    /// performs email exists or not
    /// /// - Parameters:
    ///   - email: email
    ///API Used:  "{appBaseUrl }/user/exists/{emailID}"
//    public static func verifyEmail(_ email: String) -> Observable<String> {
//        return string(.get, "user/exists/\(email)")
//    }
//    static func verifyEmail(_ email: String) -> Observable<ExistUserInfo> {
//        return json(.get, "user/exists/\(email)")
//            .map { json in
//                ExistUserInfo.init(json: JSON(json["data"]["result"].dictionaryObject as Any))
//        }
//        .restSend()
//    }


    /// performs login
    ///
    /// - Parameters:
    ///   - email: username
    ///   - password: password
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/login?rememberMe=true with above parameters
//    public static func login(username: String, password: String, company: String?, remember: Bool, callback: ((String)->())? = nil) -> Observable<UserInfo> {
//        let parameters: [String: Any] = [
//            "email": username,
//            "password": password
//        ]
//        return json(.post, "login?rememberMe=\(remember)",
//            parameters: parameters)
//            .do(onNext: { (json) in
//                let token = json["data"]["result"].stringValue
//                callback?(token)
//                TokenUtil.store(accessToken: token, until: Date(timeIntervalSinceNow: remember ? TokenUtil.defaultLifetime : 0).fullFormat)
//                AuthenticationUtil.sharedInstance.rememberPassword = remember
//
//            })
//            .flatMap({ _ in
//                RestDataSource.getUser(setAuthenticated: false)
//            })
//            .restSend()
//    }

    /// Register `deviceToken` for APNS
    ///
    /// - Parameters:
    ///   - deviceToken: deviceToken 
    ///   - deviceType  : IOS
    ///   - deviceId  : {UUID}
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/users/devices with above parameters
    static func registerDevice(deviceToken: String) -> Observable<JSON> {
        return json(.post, "users/devices", parameters: [
            "deviceToken": deviceToken,
            "deviceType": "IOS",
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ])
            .restSend()
    }
    
    /// De-Register `deviceToken` for APNS
    ///
    /// - Parameters:
    ///   - deviceToken: the token
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/users/devices/{deviceId} with above parameters
    static func deRegisterDevice(deviceId: String) -> Observable<JSON> {
        return json(.delete, "users/devices/\(deviceId)").do(onNext: { (_) in
            AuthenticationUtil.sharedInstance.cleanUp()
            TokenUtil.cleanup()
        }).catchError({ (error) -> Observable<JSON> in
            print("ERROR: logout()\(error)")
            AuthenticationUtil.sharedInstance.cleanUp()
            TokenUtil.cleanup()
            return Observable.just(JSON(1))
        })
            .restSend()
    }
    
    /// signUp: registers a new user
    ///
    /// - Parameters:
    ///   - email: email
    ///   - password: password
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/user/signup with above parameters
    static func signUp(email: String, password: String) -> Observable<Void> {
        return json(.post, "user/signup",
                    parameters: [
                        "email": email,
                        "password": password
        ])
            .toVoid()
            .restSend()
    }

    /// signUp Verify with OTP Token: registered  user verify email
    ///
    /// - Parameters:
    ///   - email: email
    ///   - otp: otpString
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/user/verify-email with above parameters
//    static func signUpUserVerifyEmail(email: String, otpString: String, remember: Bool, callback: ((String)->())? = nil) -> Observable<UserInfo> {
//    let parameters: [String: Any] = [
//              "email": email,
//              "otp": otpString
//          ]
//          return json(.post, "user/verify-email",
//              parameters: parameters)
//              .do(onNext: { (json) in
//                  let token = json["data"]["result"].stringValue
//                  callback?(token)
//                  TokenUtil.store(accessToken: token, until: Date(timeIntervalSinceNow: remember ? TokenUtil.defaultLifetime : 0).fullFormat)
//                  AuthenticationUtil.sharedInstance.rememberPassword = remember
//
//              })
//              .flatMap({ _ in
//                  RestDataSource.getUser(setAuthenticated: false)
//              })
//              .restSend()
//      }

    //Forgot Password ( PUT -> user/forgot-password/{email} )
    ///
    /// - Parameters:
    ///   - email: email
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/user/forgot-password/{email} with above parameters
    static func initiatePasswordReset (email: String) -> Observable<Void> {
        return json(.put, "user/forgot-password/\(email)")
            .toVoid()
            .restSend()
    }

    //Forgot Password - Email Sent ( POST -> otp/verify )
    ///
    /// - Parameters:
    ///   - email: email
    ///   - otp: otpString
    ///   - type : password
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/otp/verify  with above parameters
    static func passwordResetVerifyOTP(email: String, otpString:String) -> Observable<Void> {
        return json(.post, "otp/verify",
                    parameters: [
                        "email": email,
                        "otp": otpString,
                        "type": "password"
        ])
            .toVoid()
            .restSend()
    }

    //Forgot Password - Password Reset ( PUT -> user/reset-password  )
    ///
    /// - Parameters:
    ///   - email: email
    ///   - otp: otpString
    ///   - newPassword : newPasswordString
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/user/reset-password  with above parameters
    static func passwordReset(email: String, otpString:String, newPasswordString:String) -> Observable<Void> {
        return json(.put, "user/reset-password",
                    parameters: [
                        "email": email,
                        "otp": otpString,
                        "newPassword": newPasswordString
        ])
            .toVoid()
            .restSend()
    }


    //Re-Sends an otp to verify an email
    ///
    /// - Parameters:
    ///   - email: email
    /// - Returns: call observable
    ///API Used:  {appBaseUrl }/user/resend/email-verification-otp/{email}
    ///
    static func resendLink(email: String) -> Observable<Void> {
        return json(.post, "user/resend/email-verification-otp/\(email)")
            .toVoid()
            .restSend()
    }
}
