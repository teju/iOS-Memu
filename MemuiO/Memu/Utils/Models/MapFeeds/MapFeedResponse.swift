//
//  MapFeedResponse.swift
//  Memu
//
//  Created by Tejaswini N on 15/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class MapFeeds {
    var feed_name = ""
    var feed_id = ""
    var longitude = ""
    var lattitude = ""
    var logo = ""

    init(json: JSON) {
        feed_name = json["feed_name"].stringValue
        feed_id = json["feed_id"].stringValue
        longitude = json["longitude"].stringValue
        lattitude = json["lattitude"].stringValue
        logo = json["logo"].stringValue

    }
    init() {
        feed_name = ""
        feed_id = ""
        longitude = ""
        lattitude = ""
        logo = ""

    }
}
