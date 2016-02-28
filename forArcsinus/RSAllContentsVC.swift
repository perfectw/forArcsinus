//
//  RSNewsVC.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 27/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//

import UIKit


class RSAllContentsVC: UITableViewController {
    @IBOutlet var RSActivity: UIActivityIndicatorView!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.RSActivity.center = self.view.center
        self.tableView.addSubview(RSActivity)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView:", name: RSGotContents, object: nil)
    }
    
    func updateTableView(notification: NSNotification) {
        self.RSActivity.stopAnimating()
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return Contents.shared.count() }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let i = indexPath.row
        let cell = self.tableView.dequeueReusableCellWithIdentifier("RSAllContentsCell") as! RSAllContentsCell
        // header & text
        cell.RSHeaderLabel.text = Contents.shared.header(i)
        cell.RSTextLabel.text = Contents.shared.shortText(i)
        // type & date
        let typeDateColor = Contents.shared.typeDate(i)
        cell.RSTypeDateLabel.text = typeDateColor.text
        cell.RSTypeDateLabel.textColor = typeDateColor.color
        // image
        if let img = Contents.shared.imagePreview(i) {
            cell.RSImageView.image = img
        } else {
            cell.RSImageView.image = UIImage(named: "noimg.png")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)!.selectionStyle = UITableViewCellSelectionStyle.None
        Contents.shared.setCurrent(indexPath.row)
        self.performSegueWithIdentifier("RSSegue2OneContent", sender: self)
    }
}


// MARK: RSTableViewCell
class RSAllContentsCell: UITableViewCell {
    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet weak var RSHeaderLabel: UILabel!
    @IBOutlet weak var RSTypeDateLabel: UILabel!
    @IBOutlet weak var RSTextLabel: UILabel!
}
