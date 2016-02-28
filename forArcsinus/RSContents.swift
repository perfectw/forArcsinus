//
//  RSContentsHTML.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 28/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import CoreData



class Contents: NSObject, CLLocationManagerDelegate {
    static let shared = Contents()
    
    // MARK: LocationManager
    let locationManager = CLLocationManager()
    private override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getContentAgain:", name: RSGetContentAgain, object: nil)
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse:
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            if Reachability.isConnectedToNetwork() == true {
                //if got UID
                if (self.RSUID != nil) {
                    self.postUID()
                } else  { self.postAIUID() }
            } else {
                // for offline 
                self.readCoreData()
                NSNotificationCenter.defaultCenter().postNotificationName(RSOffline, object: self)
            }
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            NSNotificationCenter.defaultCenter().postNotificationName(RSOpenSettingsURL, object: self)
        }
    }
    
    // if ALLContents view try refresh
    func getContentAgain(notification: NSNotification) {
        if Reachability.isConnectedToNetwork() == true {
            //if got UID
            if (self.RSUID != nil) {
                self.postUID()
            } else  { self.postAIUID() }
        } else {
            // for offline
            self.readCoreData()
            NSNotificationCenter.defaultCenter().postNotificationName(RSOffline, object: self)
        }
    }
    
    // MARK: HTML
    private var RSUID : String! {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("RSUID") as! String?
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "RSUID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private func postAIUID() {
        let parameters = [
            "app_key" : "04f0f542ea27a58461a44fbd75a89b30",
            "package_name" : "ru.arcsinus.SalesBlast",
            "app_version" : "1.1.0",
            "latitude" : String(locationManager.location!.coordinate.latitude),
            "longitude" : String(locationManager.location!.coordinate.longitude),
            "devicetype" : "0",
            "deviceversion": UIDevice.currentDevice().systemVersion,
            "devicemodel" : UIDevice.currentDevice().model,
            "screenwidth" : String(UIScreen.mainScreen().bounds.width),
            "screenheight" : String(UIScreen.mainScreen().bounds.height),
            "aiuid" : UIDevice.currentDevice().identifierForVendor!.UUIDString ]
        Alamofire.request(.POST, "http://service-retailmob.rhcloud.com/api/v1/mobclient/register", parameters: parameters).responseJSON { response in
            if let jsonData = response.data {
                let json = JSON(data: jsonData)
                print(json)
                // if OK
                if json["status"].int == 0 {
                    self.RSUID = json["data"]["UID"].string
                    self.postUID()
                }
            }
        }
    }
    
    private func postUID() {
        let parameters = [
            "app_key" : "04f0f542ea27a58461a44fbd75a89b30",
            "package_name" : "ru.arcsinus.SalesBlast",
            "app_version" : "1.2.0",
            "latitude" : String(locationManager.location!.coordinate.latitude),
            "longitude" : String(locationManager.location!.coordinate.longitude),
            "devicetype" : "0",
            "deviceversion": UIDevice.currentDevice().systemVersion,
            "devicemodel" : UIDevice.currentDevice().model,
            "screenwidth" : String(UIScreen.mainScreen().bounds.width),
            "screenheight" : String(UIScreen.mainScreen().bounds.height),
            "UID" : self.RSUID!,
            "last_session_datetime" : "0",
            "content_type_id" : "0",
            "from_id" : "0",
            "max" : "100" ]
        Alamofire.request(.POST, "http://service-retailmob.rhcloud.com/api/v1/mobclient/getContent", parameters: parameters).responseJSON { response in
            if let dummyData = response.data {
                // remove old data
                self.array.removeAll()
                let dummyJSON = JSON(data: dummyData)
                let contentJSON = dummyJSON["data"]["content"]
                for (_, subJSON) in contentJSON {
//                    print(subJSON)
                    let id = subJSON["id"].stringValue
                    let header = subJSON["header"].stringValue
                    let text = subJSON["full_text"].stringValue
                    let imgPreviewUrl = subJSON["img_preview_url"].stringValue
                    let imgUrl = "http://service-retailmob.rhcloud.com/images/105/content/107/image/1.png"//subJSON["img_url"].stringValue
                    let link = subJSON["link"].stringValue
                    let shortText = subJSON["short_text"].stringValue
                    let type = subJSON["content_type_id"].stringValue
                    let datePublish = subJSON["publish_time"].stringValue
                    self.array.append(Content(id: id, header: header, text: text, imgPreviewUrl: imgPreviewUrl, imgUrl: imgUrl, link: link, shortText: shortText, type: type, datePublish: datePublish))
                    self.array.append(Content(id: id, header: header, text: text, imgPreviewUrl: imgPreviewUrl, imgUrl: imgUrl, link: link, shortText: shortText, type: type, datePublish: datePublish))
                }
                // sort and write
                self.arraySort()
                self.writeCoreData()
                NSNotificationCenter.defaultCenter().postNotificationName(RSGotContents, object: self)
            } else { print("No-No-No ;(") }
        }
    }
    
    
    // MARK: Array
    private var array : [Content] = []
    private func arraySort() { self.array.sortInPlace({ $0.datePublish > $1.datePublish }) }
    private func append(content : Content) { self.array.append(content) }
    func count() -> Int { return self.array.count }
    // current
    private var current : Int = 0
    internal func setCurrent(i: Int) { self.current = i }
    func currentImage() -> UIImage? { return self.array[self.current].image }
    func currentImageUrl() -> String? { return self.array[self.current].imgUrl }
    func setCurrentImage(image: UIImage) { self.array[self.current].image = image }
    func currentHeader() -> String { return self.array[self.current].header }
    func currentText() -> String { return self.array[self.current].text }
    func currentLink() -> String { return self.array[self.current].link }
    // atIndex
    func header(i: Int) -> String { return self.array[i].header }
    func shortText(i: Int) -> String { return self.array[i].shortText }
    func imagePreview(i: Int) -> UIImage? { return self.array[i].imagePreview }
    func imagePreviewUrl(i: Int) -> String? { return self.array[i].imgPreviewUrl }
    func setImagePreview(imagePreview: UIImage, index: Int) { self.array[index].imagePreview = imagePreview }
    func typeDate(i: Int) -> (text: String, color: UIColor) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.stringFromDate(self.array[i].datePublish)
        switch self.array[i].type {
        case ContentType.Promotion :
            return("Акция, "+date, UIColor.blueColor())
        case ContentType.Special :
            return("Спецпредложение, "+date, UIColor.redColor())
        default:
            return("Новость, "+date, UIColor.orangeColor())
        }
    }
    
    
    // MARK: CoreData
    func readCoreData() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedContext)
        do {
            let fetchedEntities = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
            for fetchedEntity in fetchedEntities {
//                let idTemp, headerTemp, textTemp, imgPreviewUrlTemp, imgUrlTemp, linkTemp, shortTextTemp, typeTemp, datePublishTemp : String
//                if let id = fetchedEntity.valueForKey("id") as? String {
//                    idTemp = id  } else { idTemp = "" }
//                if let header = fetchedEntity.valueForKey("header") as? String {
//                    headerTemp = header  } else { headerTemp = "" }
//                if let text = fetchedEntity.valueForKey("text") as? String {
//                    textTemp = text  } else { textTemp = "" }
//                if let imgPreviewUrl = fetchedEntity.valueForKey("imgPreviewUrl") as? String {
//                    imgPreviewUrlTemp = imgPreviewUrl  } else { imgPreviewUrlTemp = "" }
//                if let imgUrl = fetchedEntity.valueForKey("imgUrl") as? String {
//                    imgUrlTemp = imgUrl  } else { imgUrlTemp = "" }
//                if let link = fetchedEntity.valueForKey("link") as? String {
//                    linkTemp = link  } else { linkTemp = "" }
//                if let shortText = fetchedEntity.valueForKey("shortText") as? String {
//                    shortTextTemp = shortText  } else { shortTextTemp = "" }
//                if let type = fetchedEntity.valueForKey("type") as? Int {
//                    typeTemp = String(type) } else { typeTemp = "0" }
//                if let datePublish = fetchedEntity.valueForKey("datePublish") as? String {
//                    datePublishTemp = datePublish  } else { datePublishTemp = "" }
                self.array.append(Content(id: fetchedEntity.valueForKey("id") as! String, header: fetchedEntity.valueForKey("header") as! String, text: fetchedEntity.valueForKey("text") as! String, imgPreviewUrl: fetchedEntity.valueForKey("imgPreviewUrl") as! String, imgUrl: fetchedEntity.valueForKey("imgUrl") as! String, link: fetchedEntity.valueForKey("link") as! String, shortText: fetchedEntity.valueForKey("shortText") as! String, type: String(fetchedEntity.valueForKey("type") as! Int), datePublish: fetchedEntity.valueForKey("datePublish") as! String))
                if let data = (fetchedEntity.valueForKey("image") as? NSData) {if let img = UIImage(data: data) {
                    self.array.last?.image = img }
                }
                if let data = (fetchedEntity.valueForKey("imagePreview") as? NSData) {if let img = UIImage(data: data) {
                    self.array.last?.imagePreview = img }
                }
            }
            // update View
            NSNotificationCenter.defaultCenter().postNotificationName(RSGotContents, object: self)
        } catch {
            print(error) }
    }
    
    func writeCoreData() {
        deleteCoreData()
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let contentEntity = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedContext)
        for content in self.array {
            let currentRecord = NSManagedObject(entity: contentEntity!, insertIntoManagedObjectContext: managedContext)
            currentRecord.setValue(String(content.id), forKey: "id")
            currentRecord.setValue(content.header, forKey: "header")
            currentRecord.setValue(content.text, forKey: "text")
            currentRecord.setValue(content.imgPreviewUrl, forKey: "imgPreviewUrl")
            currentRecord.setValue(content.imgUrl, forKey: "imgUrl")
            currentRecord.setValue(content.link, forKey: "link")
            currentRecord.setValue(content.shortText, forKey: "shortText")
            currentRecord.setValue(content.type.rawValue, forKey: "type")
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
            currentRecord.setValue(formatter.stringFromDate(content.datePublish), forKey: "datePublish")
            // images
            if let image = content.image    { if let imageData = UIImagePNGRepresentation(image) {
                currentRecord.setValue(imageData, forKey: "image") }
            }
            if let image = content.imagePreview    { if let imagePreviewData = UIImagePNGRepresentation(image) {
                currentRecord.setValue(imagePreviewData, forKey: "imagePreview") }
            }
        }
        do { try managedContext.save() }
            catch { print("Could not save \(error)") }
        }
    
        func deleteCoreData() {
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedContext)
            do {
                let fetchedEntities = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
                for entity in fetchedEntities { managedContext.deleteObject(entity) }
                try managedContext.save()
            } catch { print(error) }
        }
    
}

