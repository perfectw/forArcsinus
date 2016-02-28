
import UIKit


enum ContentType : Int {
    // 0 - новость, 1 - акция, 2 - спецпредложение
    case News = 0
    case Promotion = 1
    case Special = 2
}
//enum ContentStatus : Int {
//    // 1 - Новый, 2 - Доступен для приложения, 3 - Не доступен для приложения, 4 - Должен быть удален
//    case New = 1
//    case Available = 2
//    case NotAvailable = 3
//    case Removal = 4
//}


// MARK: Content
class Content {
    var id : Int
    var header, text, shortText, imgPreviewUrl, imgUrl, link : String
    var type : ContentType
    //    var status : ContentStatus
    var datePublish : NSDate    // no dateChange & end_datetime & start_datetime
    var image, imagePreview : UIImage!
    init (id: String, header: String, text: String, imgPreviewUrl: String, imgUrl: String, link: String, shortText: String, status: String, type: String, typeString: String, datePublish: String, dateChange: String ) {
        if let ID = Int(id) { self.id = ID }    else { self.id = 0 }
        self.header = header; self.text = text; self.shortText = shortText;
        self.imgPreviewUrl = imgPreviewUrl; self.imgUrl = imgUrl; self.link = link
        if let Type = Int(type) {
            if let cType = ContentType.init(rawValue: Type) {
                self.type = cType
            } else { self.type = ContentType.News } // News is not bad
        } else { self.type = ContentType.News } // News is not bad
        //        if let Status = Int(status) {
        //            if let cStatus = ContentStatus.init(rawValue: Status) {
        //                self.status = cStatus
        //            } else { self.status = ContentStatus.New } // If downloaded Then it's new
        //        } else { self.status = ContentStatus.New } // If downloaded Then it's new
        self.datePublish = datePublish.toNSDate()
    }
}



extension String {
    func toNSDate() -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        if let dateFromString : NSDate = dateFormatter.dateFromString(self) {
            return dateFromString
        }
        return NSDate()
    }
}

let RSGotContents = "RSGotContents"

public func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedAscending
}
public func ==(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedSame
}
public func >(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedDescending
}
