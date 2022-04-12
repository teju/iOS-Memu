//
//  UserWallResponse.swift
//  Memu
//
//  Created by Tejaswini N on 18/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserWallResponse {
    var message = ""
    var status = ""
    var activities = [UserWall]()
    var is_freind = false
    var is_follower = false

    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           is_freind = json["is_freind"].boolValue
            is_follower = json["is_follower"].boolValue

           activities = json["activities"].arrayValue.map { UserWall(json: $0) }
    }
    
    init() {
        status = ""
        message = ""
        activities = [UserWall]()
        is_follower = false
    }
}
