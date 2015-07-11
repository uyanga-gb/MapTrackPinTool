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
    
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
//        pins.removeAtIndex(2)
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("PinCell", forIndexPath: indexPath)
        let cell = dequeued as! UITableViewCell
        cell.textLabel?.text = pins[indexPath.row].objTitle
        cell.detailTextLabel?.text = pins[indexPath.row].objSubtitle
        var image : UIImage = UIImage(named: "camera")!
        let photo = pins[indexPath.row].photo
//        if let photo = pins[indexPath.row].photo {
//            let decodedData = NSData(base64EncodedString: photo, options: NSDataBase64DecodingOptions(rawValue: 0))
//            var decodedimage = UIImage(data: decodedData!)
            if let image = photo {
                var image : UIImage = photo!
//                cell.imageView!.transform = CGAffineTransformMakeRotation((90.0 * CGFloat(M_PI)) / 180.0)
                cell.imageView!.image = image
            }
            else {
                cell.imageView!.image = UIImage(named: "camera")
            }
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
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! PinToEditController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.pinToEdit = pins[indexPath.row]
            }
        }
    }
}
