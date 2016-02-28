//
//  RSAllContentsVCextension.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 28/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//
import UIKit
import CoreData
import CoreLocation

extension RSAllContentsVC {
    // MARK: CoreData
    func readCoreData() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedContext)
        do {
            let fetchedEntities = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
            self.contents.removeAll()
            //            for fetchedEntity in fetchedEntities {
            self.contents.append(Content(id: "666", header: "", text: "", imgPreviewUrl: "", imgUrl: "", link: "", shortText: "", status: "1", type: "0", typeString: "0", datePublish: "0", dateChange: "0"))
            
            //        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            //            // handle failed conversion
            //            print("jpg error")
            //            return
            //        }
            
            
            //                    (label: fetchedEntity.valueForKey("label") as! String, author: fetchedEntity.valueForKey("author") as! String, id: fetchedEntity.valueForKey("id") as! Int))
            //            }
        } catch {
            print(error) }
    }
    //    func writeCoreData() {
    //        deleteCoreData()
    //        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    //        let songEntity = NSEntityDescription.entityForName("Song", inManagedObjectContext: managedContext)
    //        for songsItem in tempSongs {
    //            let currentD = NSManagedObject(entity: songEntity!, insertIntoManagedObjectContext: managedContext)
    //            currentD.setValue( NSNumber.IntegerLiteralType(songsItem.id), forKey: "id")
    //            currentD.setValue(songsItem.author, forKey: "author")
    //            currentD.setValue(songsItem.label, forKey: "label")
    //        }
    //        do { try managedContext.save() }
    //        catch { print("Could not save \(error)") }
    //    }
    //    func deleteCoreData() {
    //        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    //        let request = NSFetchRequest()
    //        request.entity = NSEntityDescription.entityForName("Song", inManagedObjectContext: managedContext)
    //        do {
    //            let fetchedEntities = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
    //            for entity in fetchedEntities { managedContext.deleteObject(entity) }
    //            try managedContext.save()
    //        } catch { print(error) }
    //    }
    // MARK: CoreLocation
    func askLocationPermission() {
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()//.startUpdatingLocation()
        let i = 0
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("status has changed: \(status.rawValue)")
        manager.location?.coordinate.latitude
        if status.rawValue == 2 {
            self.locationManager.requestWhenInUseAuthorization()
        }
        checkAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation : CLLocation = locations.last!
        print("locations")
        print("locations count:",locations.count )
        print(currentLocation.coordinate.latitude)
        print(currentLocation.coordinate.longitude)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("toLocation")
        let currentLocation : CLLocation = newLocation
        print(currentLocation.coordinate.latitude)
        print(currentLocation.coordinate.longitude)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        print("pause")
        checkAuthorization()
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        print("resume")
        checkAuthorization()
    }
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("ERROR: didFinishDeferredUpdatesWithError: \(error)")
    }
    
    func checkAuthorization() {
        //        // Check if the user allowed authorization
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse        {
            print(locationManager.location)
        }  else {
            print("no location :(")
            
            locationManager.requestWhenInUseAuthorization()
        }
    }
}