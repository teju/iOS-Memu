//
//  VehicleListResponse.swift
//  Memu
//
//  Created by Tejaswini N on 22/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class VehicleListResponse {
    var message = ""
    var status = ""
    var vehicle_list = [VehicleList]()

    init(json: JSON) {
           message = json["message"].stringValue
           status = json["status"].stringValue
           vehicle_list = json["vehicle_list"].arrayValue.map { VehicleList(json: $0) }


       }
    init() {
        status = ""
        message = ""
        vehicle_list = [VehicleList]()
    }
}
