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

class Pin: NSObject, NSCoding, MKAnnotation {
    static var key: String = "Pin"
    static var schema: String = "theList"
    var objTitle: String
    var objSubtitle: String
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D
    var photo: UIImage?
    var createdAt: NSDate
    // use this init for creating a new Task
    init(pinTitle: String, pinSubtitle: String, pinLatitude: Double, pinLongitude: Double, coordinate: CLLocationCoordinate2D) {
        self.objTitle = pinTitle
        self.objSubtitle = pinSubtitle
        self.latitude = pinLatitude
        self.longitude = pinLongitude
        self.coordinate = coordinate
        self.createdAt = NSDate()
    }
    // MARK: - NSCoding protocol
    // used for encoding (saving) objects
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objTitle, forKey: "objTitle")
        aCoder.encodeObject(objSubtitle, forKey: "objSubtitle")
        aCoder.encodeObject(latitude, forKey: "latitude")
        aCoder.encodeObject(longitude, forKey: "longitude")
        aCoder.encodeObject(coordinate.latitude, forKey: "CoorLatitude")
        aCoder.encodeObject(coordinate.longitude, forKey: "CoorLongitude")
        aCoder.encodeObject(photo, forKey: "photo")
        aCoder.encodeObject(createdAt, forKey: "createdAt")
    }
    // used for decoding (loading) objects
    required init(coder aDecoder: NSCoder) {
        objTitle = aDecoder.decodeObjectForKey("objTitle") as! String
        objSubtitle = aDecoder.decodeObjectForKey("objSubtitle") as! String
        latitude = aDecoder.decodeObjectForKey("latitude") as! Double
        longitude = aDecoder.decodeObjectForKey("longitude") as! Double
        coordinate = aDecoder.decodeObjectForKey("CoorLatitude") as! CLLocationCoordinate2D
        coordinate = aDecoder.decodeObjectForKey("CoorLongitude") as! CLLocationCoordinate2D
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