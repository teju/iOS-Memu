//
//  Friend.swift
//  Memu
//
//  Created by Tejaswini N on 17/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Friend {
    var distance = ""
    var freind_id = ""
    var id = ""
    var lattitude = ""
    var longitude = ""
    var name = ""
    var photo = Photo()


    init(json: JSON) {
           distance = json["distance"].stringValue
           freind_id = json["freind_id"].stringValue
           id = json["id"].stringValue
           lattitude = json["lattitude"].stringValue
           longitude = json["longitude"].stringValue
            name = json["name"].stringValue
        photo = Photo(json: json["photo"])


       }
    init() {
        distance = ""
        freind_id = ""
    }
}
