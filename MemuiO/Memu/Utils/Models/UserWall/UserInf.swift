//
//  UserInfo.swift
//  Memu
//
//  Created by Tejaswini N on 18/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserInf {
    var name = ""
    var photo = Photo()

    init(json: JSON) {
           name = json["name"].stringValue
           photo = Photo(json: json["photo"])
           
    }
    
    init() {
        name = ""
       photo = Photo()
    }
}
