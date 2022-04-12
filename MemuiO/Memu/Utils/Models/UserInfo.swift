//
//  UserInfo.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserInfo {
    
    var id = ""
    var role = ""
    
    var mobile = ""
    var otp = ""
    
    var firstName = ""
    var lastName = ""
    var gender = ""
    
    var name = ""
    
    var vehicle = Vehicle()
    
    var address = [Address]()
    var email = ""
    var photo = Photo()
    var accessToken = ""
    var dl_number = ""
    var office_email = ""
    var referel_code = ""
    var result = ResponceResult()
//
//    var officeAddress: String
//    var workEmail: String
    
    
    
    init(json: JSON) {
        
        id = json["user_id"].stringValue
        dl_number = json["dl_number"].stringValue

        role = json["role_type"].stringValue
        accessToken = json["access_token"].stringValue
        mobile = json["mobile"].stringValue
        otp = json["otp"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        name = json["name"].stringValue
        gender = json["gender"].stringValue
        email = json["email"].stringValue
        referel_code = json["referel_code"].stringValue
        vehicle = Vehicle(json: json["vehicle"])
        address = json["Address"].arrayValue.map { Address(json: $0) }
        photo = Photo(json: json["photo"])

        result = ResponceResult(json: json)
        
        office_email = json["office_email"].stringValue
    }
    
    /// Convert UserInfo to JSON object
    ///
    /// - Returns: JSON object
    func toParams() -> [String: Any] {
        
        let userDic: [String: Any] = [
            "mobile": mobile,
            "first_name": firstName,
            "last_name": lastName,
            "gender": gender,
            "referel_code": "",
            "email": email
        ]
        var dic: [String: Any] = [
            "ApiSignupForm": userDic,
            "Address": address.map{ $0.toParams() }
        ]
        if !vehicle.vehicleName.isEmpty {
            dic["Vehicle"] = vehicle.toParams()
        }
        return dic
    }
    
    init() {}
}
