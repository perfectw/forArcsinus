//
//  RSNewsVC.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 27/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class RSAllContentsVC: UITableViewController {
    
    var contents : [Content] = []
    var currentContent = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contents = []
    }

// MARK: TableView
override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contents.count
}
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let i = indexPath.row
    let cell = self.tableView.dequeueReusableCellWithIdentifier("RSAllContentsCell") as! RSAllContentsCell
    cell.RSHeaderLabel.text = contents[i].header
    cell.RSTypeDateLabel.text = contents[i].typeString + contents[i].dateChange.description // temp
    cell.RSTextLabel.text = contents[i].text
    if let img = contents[i].image {
        cell.RSImageView.image = img
    } else {
//        Alamofire.request(.GET, RSURLSite+self.publications[indexPath.row].imgUrl).responseString { response in
//            if let data = response.data {
//                let img = UIImage(data: data)
//                cell.RSImageView.image = img
//                self.publications[indexPath.row].image = img
//            }
//        }
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
    self.currentContent = indexPath.row
    self.performSegueWithIdentifier("RSSegue2OneContent", sender: self)
}
    
override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!)
{
    if segue.identifier == "RSSegue2OneContent" {
        (segue.destinationViewController as! RSOneContentVC).RSURL = self.contents[self.currentContent].link
    }
}
    
}


// MARK: RSTableViewCell
class RSAllContentsCell: UITableViewCell {
    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet weak var RSHeaderLabel: UILabel!
    @IBOutlet weak var RSTypeDateLabel: UILabel!
    @IBOutlet weak var RSTextLabel: UILabel!
}
