//
//  EndTripID.swift
//  Memu
//
//  Created by Tejaswini N on 30/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON
class EndTripID  {
    
    var message = ""
    var trip_details = TripDetails()
    var status = ""
    init(json: JSON) {
        
        message = json["message"].stringValue
        trip_details = TripDetails(json: json["trip_details"])
        status = json["status"].stringValue
    }
    
    init() {}
}

