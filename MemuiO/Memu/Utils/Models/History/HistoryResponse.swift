//
//  HistoryResponse.swift
//  Memu
//
//  Created by Tejaswini N on 23/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class HistoryResponse {
    var message = ""
    var status = ""
    var count = 0
    var scheduled_list = [ScheduledList]()
    var completed_list = [ScheduledList]()

    init(json: JSON) {
       message = json["message"].stringValue
       status = json["status"].stringValue
      scheduled_list = json["scheduled_list"].arrayValue.map { ScheduledList(json: $0) }
        completed_list = json["completed_list"].arrayValue.map { ScheduledList(json: $0) }
   }
    init() {
        status = ""
        message = ""
        count = 0
        scheduled_list = [ScheduledList]()
        completed_list = [ScheduledList]()
      //  vehicle_list = [VehicleList]()
    }
}
