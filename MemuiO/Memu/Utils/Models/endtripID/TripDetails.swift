//
//  TripDetails.swift
//  Memu
//
//  Created by Tejaswini N on 30/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON
class TripDetails  {
    
    var trip_id = ""
    var trip_rider_id = ""
    var driver_id = ""
    var vehicle_id = ""
    var no_of_kms = ""
    var price_per_km = ""
    init(json: JSON) {
        trip_id = json["trip_id"].stringValue
        trip_rider_id = json["trip_rider_id"].stringValue
        driver_id = json["driver_id"].stringValue

        vehicle_id = json["vehicle_id"].stringValue

        no_of_kms = json["no_of_kms"].stringValue

        price_per_km = json["price_per_km"].stringValue

    }
    
    init() {}
}

