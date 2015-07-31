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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
    var pin = [Pin]()
    var pinAll = Pin.all()
    var new_title = ""
    var new_subtitle = ""
    var controller: UIImagePickerController?
    var imageView = UIImageView(frame: CGRectMake(20, 20, 50, 50))
    weak var delegate: ViewControllerDelegate?
    
//    let server = Requests(server: "http://192.168.1.95:8000/") //used for connection with node.js server
    
    
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
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var pinPhoto = ""
    var userLocationUpdated = false
    var lastLocationError: NSError?
    var location: CLLocation?
    var newRegion: MKCoordinateRegion?
    var polyline: MKPolyline?

    override func viewDidAppear(animated: Bool) {
    
            self.showPinsCenter()
        theMap.showAnnotations(pinAll, animated: true)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        var trackAlert = UIAlertController(title: "Location Tracking", message: "Do you want to track your route?", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        trackAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
//            
//            self.createPolyline()
//        }))
//        trackAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
////            self.removePolyline(self.polyline!)
//        }))
//        presentViewController(trackAlert, animated: true, completion: nil)

        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        theMap.zoomEnabled = true
        theMap.scrollEnabled = true

        stopLocationManager()
        if userLocationUpdated {
            stopLocationManager()
        }
        else {
            location = nil
            lastLocationError = nil
        }

        theMap.delegate = self
        theMap.showsUserLocation = true
        addTitleOutlet.hidden = true
        addSubtitleOutlet.hidden = true
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        titleText.hidden = true
        subtitleText.hidden = true
        
        longPressRecogniser.minimumPressDuration = 1.0
        theMap.addGestureRecognizer(longPressRecogniser)
        let tapper = UITapGestureRecognizer(target: self.view, action:Selector("endEditing:"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);
        
//        var doubleClick = UITapGestureRecognizer(target: theMap.showsUserLocation, action: "userLocationSelected")
//        doubleClick.numberOfTapsRequired = 2
//        theMap.addGestureRecognizer(doubleClick)
//        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        
    }
    
    func showPinsCenter() {
        var allLatArray : [CLLocationDegrees] = []
        var allLongArray : [CLLocationDegrees] = []

        for pin in pinAll {
            allLatArray.append(pin.latitude)
            allLongArray.append(pin.longitude)
        }
        allLatArray.sort() {
            $0 < $1
        }
       
        allLongArray.sort() {
            $0 < $1
        }

        var smallestLat: Double = allLatArray[0]
        var smallestLong: Double = allLongArray[0]

        var biggestLat: Double = allLatArray[allLatArray.count-1]
        var biggestLong: Double = allLongArray[allLongArray.count-1]
        
        var midPoint : CLLocationCoordinate2D = CLLocationCoordinate2DMake((biggestLat + smallestLat)/2, (biggestLong + smallestLong)/2)
        
        var radius : MKCoordinateSpan = MKCoordinateSpanMake(biggestLat - smallestLat, biggestLong - smallestLong)
        var region : MKCoordinateRegion = MKCoordinateRegionMake(midPoint, radius)
       
        self.theMap.setRegion(region, animated: true)
    }

    func handleWaypoints(waypoints: [Pin]) {
        theMap.addAnnotations(waypoints)
        theMap.showAnnotations(waypoints, animated: true)
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        theLabel.text = "\(locations[0])"
        myLocations.append(locations[0] as! CLLocation)
        let newLocation = locations.last as! CLLocation

//        let spanX = 0.10
//        let spanY = 0.10
//        newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
//        newRegion = MKCoordinateRegionMakeWithDistance(theMap.userLocation.coordinate, 2000, 2000)
//        theMap.setRegion(newRegion!, animated: true)
//        theMap.centerCoordinate = newLocation.coordinate
//        request.region = newRegion!
//        let search = MKLocalSearch(request: request)
//        search.startWithCompletionHandler {
//            (MKLocalSearchResponse, NSError) -> Void in
//            
//        }
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            polyline = MKPolyline(coordinates: &a, count: a.count)
            theMap.addOverlay(polyline)
        }
    }
//    func createPolyline() {
//        if (myLocations.count > 1){
//            var sourceIndex = myLocations.count - 1
//            var destinationIndex = myLocations.count - 2
//            
//            let c1 = myLocations[sourceIndex].coordinate
//            let c2 = myLocations[destinationIndex].coordinate
//            var a = [c1, c2]
//            polyline = MKPolyline(coordinates: &a, count: a.count)
////            createPolyline(polyline!)
////            removePolyline(polyline!)
//            theMap.addOverlay(polyline)
//        }
//    }
//    func removePolyline(polyline: MKPolyline) {
//        theMap.removeOverlay(polyline)
//    }


    func stopLocationManager() {
        if userLocationUpdated {
            manager.stopUpdatingLocation()
            manager.delegate = nil
            userLocationUpdated = false
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        var myPhoto = UIImageView()
        if (annotation is MKUserLocation)
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
        } else {
                anView!.annotation = annotation
        }
            //            anView!.leftCalloutAccessoryView = imageView
            anView!.calloutOffset = CGPoint(x: -5, y: 5)
       
            anView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.Custom) as! UIView
            var reSizeDelete = UIImageView(frame: CGRectMake(0, 0, 40, 40))
            var delete = UIImage(named: "delete")
            var compDelete = LocationTrackerController.sharedInstance.createThumbnail(delete!)
            reSizeDelete.image = compDelete
        
//                    var decodedData = NSData(base64EncodedString: pinImage.photo!, options: NSDataBase64DecodingOptions(rawValue: 0))
//                    var decodedImage = UIImage(data: decodedData!)
                    //                pinImage = decodedImage!
                    //                pinImage.transform = CGAffineTransformMakeRotation((90.0 * CGFloat(M_PI)) / 180.0)
//                    anView!.image = decodedImage
              
        if let waypoint = annotation as? Pin {
            if waypoint.photo != nil {
                anView!.image = waypoint.photo
                anView!.bounds.size.height = 50.0
                anView!.bounds.size.width = 40.0
                anView!.centerOffset = CGPointMake(0, 20)
            } else {
                anView!.image = UIImage(named: "camera")
                anView!.bounds.size.height = 50.0
                anView!.bounds.size.width = 40.0
                anView!.centerOffset = CGPointMake(0, 20)
            }
            
        }
            anView!.rightCalloutAccessoryView.frame = CGRectMake(0, 0, 40, 40)
            anView!.rightCalloutAccessoryView.backgroundColor = UIColor.whiteColor()
            anView!.rightCalloutAccessoryView.addSubview(reSizeDelete)
        
            anView!.leftCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.System) as! UIView
            anView.leftCalloutAccessoryView.frame = CGRectMake(0, 0, 40, 40)
            anView!.leftCalloutAccessoryView.backgroundColor = UIColor.whiteColor()
            var reSizeZoom = UIImageView(frame: CGRectMake(0, 0, 40, 40))
            var zoomIn = UIImage(named: "zoomIn")
            var compZoom = LocationTrackerController.sharedInstance.createThumbnail(zoomIn!)
            reSizeZoom.image = compZoom
            anView!.leftCalloutAccessoryView.addSubview(reSizeZoom)
      //  }
        return anView
    }
//    func saveImageInPin() {
//        if let image = imageView.image {
//            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
//             let fileManager = NSFileManager()
//                if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL {
//                   let unique = NSDate.timeIntervalSinceReferenceDate()
//                    let url = docsDir.URLByAppendingPathComponent("\(unique).jpg")
//                    if let path = url.absoluteString {
//                        if imageData.writeToURL(url, atomically: true){
////                            pinWithImage.photo = path
//
//                        }
//                        
//                    }
//                }
//            }
//        }
//    }
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if (control as? UIButton)?.buttonType == UIButtonType.Custom {
            theMap.deselectAnnotation(view.annotation, animated: false)
            var refreshAlert = UIAlertController(title: "Delete annotations", message: "All pins will only desappear from the Map View!", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Selected", style: .Default, handler: { (action: UIAlertAction!) in
                self.theMap.removeAnnotation(view.annotation as MKAnnotation)
          
            }))
            refreshAlert.addAction(UIAlertAction(title: "All", style: .Default, handler: { (action: UIAlertAction!) in
                let annotationsToRemove = self.theMap.annotations.filter { $0 !== self.theMap.userLocation }
                self.theMap.removeAnnotations(annotationsToRemove)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                self.theMap.deselectAnnotation(view.annotation, animated: false)
            }))

            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else {
            performSegueWithIdentifier("ShowImageSegue", sender: view)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImageSegue" {
            if let waypoint = (sender as? MKAnnotationView) {
                 let ivc = segue.destinationViewController as? ImageViewController
                   var selectedImage = waypoint.image
                    ivc!.pinImage = selectedImage
            }
        }
    }

    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
//        dropPinPressed(sender: UIGestureRecognizer)
        if getstureRecognizer.state != .Began { return }
            
            let touchPoint = getstureRecognizer.locationInView(self.theMap)
            let touchMapCoordinate = theMap.convertPoint(touchPoint, toCoordinateFromView: theMap)
            var compImage = LocationTrackerController.sharedInstance.createThumbnail(imageView.image!)
            let waypoint = Pin(title: new_title, subtitle: new_subtitle, coordinate: touchMapCoordinate, photo: compImage)
            theMap.addAnnotation(waypoint)
        
            let newPin = Pin(title: waypoint.title, subtitle: waypoint.subtitle, coordinate: waypoint.coordinate, photo: compImage)
            newPin.save()
    }

    //----------------------------------------------------------------------------------
    //Taking a photo and other photo related functions starts here
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
                            if var theImage = image{
                                var imageData = UIImagePNGRepresentation(theImage)
                                imageView.image = theImage
                                
//                                saveImageInPin()
                                
//                                var base64String = imageData.base64EncodedStringWithOptions(.allZeros)
//                                myPhotos.append(base64String)
//                                pinPhoto = base64String
//                                photo = snapShot.image!
//                                snapShot.image = imageView.image
                            }
                        }
                    }
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: nil)
    }

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
//    func lastPhoto() {
//        var fetchOptions: PHFetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
//        if (fetchResult.lastObject != nil) {
//            var lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
//            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: self.imageView.bounds.size, contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions(), resultHandler: { (result, info) -> Void in
////                self.imageView.image = result
//            })
//        }
//    }
    
    //photo related functions ends here
    //----------------------------------------------------------------------------------
    // Clicking on the current location blue dot and drop pin test starts here
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
    // // Clicking on the current location blue dot and drop pin test ends here
    //--------------------------------------------------------------------------------------
    // MEAN Stack related parts start here
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
    //    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MEAN stack related parts end here
}
