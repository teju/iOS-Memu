//
//  Address.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Address {
    
    var type = ""
    var address = ""
    var lattitude = ""
    var longitude = ""
    var formattedAddress = ""
    var country = ""
    var state = ""
    var city = ""
    var location = ""
    var pincode = ""
    var id = ""
    var address_line1 = ""
    init(json: JSON) {
        
        type = json["type"].stringValue
        address = json["address_line1"].stringValue
        lattitude = json["lattitude"].stringValue
        longitude = json["longitude"].stringValue
        formattedAddress = json["formatted_address"].stringValue
        country = json["country"].stringValue
        state = json["state"].stringValue
        city = json["city"].stringValue
        location = json["location"].stringValue
        pincode = json["pincode"].stringValue
        id = json["id"].stringValue
    }
    
    /// Convert UserInfo to JSON object
    ///
    /// - Returns: JSON object
    func toParams() -> [String: Any] {
        var dic: [String: Any] = [
            "lattitude": lattitude,
            "longitude": longitude,
            "formatted_address": formattedAddress
        ]
        if address.isEmpty {
            dic["address_line1"] = formattedAddress
        } else {
            dic["address_line1"] = address
        }
        if !id.isEmpty {
             dic["id"] = id
        }
        if !type.isEmpty {
             dic["type"] = type
        }
       
        return dic
    }
    func toParams2() -> [String: Any] {
        var dic: [String: Any] = [
            "type": type,
            "lattitude": lattitude,
            "longitude": longitude,
            "formatted_address": formattedAddress,
            "country": country,
            "state": state,
            "city": city,
            "location": location,
            "pincode": pincode
        ]
        if address.isEmpty {
            dic["address_line1"] = formattedAddress
        } else {
            dic["address_line1"] = address
        }
        if(!id.isEmpty) {
            dic["id"] = id
        }
        return dic
    }
    
    init() {
    }
}
