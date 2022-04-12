//
//  AlertMapFeeds.swift
//  Memu
//
//  Created by Tejaswini N on 17/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class AlertMapFeeds {
    var points = ""
    var logo = ""
    var id = ""
    var name = ""
    var logo_wt_pin = ""
    init(json: JSON) {
        points = json["points"].stringValue
        logo = json["logo"].stringValue
        id = json["id"].stringValue
        name = json["name"].stringValue
         logo_wt_pin = json["logo_wt_pin"].stringValue
    }
    init() {
        points = ""
        logo = ""
        id = ""
        name = ""
        logo_wt_pin = ""
    }
}
