//
//  FriendsListResponse.swift
//  Memu
//
//  Created by Tejaswini N on 17/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class FriendsListResponse {
    var message = ""
    var status = ""
    var user_list = [Friend]()

    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           user_list = json["user_list"].arrayValue.map { Friend(json: $0) }


       }
    init() {
        status = ""
        message = ""
        user_list = [Friend]()
    }
}
