//
//  AlertMapFeedsResponse.swift
//  Memu
//
//  Created by Tejaswini N on 17/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class AlertMapFeedsResponse {
    var message = ""
    var status = ""
    var map_feeds = [AlertMapFeeds]()

    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           map_feeds = json["map_feeds"].arrayValue.map { AlertMapFeeds(json: $0) }


       }
    init() {
        status = ""
        message = ""
        map_feeds = [AlertMapFeeds]()
    }
}
