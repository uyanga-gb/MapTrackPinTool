//
//  Pin.swift
//  LocationTracker
//
//  Created by uyanga on 6/3/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Pin: NSObject, MKAnnotation, NSCoding  {
    static var key: String = "Pin"
    static var schema: String = "theList"
    var title: String
    var subtitle: String
    
    var coordinate: CLLocationCoordinate2D // need this for MKAnnotation
    var latitude : CLLocationDegrees
    var longitude : CLLocationDegrees
    var photo: UIImage?
    var createdAt: NSDate
    
    // use this init for creating a new Task
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, photo: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.longitude = self.coordinate.longitude
        self.latitude = self.coordinate.latitude
        self.photo = photo
        self.createdAt = NSDate()
    }
    // MARK: - NSCoding protocol
    // used for encoding (saving) objects
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(subtitle, forKey: "subtitle")
        //aCoder.encodeObject(coordinate, forKey: "coordinate")
        aCoder.encodeObject(coordinate.latitude, forKey: "latitude")
        aCoder.encodeObject(coordinate.longitude, forKey: "longitude")
        aCoder.encodeObject(photo, forKey: "photo")
        aCoder.encodeObject(createdAt, forKey: "createdAt")
    }
    // used for decoding (loading) objects
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        subtitle = aDecoder.decodeObjectForKey("subtitle") as! String
        latitude = aDecoder.decodeObjectForKey("latitude") as! Double
        longitude = aDecoder.decodeObjectForKey("longitude") as! Double
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        photo = aDecoder.decodeObjectForKey("photo") as? UIImage
        createdAt = aDecoder.decodeObjectForKey("createdAt") as! NSDate
        super.init()
    }
    // MARK: - Queries
    static func all() -> [Pin] {
        var pin = [Pin]()
        let path = Database.dataFilePath("theList")
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                pin = unarchiver.decodeObjectForKey(Pin.key) as! [Pin]
                unarchiver.finishDecoding()
            }
        }
        return pin
    }
    func save() {
        var pinsFromStorage = Pin.all()
        var exists = false
        for var i = 0; i < pinsFromStorage.count; ++i {
            if pinsFromStorage[i].createdAt == self.createdAt {
                pinsFromStorage[i] = self
                exists = true
            }
        }
        if !exists {
            pinsFromStorage.append(self)
        }
        Database.save(pinsFromStorage, toSchema: Pin.schema, forKey: Pin.key)
    }
    func destroy() {
        var pinsFromStorage = Pin.all()
        for var i = 0; i < pinsFromStorage.count; ++i {
            if pinsFromStorage[i].createdAt == self.createdAt {
                pinsFromStorage.removeAtIndex(i)
            }
        }
        Database.save(pinsFromStorage, toSchema: Pin.schema, forKey: Pin.key)
    }
}