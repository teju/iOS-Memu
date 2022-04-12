//
//  City.swift
//  Memu
//
//  Created by Tejaswini N on 10/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class City {
    
    var city = ""
    var name = ""
    var total_points = ""
    var photo = Photo()
    init(json: JSON) {
        city = json["city"].stringValue
        name = json["name"].stringValue
        total_points = json["total_points"].stringValue
        photo = Photo(json: json["photo"])
    }
    init() {
        city = ""
        name = ""
        name = ""
        photo = Photo()
    }
}
