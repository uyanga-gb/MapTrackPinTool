//
//  LocationTrackerController.swift
//  LocationTracker
//
//  Created by uyanga on 7/15/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import UIKit
// ths is the class that compresses the image
class LocationTrackerController: NSObject {
   // this is a singleton - > read about it
    static let sharedInstance = LocationTrackerController()
//    var imageData: NSData?
    
    func createThumbnail(image: UIImage) -> UIImage {
        
        var compressedData: NSData { return UIImageJPEGRepresentation(image, 0.25)}
        var compressedImage: UIImage = UIImage(data: compressedData)!
        
        let size = CGSizeApplyAffineTransform(compressedImage.size, CGAffineTransformMakeScale(0.2, 0.2))
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size:size))
        
        let scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
    func getFulllsizeImage() {
        
    }
    
}
