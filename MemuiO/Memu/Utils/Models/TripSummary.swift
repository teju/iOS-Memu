//
//  TripSummary.swift
//  Memu
//
//  Created by Tejaswini N on 01/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class TripSummary {
    
    var status: String
    var message: String
    var money_earned_spent: String
    var reputation_coin: String
    var time_taken: String
    var distance_travelled: String
    init(json: JSON) {

        status = json["status"].stringValue
        message = json["message"].stringValue
        money_earned_spent = json["money_earned_spent"].stringValue
        reputation_coin = json["reputation_coin"].stringValue
        time_taken = json["time_taken"].stringValue
        distance_travelled = json["distance_travelled"].stringValue
    }
    
    init() {
        status = ""
        message = ""
        money_earned_spent = ""
        reputation_coin = ""
        time_taken = ""
        distance_travelled = ""
    }
}
