//
//  TopEarners.swift
//  Memu
//
//  Created by Tejaswini N on 10/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class TopEarners {
    
    var referral_balance = ""
    var balance = ""
    var city_earners = [City]()
    var friend_earners = [City]()

    init(json: JSON) {
       referral_balance = json["referral_balance"].stringValue
      city_earners = json["city_earners"].arrayValue.map { City(json: $0) }
        friend_earners = json["friend_earners"].arrayValue.map { City(json: $0) }

    }
    init() {
        referral_balance = ""
        balance = ""
        city_earners = [City]()
        friend_earners = [City]()
    }
}
