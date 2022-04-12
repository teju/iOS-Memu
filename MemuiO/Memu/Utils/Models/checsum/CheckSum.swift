//
//  CheckSum.swift
//  Memu
//
//  Created by Tejaswini N on 16/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class CheckSum {
    
    var body = Body()
    init(json: JSON) {

       body = Body(json: json["body"])
    }
    
    init() {
        body = Body()
    }
}
