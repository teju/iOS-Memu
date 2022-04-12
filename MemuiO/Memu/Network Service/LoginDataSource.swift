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
    ///   - mobileNo: mobileNo
    ///API Used:  POST https://memu.world/api/web/user/login
    static func verifyMobile(_ mobileNo: String) -> Observable<ResponceResult> {
        
        let parameters: [String: Any] = [
            "username": mobileNo
        ]
        let sendParameters: [String: Any] = [
            "LoginForm": parameters
        ]
        
        return json(.post, "user/login",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func updateFCMID(_ fcmID: String) -> Observable<ResponceResult> {
        
        let parameters: [String: Any] = [
            "google_fcm_id": fcmID,"user_id":UserDefaults.user_id
        ]
        let sendParameters: [String: Any] = [
            "PushNotification": parameters
        ]
        
        return json(.post, "user/update-fcm-id",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    /// performs email exists or not
    /// /// - Parameters:
    ///   - mobileNo: mobileNo
    ///API Used:  POST https://memu.world/api/web/user/login
    static func requestMobile(_ mobileNo: String) -> Observable<ResponceResult> {
        let parameters: [String: Any] = [
            "mobile": mobileNo
        ]
        return json(.post, "user/request-mobile-otp",
                    parameters: parameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }

    static func currentVehicleLocation(_ location_details: Address) -> Observable<ResponceResult> {
        let parameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "location_details":location_details.toParams2()
        ]
        return json(.post, "vehicle/current-vehicle-location",
                    parameters: parameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    
    /// performs email exists or not
    /// /// - Parameters:
    ///   - mobileNo: mobileNo
    ///API Used:  POST https://memu.world/api/web/user/mobile-otp-verify
    static func verifyOTP(_ mobileNo: String, OTP: String) -> Observable<ResponceResult> {
        
        let parameters: [String: Any] = [
            "mobile": mobileNo,
            "otp_code": OTP
        ]
        let sendParameters: [String: Any] = [
            "OtpForm": parameters
        ]
        
        return json(.post, "user/mobile-otp-verify",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }


    /// performs login
    ///
    /// - Parameters:
    ///   - mobileNo: mobileNo
    ///   - OTP: OTP
    /// - Returns: call observable
    ///API Used:  POST "https://memu.world/api/web/user/otp"
    static func login(mobileNo: String, OTP: String, callback: ((String)->())? = nil) -> Observable<UserInfo?> {
        let otpParam: [String: Any] = [
            "otp_code": OTP
        ]
        let mobileParam: [String: Any] = [
            "username": mobileNo
        ]
        let sendParameters: [String: Any] = [
            "LoginForm": mobileParam,
            "OtpForm": otpParam
        ]
        return json(.post, "user/otp",
            parameters: sendParameters)
            .do(onNext: { (json) in
                let token = json["access_token"].stringValue
                callback?(token)
                TokenUtil.store(accessToken: token, until: Date(timeIntervalSinceNow: TokenUtil.defaultLifetime).fullFormat)
            }).map { json in
                if let dict =  json.dictionaryObject {
                    return UserInfo(json: JSON(dict))
                }
                return nil
        }
        .restSend()
    }

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
            
            TokenUtil.cleanup()
        }).catchError({ (error) -> Observable<JSON> in
            print("ERROR: logout()\(error)")
            
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
    static func signUp(_ userInfo: UserInfo, callback: ((String)->())? = nil) -> Observable<UserInfo?> {
        return json(.post, "user/user-signup", parameters: userInfo.toParams())
            .do(onNext: { (json) in
                let token = json["access_token"].stringValue
                callback?(token)
                TokenUtil.store(accessToken: token, until: Date(timeIntervalSinceNow: TokenUtil.defaultLifetime).fullFormat)
            }).map { json in
            if let dict =  json.dictionaryObject {
                return UserInfo(json: JSON(dict))
            }
            return nil
        }
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
