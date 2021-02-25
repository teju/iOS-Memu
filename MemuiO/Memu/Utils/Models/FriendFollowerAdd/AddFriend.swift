//
//  AddFriend.swift
//  Memu
//
//  Created by Tejaswini N on 25/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class AddFriend {
  
    var status: String
    var message: String
    var user_details = AddUserDetails()

    init(json: JSON) {
        status = json["status"].stringValue
        message = json["message"].stringValue
        user_details = AddUserDetails(json: json["user_detail"])
    }
    
    init() {
        status = ""
        message = ""
    }
}
