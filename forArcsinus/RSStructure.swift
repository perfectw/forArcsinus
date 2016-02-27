
import UIKit

let RSURLSite = "http://the-flow.ru"


//"banner" : 0,
//"change_datetime" : "07-12-2015 14:09:36", - Время последнего изменения
//"content_status_id" : 2, 1 - Новый, 2 - Доступен для приложения, 3 - Не доступен для приложения, 4 - Должен быть удален
//"content_type_id" : 0, - 0 - новость, 1 - акция, 2 - спецпредложение
//"deleted" : 1, - не интересует
//"end_datetime" : "00-00-0000 23:59:59",
//"full_text" : "тест 4",        - Полное описание
//"header" : "Тестовая новость", - Заголовок
//"id" : 165,                    - идентификатор
//"img_banner_url" : null,       - не интересует
//"img_height" : null,           - не интересует
//"img_preview_url" : "",        - Url превью картинки
//"img_url" : null,              - Url картинки
//"img_width" : null,            - не интересует
//"link" : "",                   - ссылка на источник
//"publish_time" : "07-12-2015 14:03:53",   - Время публикации контента
//"short_text" : "ОЧЕНЬ краткий текст",     - Краткое описание
//"start_datetime" : "00-00-0000 00:00:00", - Время начала действия акции
//"status" : "Доступен для приложения",     - Текстовое описание статуса
//"template" : 1, - не интересует
//"type" : "Новость" - описание типа


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

class Content {
    var text, header, imgPreviewUrl, imgUrl, link : String
    var id : Int
    var status : ContentStatus
    var type : ContentType
    var typeString : String
    var datePublish, dateChange : NSDate    // no end_datetime & start_datetime
    var shortText : String // Краткое описание
    var image, previewImage : UIImage!
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
        let dateFromString : NSDate = dateFormatter.dateFromString(self)!
        //Return Parsed Date
        return dateFromString
    }
}

let RSCellHeight = 300