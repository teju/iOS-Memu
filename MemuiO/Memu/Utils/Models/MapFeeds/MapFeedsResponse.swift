//
//  MapFeedsResponse.swift
//  Memu
//
//  Created by Tejaswini N on 15/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class MapFeedsResponse {
    var message = ""
    var status = ""
    var feeds = [MapFeeds]()

    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           feeds = json["list"].arrayValue.map { MapFeeds(json: $0) }


       }
    init() {
        status = ""
        message = ""
        feeds = [MapFeeds]()
    }
}
