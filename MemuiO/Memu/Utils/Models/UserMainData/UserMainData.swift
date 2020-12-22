//
//  UserMainData.swift
//  Memu
//
//  Created by Tejaswini N on 17/09/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserMainData {
    
    var followers = 0
    var followings = 0
    var friends = 0
    var id = 0
    var likes = 0
    var messages = 0
    var name = ""
    var distance_shared = ""
    var posts = 0
    var photo = Photo()
    var rides_shared = 0
    var rating = ""
//
//    var officeAddress: String
//    var workEmail: String
    
    
    
    init(json: JSON) {
        
        id = json["id"].intValue
        followers = json["followers"].intValue
        followings = json["followings"].intValue
        friends = json["friends"].intValue
        likes = json["likes"].intValue
        messages = json["messages"].intValue
        name = json["name"].stringValue
        distance_shared = json["distance_shared"].stringValue
        rides_shared = json["rides_shared"].intValue
        rating = json["rating"].stringValue
        posts = json["posts"].intValue
        photo = Photo(json: json["photo"])

    }

    init() {}
}
