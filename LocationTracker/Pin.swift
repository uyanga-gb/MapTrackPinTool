//
//  Pin.swift
//  LocationTracker
//
//  Created by uyanga on 6/3/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import Foundation

class Pin: NSObject, NSCoding {
    static var key: String = "Pins"
    static var schema: String = "theList"
    var title: String
    var subtitle: String
    var createdAt: NSDate
    // use this init for creating a new Task
    init(pinTitle: String, pinSubtitle: String) {
        title = pinTitle
        subtitle = pinSubtitle
        createdAt = NSDate()
    }
    // MARK: - NSCoding protocol
    // used for encoding (saving) objects
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(subtitle, forKey: "subtitle")
        aCoder.encodeObject(createdAt, forKey: "createdAt")
    }
    // used for decoding (loading) objects
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        subtitle = aDecoder.decodeObjectForKey("subtitle") as! String
        createdAt = aDecoder.decodeObjectForKey("createdAt") as! NSDate
        super.init()
    }
    // MARK: - Queries
    static func all() -> [Pin] {
        var pins = [Pin]()
        
        let path = Database.dataFilePath("theList")
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                pins = unarchiver.decodeObjectForKey(Pin.key) as! [Pin]
                unarchiver.finishDecoding()
                println(pins)
            }
        }
        println(pins[1].subtitle)
        return pins
    }
    func save() {
        var pinsFromStorage = Pin.all()
        var exists = false
        for var i = 0; i < pinsFromStorage.count; ++i {
            println("cheching exist true")
            if pinsFromStorage[i].createdAt == self.createdAt {
                pinsFromStorage[i] = self
                exists = true
            }
        }
        if !exists {
            println("if not exist")
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