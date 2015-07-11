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

class Pin: NSObject, NSCoding {
    static var key: String = "Pin"
    static var schema: String = "theList"
    var objTitle: String
    var objSubtitle: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
//    var coordinate: CLLocationCoordinate2D {
//        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
    var photo: UIImage?
    var createdAt: NSDate
    // use this init for creating a new Task
    init(pinTitle: String, pinSubtitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photo: UIImage) {
        self.objTitle = pinTitle
        self.objSubtitle = pinSubtitle
        self.latitude = latitude
        self.longitude = longitude
//        coordinate = coordinate
        self.photo = photo
        self.createdAt = NSDate()
    }
    // MARK: - NSCoding protocol
    // used for encoding (saving) objects
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objTitle, forKey: "objTitle")
        aCoder.encodeObject(objSubtitle, forKey: "objSubtitle")
        aCoder.encodeObject(latitude, forKey: "latitude")
        aCoder.encodeObject(longitude, forKey: "longitude")
//        aCoder.encodeObject(coordinate.latitude, forKey: "objLatitude")
//        aCoder.encodeObject(coordinate.longitude, forKey: "objLongitude")
        aCoder.encodeObject(photo, forKey: "photo")
        aCoder.encodeObject(createdAt, forKey: "createdAt")
    }
    // used for decoding (loading) objects
    required init(coder aDecoder: NSCoder) {
        objTitle = aDecoder.decodeObjectForKey("objTitle") as! String
        objSubtitle = aDecoder.decodeObjectForKey("objSubtitle") as! String
//        latitude = aDecoder.decodeObjectForKey("latitude") as! Double
//        longitude = aDecoder.decodeObjectForKey("longitude") as! Double
        latitude = aDecoder.decodeObjectForKey("latitude") as! CLLocationDegrees
        longitude = aDecoder.decodeObjectForKey("longitude") as! CLLocationDegrees
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