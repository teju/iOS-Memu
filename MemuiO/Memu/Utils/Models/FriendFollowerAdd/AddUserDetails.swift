//
//  UserDetails.swift
//  Memu
//
//  Created by Tejaswini N on 25/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class AddUserDetails {
  
    var id: String
       var name: String
    var photo = Photo()
    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        photo = Photo(json: json["photo"])
    }
    init() {
        id = ""
        name = ""
      }
     
}
