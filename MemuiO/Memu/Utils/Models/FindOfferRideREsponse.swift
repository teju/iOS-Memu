//
//  FindOfferRideREsponse.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class FindOfferRideREsponse {
    var message = ""
    var status = ""
    var trip_id = ""
    var rider_count = ""
    var trip_rider_id = ""
    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           trip_id = json["trip_id"].stringValue
        trip_rider_id = json["trip_rider_id"].stringValue
        rider_count = json["rider_count"].stringValue



       }
    init() {
        status = ""
        message = ""
         trip_id = ""
         rider_count = ""
        trip_rider_id = ""
    }
}
