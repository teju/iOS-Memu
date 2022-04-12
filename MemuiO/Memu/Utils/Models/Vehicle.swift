//
//  Vehicle.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Vehicle {
    
    var vehicleType: Int = 0
    var vehicleBrand: String = ""
    var vehicleName: String = ""
    var vehicleNo: String = ""
    var vehicleModelType: String = ""
    
    var registrationNo: String = ""
    var licenseNo: String = ""
    var id : String = ""
    init(json: JSON) {
        id = json["id"].stringValue

        vehicleType = json["vehicle_type"].intValue
        vehicleBrand = json["vehicle_brand"].stringValue
        vehicleName = json["vehicle_name"].stringValue
        vehicleNo = json["vehicle_no"].stringValue
        vehicleModelType = json["vehicle_model_type"].stringValue
        
        
        registrationNo = json["registrationNo"].stringValue
        licenseNo = json["licenseNo"].stringValue
    }
    
    /// Convert UserInfo to JSON object
    ///
    /// - Returns: JSON object
    func toParams() -> [String: Any] {
        let dic: [String: Any] = [
            "id": id,
            "vehicle_type": vehicleType,
            "vehicle_brand": vehicleBrand,
            "vehicle_name": vehicleName,
            "vehicle_no": vehicleNo,
            "vehicle_model_type": vehicleModelType
        ]
        return dic
    }

    func toParams2() -> [String: Any] {
        let dic: [String: Any] = [
            "vehicle_brand": vehicleBrand,
            "vehicle_name": vehicleName,
            "vehicle_no": vehicleNo,
            "vehicle_model_type": vehicleModelType
        ]
        return dic
    }

    
    init() {
        vehicleType = 0
        vehicleBrand = ""
        vehicleName = ""
        vehicleNo = ""
        vehicleModelType = ""
        id = ""
        registrationNo = ""
        licenseNo = ""
    }
}
