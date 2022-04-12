//
//  MatchingBuddiesResponse.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class MatchingBuddiesResponse {
    var message = ""
    var status = ""
    var count = 0
    var pooler_list = [PoolerList]()
    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
            count = json["count"].int ?? 0
        if(json["pooler_list"].count != 0) {
            pooler_list = json["pooler_list"].arrayValue.map { PoolerList(json: $0) }
        } else {
            pooler_list = json["rider_list"].arrayValue.map { PoolerList(json: $0) }
        }
       }
    init() {
        status = ""
        message = ""
        count = 0

       pooler_list = [PoolerList]()
    }
}
