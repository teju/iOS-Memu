//
//  CustomPointAnnotation.swift
//  Memu
//
//  Created by Tejaswini N on 23/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftLocation
import Mapbox

class CustomPointAnnotation : NSObject, MGLAnnotation {
    // As a reimplementation of the MGLAnnotation protocol, we have to add mutable coordinate and (sub)title properties ourselves.
    var coordinate: CLLocationCoordinate2D
    

    // Custom properties that we will use to customize the annotation's image.
    var image: UIImage?
    var reuseIdentifier: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
    }
}
