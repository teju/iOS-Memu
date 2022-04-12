//
//  ProfilePhoto.swift
//  Memu
//
//  Created by Tejaswini N on 24/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON


class ProfilePhoto {
    
    var status: String
    var message: String
    var profile_path: String
    init(json: JSON) {

        status = json["status"].stringValue
        message = json["message"].stringValue
        profile_path = json["profile_path"].stringValue
    }
    
    init() {
        status = ""
        message = ""
        profile_path = ""
    }
}
