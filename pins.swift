//
//  pins.swift
//  LocationTracker
//
//  Created by uyanga on 6/2/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//
import MapKit

class Pin: NSObject, MKAnnotation {
    let title: String
    let subtitle: String
    let image: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, image: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.coordinate = coordinate
        
        super.init()
    }
}