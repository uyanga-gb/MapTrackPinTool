//
//  PinToEditController.swift
//  LocationTracker
//
//  Created by uyanga on 6/11/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import UIKit

class PinToEditController: UITableViewController, UITextFieldDelegate {
    
    weak var cancelButtonDelegate: CancelButtonDelegate?
    var pinToEdit: Pin?
    weak var delegate: PinControllerDelegate?
    
    @IBAction func cancelBarButtonPressed(sender: UIBarButtonItem) {
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    @IBOutlet weak var newPinTextField: UITextField!
    @IBOutlet weak var txtTest: UITextField! = nil
    
    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
        if let pin = pinToEdit {
            pin.title = newPinTextField.text
            pin.save()
            delegate?.pinController(self, didFinishEditingPin: pin)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        txtTest.delegate = self
        let tapper = UITapGestureRecognizer(target: self.view, action:Selector("endEditing:"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);
        
        if let pin = pinToEdit {
            newPinTextField.text = pin.title
        }
    }
    func textFieldShouldReturn(newPinTestField: UITextField) -> Bool {
        newPinTextField.resignFirstResponder()
        return true
    }
}

