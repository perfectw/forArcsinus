
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation


enum ContentStatus : Int {
    // 1 - Новый, 2 - Доступен для приложения, 3 - Не доступен для приложения, 4 - Должен быть удален
    case New = 1
    case Available = 2
    case NotAvailable = 3
    case Removal = 4
}
enum ContentType : Int {
    // 0 - новость, 1 - акция, 2 - спецпредложение
    case News = 0
    case Promotion = 1
    case Special = 2
}

// MARK: Content
class Content {
    var text, header, imgPreviewUrl, imgUrl, link : String
    var id : Int
    var status : ContentStatus
    var type : ContentType
    var typeString : String
    var datePublish, dateChange : NSDate    // no end_datetime & start_datetime
    var shortText : String // Краткое описание
    var image, imagePreview : UIImage!
    init (id: String, header: String, text: String, imgPreviewUrl: String, imgUrl: String, link: String, shortText: String, status: String, type: String, typeString: String, datePublish: String, dateChange: String ) {
        self.text = text; self.header = header; self.imgPreviewUrl = imgPreviewUrl; self.imgUrl = imgUrl;
        self.link = link
        if let ID = Int(id) { self.id = ID }    else { self.id = 0 }
        if let Type = Int(type) {
            if let cType = ContentType.init(rawValue: Type) {
                self.type = cType
            } else { self.type = ContentType.News } // News is not bad
        } else { self.type = ContentType.News } // News is not bad
        if let Status = Int(status) {
            if let cStatus = ContentStatus.init(rawValue: Status) {
                self.status = cStatus
            } else { self.status = ContentStatus.New } // If downloaded Then it's new
        } else { self.status = ContentStatus.New } // If downloaded Then it's new
        self.typeString = typeString
        self.dateChange = dateChange.toNSDate()
        self.datePublish = datePublish.toNSDate()
        self.shortText = shortText
    }
}


// MARK: Contents
class Contents: NSObject, CLLocationManagerDelegate {
    static let shared = Contents()
    private override init() {}
    // MARK: array
    private var array : [Content] = []
    func append(content : Content) {
        self.array.append(content)
    }
    func count() -> Int {
        return self.array.count
    }
    func header(i: Int) -> String {
        return self.array[i].header
    }
    func text(i: Int) -> String {
        return self.array[i].text
    }
    func typeDate(i: Int) -> (text: String, color: UIColor) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        let date = formatter.stringFromDate(self.array[i].dateChange)
        switch self.array[i].type {
        case ContentType.Promotion :
            return("Акция, "+date, UIColor.blueColor())
        case ContentType.Special :
            return("Спецпредложение, "+date, UIColor.redColor())
        default:
            return("Новость, "+date, UIColor.orangeColor())
        }
    }
    func image(i: Int) -> UIImage? {
        return self.array[i].image
    }
    func imgUrl(i: Int) -> String {
        return self.array[i].imgUrl
    }
    internal func setImage(image: UIImage, index: Int) {
        self.array[index].image = image
    }
    func imagePreview(i: Int) -> UIImage? {
        return self.array[i].imagePreview
    }
    func imgPreviewUrl(i: Int) -> String {
        return self.array[i].imgPreviewUrl
    }
    internal func setImagePreview(imagePreview: UIImage, index: Int) {
        self.array[index].imagePreview = imagePreview
    }
    // current
    internal var current : Int = 0
    internal func currentImage() -> UIImage? {
        if let img = array[current].image {
            return img
        } else {
            if let data = NSData(contentsOfURL: NSURL(string: self.array[current].imgUrl)!) {
                if let img = UIImage(data: data) {
                    self.array[self.current].image = img
                    return img
                }
            }
            return nil
        }
    }
    // MARK: HTML
    private var RSUID : String! = nil
    func UID() -> String {
        if let uid = self.RSUID {
            return uid
        } else { return "911" }
    }
    let locationManager = CLLocationManager()
    func postAIUID() {
        // temp location?
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
        parameters
        
        
        Alamofire.request(.POST, "http://service-retailmob.rhcloud.com/api/v1/mobclient/register", parameters: parameters).responseJSON { response in
            if let jsonData = response.data {
                let json = JSON(data: jsonData)
                print(json)
                // if OK
                if json["status"].int == 0 {
                    self.RSUID = json["data"]["UID"].string
                    self.getContent()
                }
            }
        }
    }
    
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
    func noimg() {
        self.array.last?.imagePreview = UIImage(named: "noimg.png")
    }
    
}


extension String {
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
    func toNSDate() -> NSDate
    {
        //Create Date Formatter
        let dateFormatter = NSDateFormatter()
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        //Parse into NSDate
        if let dateFromString : NSDate = dateFormatter.dateFromString(self) {
            //Return Parsed Date
            return dateFromString
        }
        return NSDate()
    }
}

let RSCellHeight = 300