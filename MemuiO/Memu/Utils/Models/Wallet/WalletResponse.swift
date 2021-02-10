//
//  WalletResponse.swift
//  Memu
//
//  Created by Tejaswini N on 10/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class WalletResponse {
    
    var referral_balance = ""
    var balance = ""
    
    init(json: JSON) {
           referral_balance = json["referral_balance"].stringValue
           balance = json["balance"].stringValue
       
    }
    init() {
        referral_balance = ""
        balance = ""
    }
}
