//
//  ResponceResult.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class ResponceResult {
    
    var status: String
    var message: String
    var generate_signature: String
    init(json: JSON) {

        status = json["status"].stringValue
        message = json["message"].stringValue
        generate_signature = json["generate_signature"].stringValue
    }
    
    init() {
        status = ""
        message = ""
        generate_signature = ""
    }
}
