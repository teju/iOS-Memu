//
//  WalletBalance.swift
//  Memu
//
//  Created by Tejaswini N on 22/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class WalletBalance {
    
    var status: String
    var balance: String
    var referral_balance: String
    init(json: JSON) {

        status = json["status"].stringValue
        balance = json["balance"].stringValue
        referral_balance = json["referral_balance"].stringValue
    }
    
    init() {
        status = ""
        balance = ""
        referral_balance = ""
    }
}
