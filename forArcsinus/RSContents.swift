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


class Contents: NSObject, CLLocationManagerDelegate {
    static let shared = Contents()
    
    // MARK: LocationManager
    let locationManager = CLLocationManager()
    private override init() {
        super.init()
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
            self.postAIUID()
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        default: break
        }
    }

    // MARK: HTML
    private var RSUID : String! = nil
    internal func UID() -> String {
        if let uid = self.RSUID {
            return uid
        } else { return "911" }
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
            "uid" : self.RSUID!,
            "last_session_datetime" : "0",
            "content_type_id" : "0",
            "from_id" : "0",
            "max" : "100" ]
        
        Alamofire.request(.POST, "http://service-retailmob.rhcloud.com/api/v1/mobclient/register", parameters: parameters).responseJSON { response in
            debugPrint(response)     // prints detailed description of all response properties
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)
            if let dummyData = response.data {
                let dummyJSON = JSON(data: dummyData)
                print(dummyJSON)
                for (_, subJSON) in dummyJSON {
                    print(subJSON)
                }
                Contents.shared.append(Content(id: "666", header: "New New", text: "long or short but that is text aboutnew text with bitch and hitch", imgPreviewUrl: "http://dreamatico.com/data_images/car/car-8.jpg", imgUrl: "http://dreamatico.com/data_images/car/car-8.jpg", link: "nilds", shortText: "short", status: "1", type: "0", typeString: "News", datePublish: "07-12-2015 14:03:53", dateChange: "07-12-2015 14:11:53"))
//                Contents.shared.noimg()
                Contents.shared.append(Content(id: "666", header: "New New2", text: "long or short but that is text aboutnew text with bitch and hitch", imgPreviewUrl: "nil", imgUrl: "http://www.macdigger.ru/wp-content/uploads/2016/02/Power-Bank-0.jpg", link: "nildsds", shortText: "short", status: "1", type: "2", typeString: "News", datePublish: "07-12-2015 14:03:53", dateChange: "07-12-2015 14:11:53"))
                Contents.shared.noimg()
                self.arraySort()
                NSNotificationCenter.defaultCenter().postNotificationName(RSGotContents, object: self)
            } else { print("No-No-No ;(") }
        }
    }
    
    
    // MARK: Array
    private var array : [Content] = []
    private func arraySort() {
        self.array.sortInPlace({ $0.datePublish > $1.datePublish })
    }
    internal func append(content : Content) {
        self.array.append(content)
    }
    func count() -> Int {
        return self.array.count
    }
    
    func header(i: Int) -> String {
        return self.array[i].header
    }
    func shortText(i: Int) -> String {
        return self.array[i].shortText
    }
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
    func imagePreview(i: Int) -> UIImage? {
        if let imgPreview = array[i].imagePreview {
            return imgPreview
        } else {
            if let data = NSData(contentsOfURL: NSURL(string: self.array[i].imgPreviewUrl)!) {
                if let imgPreview = UIImage(data: data) {
                    self.array[i].imagePreview = imgPreview
                    return imgPreview
                }
            }
            return nil
        }
    }
    
    // MARK: currentContent
    private var current : Int = 0
    internal func setCurrent(i: Int) {
        self.current = i
    }
    func currentImage() -> UIImage? {
        if let img = array[self.current].image {
            return img
        } else {
            if let data = NSData(contentsOfURL: NSURL(string: self.array[self.current].imgUrl)!) {
                if let img = UIImage(data: data) {
                    self.array[self.current].image = img
                    return img
                }
            }
            return nil
        }
    }
    func currentHeader() -> String {
        return self.array[self.current].header
    }
    func currentText() -> String {
        return self.array[self.current].text
    }
    func currentLink() -> String {
        return self.array[self.current].link
    }
    
    func noimg() {
        self.array.last?.imagePreview = UIImage(named: "noimg.png")
    }
    
    
}

