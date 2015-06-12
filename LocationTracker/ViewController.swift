//
//  ViewController.swift
//  LocationTracker
//
//  Created by uyanga on 5/24/15.
//  Copyright (c) 2015 uyanga. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MobileCoreServices
import AVFoundation
import Photos

enum MapType: Int {
    case Standard = 0
    case Hybrid
    case Satellite
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ViewControllerDelegate {

    var pins = [Pin]()
    var pinAll = Pin.all()
    var new_title = ""
    var new_subtitle = ""
    var controller: UIImagePickerController?
    var imageView = UIImageView(frame: CGRectMake(20, 20, 50, 50))
    var photo = UIImage?()
    var currentAnnotation = MKAnnotation?()
//    let server = Requests(server: "http://192.168.1.95:8000/")
    var pinToAdd: Pin?
    weak var delegate: ViewControllerDelegate?
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBAction func dropPinPressed(sender: UIButton) {
        photoPressed()
        titleText.hidden = false
        subtitleText.hidden = false
        addTitleOutlet.hidden = false
        addSubtitleOutlet.hidden = false
    }
    @IBAction func titleButtonPressed(sender: UIButton) {
        new_title = titleText.text
        titleText.hidden = true
        sender.hidden = true
        titleText.text = ""
    }
    @IBAction func subtitleButtonPressed(sender: UIButton) {
        new_subtitle = subtitleText.text
        subtitleText.hidden = true
        sender.hidden = true
        subtitleText.text = ""
    }
    @IBOutlet weak var subtitleText: UITextField!
    @IBOutlet weak var addTitleOutlet: UIButton!
    @IBOutlet weak var addSubtitleOutlet: UIButton!
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var theLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var myPhotos: [String] = []
    var userLocationUpdated = false
    var lastLocationError: NSError?
    var location: CLLocation?
    var newRegion: MKCoordinateRegion?
    var myPins: NSObject?
    
    @IBAction func mapType(sender: UISegmentedControl) {
        let mapType = MapType(rawValue: segmentedControl.selectedSegmentIndex)
        switch (mapType!) {
        case .Standard:
            theMap.mapType = MKMapType.Standard
        case .Hybrid:
            theMap.mapType = MKMapType.Hybrid
        case .Satellite:
            theMap.mapType = MKMapType.Satellite
        default:
            break
        }
    }
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
    
//        if let urlToReq = NSURL(string: "http://192.168.1.95:8000/pins") {
//            if let data = NSData(contentsOfURL: urlToReq) {
////                println("data \(data)")
//                let arrOfPins = parseJSON(data)
        
//                println(arrOfPins)
        
//                for pin in arrOfPins {
//                    let object = pin as! NSDictionary
//                    
//                    let pinTitle = object["title"] as! String
//                    let pinSubtitle = object["subtitle"] as! String
//                    let pinImage = object["image"] as! String
//                    let pinLat = object["lat"] as! Int
//                    let pinLong = object["long"] as! Int
//                    
                    //                        let pin = Pin(title: pinTitle, subtitle: pinSubtitle, image: pinImage, lat: pinLat, long: pinLong)
                    //                        pins.append(pin)
//                }
//            }
//        }
    
//        server.getRequestWithReturnedArray(relativeUrl: "/pins") {
//            data in
//            println(data)
//        }
        
//    }
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        stopLocationManager()
        if userLocationUpdated {
            stopLocationManager()
        }
        else {
            location = nil
            lastLocationError = nil
        }
//        updateUI()
        
        theMap.delegate = self
        theMap.showsUserLocation = true
//        var doubleClick = UITapGestureRecognizer(target: theMap.showsUserLocation, action: "userLocationSelected")
//        doubleClick.numberOfTapsRequired = 2
//        theMap.addGestureRecognizer(doubleClick)
        addTitleOutlet.hidden = true
        addSubtitleOutlet.hidden = true
//        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        titleText.hidden = true
        subtitleText.hidden = true
        
        longPressRecogniser.minimumPressDuration = 1.0
        theMap.addGestureRecognizer(longPressRecogniser)
        
        let tapper = UITapGestureRecognizer(target: self.view, action:Selector("endEditing:"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);
    }
//    func parseJSON(inputData: NSData) -> NSArray {
//        var error: NSError?
//        var arrOfObjects = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSArray
//        return arrOfObjects
//    }
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
//        userLocationUpdated = true
        theLabel.text = "\(locations[0])"
        myLocations.append(locations[0] as! CLLocation)
        let newLocation = locations.last as! CLLocation
        let spanX = 0.01
        let spanY = 0.01
        newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion!, animated: true)
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            theMap.addOverlay(polyline)
        }
    }
    func viewController(controller: ViewController, didFinishAddingPin pin: Pin) {
        dismissViewControllerAnimated(true, completion: nil)
        pinAll = Pin.all()
    }

    func stopLocationManager() {
        if userLocationUpdated {
            manager.stopUpdatingLocation()
            manager.delegate = nil
            userLocationUpdated = false
        }
    }
    func startUpdatingLocation() {
        
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        var myPhoto = UIImageView()
        if !(annotation is MKPointAnnotation)
        {
            return nil
        }
        let reuseId = "test"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
//        anView.frameForAlignmentRect(CGRectMake(10, 10, 50, 50))
        if anView == nil
        {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            anView!.canShowCallout = true
            anView!.image = imageView.image
            //            anView!.leftCalloutAccessoryView = imageView
            anView!.calloutOffset = CGPoint(x: -5, y: 5)
            anView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.Custom) as! UIView
            var delete = UIImageView(frame: CGRectMake(0, 0, 40, 40))
            delete.image = UIImage(named: "delete")
            anView!.rightCalloutAccessoryView.frame = CGRectMake(0, 0, 40, 40)
            anView!.rightCalloutAccessoryView.tintColor = UIColor.redColor()
            anView!.rightCalloutAccessoryView.addSubview(delete)
        }
        else
        {
            anView!.annotation = annotation
        }
            return anView
    }
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if (control as? UIButton)?.buttonType == UIButtonType.Custom {
//            currentAnnotation = view.annotation
            
            theMap.deselectAnnotation(view.annotation, animated: false)
           
            var refreshAlert = UIAlertController(title: "Delete annotations", message: "All data will be lost!", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Selected", style: .Default, handler: { (action: UIAlertAction!) in
                self.theMap.removeAnnotation(view.annotation as! MKPointAnnotation)
          
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "All", style: .Default, handler: { (action: UIAlertAction!) in
                let annotationsToRemove = self.theMap.annotations.filter { $0 !== self.theMap.userLocation }
                self.theMap.removeAnnotations(annotationsToRemove)
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
//        dropPinPressed(sender: UIGestureRecognizer)
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.theMap)
        let touchMapCoordinate = theMap.convertPoint(touchPoint, toCoordinateFromView: theMap)
        
        lastPhoto()
        var annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
//        newRegion = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpanMake(500, 500))
//        theMap.setRegion(newRegion!, animated: true)
        annotation.title = new_title
        annotation.subtitle = new_subtitle
       
        println(annotation.coordinate.latitude)
        println(annotation.coordinate.longitude)
//        var location = CLLocationCoordinate2D(
//            latitude: annotation.coordinate.latitude,
//            longitude: annotation.coordinate.longitude
//        )
        mapView(theMap, viewForAnnotation: annotation)
        let newPin = Pin(pinTitle: annotation.title, pinSubtitle: annotation.subtitle) //change from String to Item type to confrom to protocol with db
//            println(newPin.title)
            newPin.save()
        //save new item to db
//            delegate?.viewController(self, didFinishAddingPin: newPin)
    


//            if let urlToReq = NSURL(string: "http://192.168.1.95:8000/pins") {
//                var request: NSMutableURLRequest = NSMutableURLRequest(URL: urlToReq)
//                request.HTTPMethod = "POST"
//                var bodyData = "name=\(annotation.title)&subtitle=\(annotation.subtitle)&image=\(annotation.subtitle)&lat=\(annotation.coordinate.latitude)&long=\(annotation.coordinate.longitude)"
//                println(bodyData)
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
//                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
//                    (response, data, error) in
//                    println(NSString(data: data, encoding: NSUTF8StringEncoding))
//                }
//            }
        theMap.addAnnotation(annotation)
//        delegate?.mainViewController(self, didFinishAddingPin: myAnnotations)
    }

//    func userLocationSelected(getstureRecognizer : UIGestureRecognizer) {
//        if getstureRecognizer.state != .Began { return }
//        let touchLocation = getstureRecognizer.locationInView(self.theMap)
//        let touchMapCoordinateUser = theMap.convertPoint(touchLocation, toCoordinateFromView: theMap)
//        var annotation = MKPointAnnotation()
//        annotation.coordinate = touchMapCoordinateUser
//        annotation.title = new_title
//        annotation.subtitle = new_subtitle
//        
//        println(annotation.coordinate.latitude)
//        println(annotation.coordinate.longitude)
//        //        var location = CLLocationCoordinate2D(
//        //            latitude: annotation.coordinate.latitude,
//        //            longitude: annotation.coordinate.longitude
//        //        )
//        lastPhoto()
//        mapView(theMap, viewForAnnotation: annotation)
//        theMap.addAnnotation(annotation)
//    }
    @IBAction func photoPressed() {
        if isCameraAvailable() && doesCameraSupportTakingPhotos(){
            controller = UIImagePickerController()
            if let theController = controller{
                theController.sourceType = .Camera
                theController.mediaTypes = [kUTTypeImage as! String]
                theController.allowsEditing = true
                theController.delegate = self
                presentViewController(theController, animated: true, completion: nil)
            }
        }
         else {
            println("Camera is not available")
        }
    }
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]

            if let type:AnyObject = mediaType{
                if type is String{
                    let stringType = type as! String
                    if stringType == kUTTypeMovie as! String{
                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                        if let url = urlOfVideo{
                            println("Video URL = \(url)")
                        }
                    }
                    else if stringType == kUTTypeImage as! String{
                        let metadata = info[UIImagePickerControllerMediaMetadata]
                            as? NSDictionary
                        if let theMetaData = metadata{
                            let image = info[UIImagePickerControllerOriginalImage]
                                as? UIImage
                            var imageToSave: UIImage = image!
                            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
//                            self.savedImageAlert()
                            
                            if var theImage = image{
                                var imageData = UIImagePNGRepresentation(theImage)
                                var base64String = imageData.base64EncodedStringWithOptions(.allZeros)
                                myPhotos.append(base64String)
//                                photo = snapShot.image!
//                               imageView.image = theImage
//                                snapShot.image = imageView.image
                            }
                        }
                    }
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: nil)
    }
//    func savedImageAlert()
//    {
//        var alert:UIAlertView = UIAlertView()
//        alert.title = "Saved!"
//        alert.message = "Your picture was saved to Camera Roll"
//        alert.delegate = self
//        alert.addButtonWithTitle("Ok")
//        alert.show()
//    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("Picker was cancelled")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    func doesCameraSupportTakingPhotos() -> Bool{
        return cameraSupportsMedia (kUTTypeImage as! String, sourceType: .Camera)
    }
    func cameraSupportsMedia(mediaType: String,
        sourceType: UIImagePickerControllerSourceType) -> Bool{
            
            let availableMediaTypes =
            UIImagePickerController.availableMediaTypesForSourceType(sourceType) as!
                [String]?
            
            if let types = availableMediaTypes{
                for type in types{
                    if type == mediaType{
                        return true
                    }
                }
            }
            return false
    }
    func lastPhoto() {
        var fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        if (fetchResult.lastObject != nil) {
            var lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: self.imageView.bounds.size, contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions(), resultHandler: { (result, info) -> Void in
                self.imageView.image = result
            })
        }
    }
}
