//
//  MatchedBuddies.swift
//  Memu
//
//  Created by Tejaswini N on 23/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON
class PoolerList {
    var time = ""
    var name = ""
    var mobile = ""

    var date = ""
    var email = ""
    var no_of_kms = ""
    var no_of_seats = ""
    var status = ""
    
    var trip_rider_id = ""
    var route_per = ""
    var user_id = ""
    var id = ""
    var fromaddress = Address()
    var toaddress = Address()
    var photo = Photo()
    init(json: JSON) {
        print("PoolerList \(json)")
       time = json["time"].stringValue
        name = json["name"].stringValue
        mobile = json["mobile"].stringValue
        date = json["date"].stringValue
        email = json["email"].stringValue
        no_of_kms = json["no_of_kms"].stringValue
        no_of_seats = json["no_of_seats"].stringValue
        status = json["status"].stringValue
        trip_rider_id = json["trip_rider_id"].stringValue
        route_per = json["route_per"].stringValue
        user_id = json["user_id"].stringValue
        id = json["id"].stringValue
        let fromaddressJson = json["from_address"]
        fromaddress = Address(json: JSON(fromaddressJson.dictionaryObject!))
        let toaddressJson = json["to_address"]
        toaddress = Address(json: JSON(toaddressJson.dictionaryObject!))
        photo = Photo(json: json["photo"])
    }
    
    init() {
        time = ""
        name = ""
        mobile = ""
        date = ""
        email = ""
        no_of_kms = ""
        no_of_seats = ""
        status = ""
        trip_rider_id = ""
        route_per = ""
        user_id = ""
        id = ""
        fromaddress = Address()
        toaddress = Address()
        photo = Photo()
    }
}
