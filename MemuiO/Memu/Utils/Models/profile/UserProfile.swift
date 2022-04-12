//
//  UserInfo.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserProfile {
  
    var vehicle = [Vehicle]()
    var personal_details = UserInfo()
    var address = ProfileAddress()

//
//    var officeAddress: String
//    var workEmail: String
    
    
    
    init(json: JSON) {
        
        vehicle = json["vehicle"].arrayValue.map { Vehicle(json: $0) }
        personal_details = UserInfo(json: json["personal_details"])
        address = ProfileAddress(json: json["address"])

    }
   
    init() {}
}
