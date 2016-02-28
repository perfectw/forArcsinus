//
//  RSNewsVC.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 27/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//
//"cc2d789aad372a50d0d9f889c35bc44a"
import UIKit
import Alamofire


class RSAllContentsVC: UITableViewController {
    
    let locationManager = CLLocationManager()
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        Contents.shared.append(Content(id: "666", header: "New New", text: "long or short but that is text aboutnew text with bitch and hitch", imgPreviewUrl: "nil", imgUrl: "nil", link: "nil", shortText: "short", status: "1", type: "0", typeString: "News", datePublish: "07-12-2015 14:03:53", dateChange: "07-12-2015 14:11:53"))
        Contents.shared.noimg()
        Contents.shared.append(Content(id: "666", header: "New New2", text: "long or short but that is text aboutnew text with bitch and hitch", imgPreviewUrl: "nil", imgUrl: "nil", link: "nil", shortText: "short", status: "1", type: "2", typeString: "News", datePublish: "07-12-2015 14:03:53", dateChange: "07-12-2015 14:11:53"))
        Contents.shared.noimg()
////        readCoreData()
//        postAIUID()
//        // if got UID
//        if let UID = NSUserDefaults.standardUserDefaults().stringForKey("RSUID") {
//            self.RSUID = UID
//            // read data
//            // get content
//            getContent()
//        } else {
//            // ask location permission
//            askLocationPermission()
//        }
    }
    
    // MARK: TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Contents.shared.count()
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let i = indexPath.row
        let cell = self.tableView.dequeueReusableCellWithIdentifier("RSAllContentsCell") as! RSAllContentsCell
        // header & text
        cell.RSHeaderLabel.text = Contents.shared.header(i)
        cell.RSTextLabel.text = Contents.shared.text(i)
        // type & date
        let typeDateColor = Contents.shared.typeDate(i)
        cell.RSTypeDateLabel.text = typeDateColor.text
        cell.RSTypeDateLabel.textColor = typeDateColor.color
        // image
        if let img = Contents.shared.image(i) {
            cell.RSImageView.image = img
        } else {
            Alamofire.request(.GET,  Contents.shared.imgPreviewUrl(i)).responseString { response in
                if let data = response.data {
                    if let imgPreview = UIImage(data: data) {
                        cell.RSImageView.image = imgPreview
                        Contents.shared.setImagePreview(imgPreview, index: i)
                    } else {
                        cell.RSImageView.image = UIImage(named: "noimg.png")
                    }
                }
            }
        }
        return cell
    }
    
    //    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        guard let tableViewCell = cell as? RSTableCell else { return }
    //        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    //        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    //    }
    //    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        guard let tableViewCell = cell as? RSTableCell else { return }
    //        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    //    }
    
    //    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return RSHeight
    //    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)!.selectionStyle = UITableViewCellSelectionStyle.None
        Contents.shared.current = indexPath.row
        self.performSegueWithIdentifier("RSSegue2OneContent", sender: self)
    }
    

    // MARK: HTTP
    func postAIUID(latitude: String, longitude: String) {
        
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
        
        Alamofire.request(.POST, "http://service-retailmob.rhcloud.com/api/v1/mobclient/register", parameters: parameters).responseJSON { response in
            if let jsonData = response.data {
                let json = JSON(data: jsonData)
                print(json)
                // if OK
                if json["status"].int == 0 {
                    Contents.shared.RSUID = json["data"]["UID"].string
                    self.getContent()
                }
            }
        }
    }
    func getContent() {
        var parameters = [
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
            "uid" : Contents.shared.RSUID!,
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
            } else { print("No-No-No ;(") }
        }
    }
    
    
    
    //    func postAppKey() {
    //        let parameters = [
    //            "app_key": "04f0f542ea27a58461a44fbd75a89b30",
    //            "package_name":"ru.arcsinus.SalesBlast",
    //            "app_version": "1.1.0",
    //            "latitude"
    //
    //
    //                ["a", 1],
    //            "qux": [
    //                "x": 1,
    //                "y": 2,
    //                "z": 3
    //            ]
    //        ]
    //
    //        Alamofire.request(.POST, "http://service-retailmob.rhcloud.com/api/v1/mobclient/register", parameters: parameters).responseJSON { response in
    //            debugPrint(response)     // prints detailed description of all response properties
    //
    //            print(response.request)  // original URL request
    //            print(response.response) // URL response
    //            print(response.data)     // server data
    //            print(response.result)   // result of response serialization
    //
    //            if let JSON = response.result.value {
    //                print("JSON: \(JSON)")
    //            }
    //        }    }
    

}


// MARK: RSTableViewCell
class RSAllContentsCell: UITableViewCell {
    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet weak var RSHeaderLabel: UILabel!
    @IBOutlet weak var RSTypeDateLabel: UILabel!
    @IBOutlet weak var RSTextLabel: UILabel!
}
