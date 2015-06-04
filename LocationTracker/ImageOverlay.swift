//
//  ImageOverlay.swift
//  LocationTracker
//
//  Created by uyanga on 5/26/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import UIKit
import MapKit

class ImageOverlay: NSObject, MKOverlay {

    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(map: ViewController) {
        boundingMapRect = MKMapRectMake(100, 100, 100, 100)
        coordinate = map.theMap.userLocation.coordinate
    }
}