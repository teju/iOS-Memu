//
//  VehicleList.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class VehicleList {
    var vehicle_type = ""
    var vehicle_model_type = ""
    var vehicle_no = ""
    var vehicle_brand = ""
    var vehicle_id = ""
    var vehicle_name = ""

    init(json: JSON) {
        vehicle_type = json["vehicle_type"].stringValue
        vehicle_model_type = json["vehicle_model_type"].stringValue
        vehicle_no = json["vehicle_no"].stringValue
        vehicle_brand = json["vehicle_brand"].stringValue
        vehicle_id = json["vehicle_id"].stringValue
        vehicle_name = json["vehicle_name"].stringValue

    }
    init() {
        vehicle_type = ""
        vehicle_model_type = ""
        vehicle_no = ""
        vehicle_brand = ""
        vehicle_id = ""
        vehicle_name = ""

    }
}
