//
//  Coins.swift
//  Memu
//
//  Created by Tejaswini N on 27/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Coins {
    var amount = 0
    var memu_amount =  0
    

    init(json: JSON) {
       amount = json["amount"].intValue
       memu_amount = json["memu_amount"].intValue
   }
    init() {
        amount = 0
        memu_amount =  0
    }
}
