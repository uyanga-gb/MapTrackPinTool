//
//  PinsController.swift
//  LocationTracker
//
//  Created by uyanga on 6/3/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import UIKit

class PinsViewController: UITableViewController, CancelButtonDelegate, PinControllerDelegate {
    var pins = Pin.all()
    
    weak var pinControllerDelegate : PinControllerDelegate?
//    weak var cancelButtonDelegate: CancelButtonDelegate?
    var pinToEdit: Pin?
//    var pinToEdit: Pin?
    
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        pins = Pin.all()
//        println(pins)

        tableView.reloadData()
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        println(pins)
        // dequeue the cell from our storyboard
        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("PinCell", forIndexPath: indexPath)
        // since the method returns an AnyObject, we have to cast it to UITableViewCell
        let cell = dequeued as! UITableViewCell
        // if the cell has a text label, set it to the model that is corresponding to the row in array
        cell.textLabel?.text = pins[indexPath.row].title
        cell.textLabel?.text = pins[indexPath.row].subtitle
        var image : UIImage = UIImage(named: "camera")!
        println("The loaded image: \(image)")
        cell.imageView!.image = image

        
        // return cell so that Table View knows what to draw in each row
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        pins.removeAtIndex(indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        Database.save(pins, toSchema: Pin.schema, forKey: Pin.key)
    }
   
       func pinController(controller: PinToEditController, didFinishEditingPin pin: Pin) {
        dismissViewControllerAnimated(true, completion: nil)
        pins = Pin.all()
        tableView.reloadData()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("EditPin", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditPin" {
            println("edit mission clicked")
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! PinToEditController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                println(pins[indexPath.row])
//                controller.delegate = self
                controller.pinToEdit = pins[indexPath.row]
            }
        }
    }
}
