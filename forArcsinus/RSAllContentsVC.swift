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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "offlineAlert:", name: RSOffline, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openSettingsAlert:", name: RSOpenSettingsURL, object: nil)
        self.refreshControl?.addTarget(self, action: "refreshTableView:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // refresh table
    func refreshTableView(sender:AnyObject) {
        self.RSActivity.startAnimating()
        NSNotificationCenter.defaultCenter().postNotificationName(RSGetContentAgain, object: self)
    }
    // reload table
    func updateTableView(notification: NSNotification) {
        self.RSActivity.stopAnimating()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // show alert offline
    func offlineAlert(notification: NSNotification) {
        self.RSActivity.stopAnimating()
        let alertController = UIAlertController(
            title: "U are offline", message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // show alert Location Access Disabled
    func openSettingsAlert(notification: NSNotification) {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'When use'.",
            preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return Contents.shared.count() }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let i = indexPath.row
        let cell = self.tableView.dequeueReusableCellWithIdentifier("RSAllContentsCell") as! RSAllContentsCell
        // header & text
        cell.RSHeaderLabel.text = Contents.shared.header(i)
        cell.RSTextLabel.text = Contents.shared.shortText(i)
//        // type & date
        let typeDateColor = Contents.shared.typeDate(i)
        cell.RSTypeDateLabel.text = typeDateColor.text
        cell.RSTypeDateLabel.textColor = typeDateColor.color
        cell.updateConstraintsIfNeeded()
//        // image
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if let imgPreview = Contents.shared.imagePreview(i) {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.RSImageView.image = imgPreview
                    Contents.shared.setImagePreview(imgPreview, index: i)
                }
            } else {
                // try download 
                if let imgPreviewUrl = Contents.shared.imagePreviewUrl(i) {
                    if let url = NSURL(string: imgPreviewUrl) {
                        if let data = NSData(contentsOfURL: url) {
                            if let imgPreview = UIImage(data: data) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    cell.RSImageView.image = imgPreview
                                    Contents.shared.setImagePreview(imgPreview, index: i)
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    cell.RSImageView.image = RSNoImage
                                    Contents.shared.setImagePreview(RSNoImage, index: i)
                                }
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.RSImageView.image = RSNoImage
                                Contents.shared.setImagePreview(RSNoImage, index: i)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.RSImageView.image = RSNoImage
                            Contents.shared.setImagePreview(RSNoImage, index: i)
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.RSImageView.image = RSNoImage
                        Contents.shared.setImagePreview(RSNoImage, index: i)
                    }
                }
            }
            cell.updateConstraintsIfNeeded()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)!.selectionStyle = UITableViewCellSelectionStyle.None
        Contents.shared.setCurrent(indexPath.row)
        self.performSegueWithIdentifier("RSSegue2OneContent", sender: self)
    }
    
    deinit { NSNotificationCenter.defaultCenter().removeObserver(self) }
}


// MARK: RSTableViewCell
class RSAllContentsCell: UITableViewCell {
    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet weak var RSHeaderLabel: UILabel!
    @IBOutlet weak var RSTypeDateLabel: UILabel!
    @IBOutlet weak var RSTextLabel: UILabel!
}
