//
//  Body.swift
//  Memu
//
//  Created by Tejaswini N on 16/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Body {
    
    var txnToken: String

    init(json: JSON) {
        txnToken = json["txnToken"].stringValue
    }
    
    init() {
        txnToken = ""

    }
}
