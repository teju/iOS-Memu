//
//  Photo.swift
//  Memu
//
//  Created by Tejaswini N on 15/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Photo {
    
    var profile_path = ""
    
    init(json: JSON) {
        profile_path = json["profile_path"].stringValue
    }
    init() {
        profile_path = ""
    }
}
