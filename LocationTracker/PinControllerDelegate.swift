//
//  MainControllerDelegate.swift
//  LocationTracker
//
//  Created by uyanga on 6/3/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//


import Foundation
protocol PinControllerDelegate: class {
    func pinController(controller: PinToEditController, didFinishEditingPin pin: Pin)
}