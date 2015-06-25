//
//  PinExtension.swift
//  LocationTracker
//
//  Created by uyanga on 6/12/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import MapKit

extension Pin: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)    }
    var title: String! { return objTitle }
    var subtitle: String! { return objSubtitle }
}
