//
//  AppNavigation.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import SwiftLocation


class AppNavigation: UINavigationController {
    
    private var request: LocationRequest!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        LocationManager.shared.requireUserAuthorization(.always)
        
        request = LocationManager.shared.locateFromGPS(.continous, accuracy: .city) { result in
          switch result {
          case .failure( _): break
            //  self.showAlert("","Please enable your location service and retry")
            case .success(let location):
                UserDefaults.latitude = location.coordinate.latitude
                UserDefaults.longitude = location.coordinate.longitude
          }
        }
        request.dataFrequency = .fixed(minInterval: 40, minDistance: 100) // minimum 40 seconds & 100 meters since the last update.
        
        request.start()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationBar.isHidden = true
        self.title = "Memu"
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        request.stop()
    }
}
