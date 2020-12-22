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
    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           is_freind = json["is_freind"].boolValue
           activities = json["activities"].arrayValue.map { UserWall(json: $0) }
    }
    
    init() {
        status = ""
        message = ""
        activities = [UserWall]()
    }
}
