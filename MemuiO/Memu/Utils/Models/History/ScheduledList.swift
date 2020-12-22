//
//  ScheduledList.swift
//  Memu
//
//  Created by Tejaswini N on 23/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScheduledList {
    var status = ""
    var id = ""
    var type = ""
    var date = ""
    var time = ""
    var days = ""
    
    var no_of_seats = ""
    var vehicle_id = ""


    var fromaddress = Address()
    var toaddress = Address()
    var matched_budies = [MatchedBuddies]()

    init(json: JSON) {
       status = json["status"].stringValue
       id = json["id"].stringValue
       type = json["type"].stringValue
       date = json["date"].stringValue
       time = json["time"].stringValue
        days = json["days"].stringValue

        let fromaddressJson = json["from_address"]
        if(fromaddressJson.count != 0) {
            fromaddress = Address(json: JSON(fromaddressJson.dictionaryObject!))
        }
        let toaddressJson = json["to_address"]
        if(toaddressJson.count != 0) {
            toaddress = Address(json: JSON(toaddressJson.dictionaryObject!))
        }
        matched_budies = json["matched_budies"].arrayValue.map { MatchedBuddies(json: $0) }


       }
    init() {
        status = ""
        id = ""
        type = ""
        date = ""
        time = ""
        days = ""
        fromaddress = Address()
        toaddress = Address()
        matched_budies = [MatchedBuddies]()
      //  vehicle_list = [VehicleList]()
    }
}
