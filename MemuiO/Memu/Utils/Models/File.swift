//
//  File.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/3/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class File {
    var property: String = ""
    var name: String
    var mimeType: String = ""
    var url: String
    var size = 0
    var fileId: String = ""
    var uploadedBy: String = ""
    var photo = Photo()

    init(json: JSON) {
        property = json["property"].stringValue
        name = json["name"].stringValue
        url = json["url"].stringValue
        mimeType = json["mimeType"].stringValue
        size = json["size"].intValue
        fileId = json["_id"].stringValue
        uploadedBy = json["uploadedBy"].stringValue
        photo = Photo(json: json["profile_path"])
    }
    
    func toParams() -> [String: Any] {
        let dic: [String:Any] = [
            "_id": fileId,
            "property":property,
            "name": name,
            "url": url,
            "mimeType": mimeType,
            "uploadedBy": uploadedBy,
            "size": size
        ]
        return dic
    }
}
