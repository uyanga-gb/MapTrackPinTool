//
//  ViewControllerDelegate.swift
//  LocationTracker
//
//  Created by uyanga on 6/4/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//


import Foundation
protocol ViewControllerDelegate: class {
    func viewController(controller: ViewController, didFinishAddingPin pin: Pin)
   }