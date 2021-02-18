//
//  ProfileAddress.swift
//  Memu
//
//  Created by Tejaswini N on 11/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileAddress {
  
    var home = Address()
    var office = Address()

    init(json: JSON) {
        home = Address(json: json["home"])
        office = Address(json: json["office"])

    }
    func toParams() -> [String: Any] {
        let dic: [String: Any] = [
            "home": home,
            "office":office]
        return dic
    }
    init() {}
}
