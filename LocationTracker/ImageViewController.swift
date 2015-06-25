//
//  ImageViewController.swift
//  LocationTracker
//
//  Created by uyanga on 6/12/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var pinImage : UIImage?
    var testingText : String = ""
    
    @IBOutlet weak var pinPhoto: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = pinImage
        pinPhoto.image = image
        
    }
}
