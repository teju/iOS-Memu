//
//  Notifications.swift
//  Memu
//
//  Created by Tejaswini N on 24/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notifications {
    
    var type: String? = ""
    var name: String? = ""
    var photo = Photo()
    var isAccept :Bool = false
    var freind_id = ""
    var user_map_feeds_id = ""
    var logo = ""
    var flag = ""
    var lattitude = 0.0
    var longitude = 0.0
    var trip_id = ""
    var trip_rider_id = ""
    init(json: JSON) {

        type = json["type"].stringValue
        lattitude = json["lattitude"].doubleValue
        longitude = json["longitude"].doubleValue
        name = json["name"].stringValue
        isAccept = json["isAccept"].boolValue
        freind_id = json["freind_id"].stringValue
        trip_id = json["trip_id"].stringValue
        trip_rider_id = json["trip_rider_id"].stringValue
        logo = json["logo"].stringValue
        flag = json["flag"].stringValue
        user_map_feeds_id = json["user_map_feeds_id"].stringValue
        photo = Photo(json: json["photo"])

    }
    
    init() {
        user_map_feeds_id = ""
        type = ""
        name = ""
        photo = Photo()
        isAccept  = false
        freind_id = ""
        logo = ""
        flag = ""
        trip_id = ""
        trip_rider_id = ""
    }
}
