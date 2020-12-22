//
//  UserWall.swift
//  Memu
//
//  Created by Tejaswini N on 18/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserWall {
    
    var date_time = ""
    var id = ""
    var image = Photo()
    var user_info = UserInf()
    var logo = ""
    var message = ""

    var shares = 0
    var from_address = Address()
    var to_address = Address()
    var address = Address()

     var type = ""
    init(json: JSON) {
           date_time = json["date_time"].stringValue
           id = json["id"].stringValue
        logo = json["logo"].stringValue
        type = json["type"].stringValue

        message = json["message"].stringValue

           image = Photo(json: json["image"])
            user_info = UserInf(json: json["user_info"])
        let from_addressJSon = json["from_address"]
        if(from_addressJSon.count != 0) {
            from_address = Address(json: JSON(from_addressJSon.dictionaryObject!))
        }
        let toaddressJson = json["to_address"]
        if(toaddressJson.count != 0) {
            to_address = Address(json: JSON(toaddressJson.dictionaryObject!))
        }
        let addressJson = json["address"]
        if(addressJson.count != 0) {
            address = Address(json: JSON(addressJson.dictionaryObject!))
        }
    }
    init() {
        date_time = ""
        id = ""
    }
}
