//
//  ViewController.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 27/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//

import UIKit


class RSOneContentVC: UIViewController {
    
    @IBOutlet weak var RSActivity: UIActivityIndicatorView!
    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet weak var RSHeaderLabel: UILabel!
    @IBOutlet weak var RSDateLabel: UILabel!
    @IBOutlet weak var RSTextLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // image
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if let img = Contents.shared.currentImage() {
                dispatch_async(dispatch_get_main_queue()) {
                    self.RSActivity.stopAnimating()
                    self.RSImageView.image = img
                    Contents.shared.setCurrentImage(img)
                }
            } else {
                // try download
                if let imgUrl = Contents.shared.currentImageUrl() {
                    if let url = NSURL(string: imgUrl) {
                        if let data = NSData(contentsOfURL: url) {
                            if let img = UIImage(data: data) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.RSActivity.stopAnimating()
                                    self.RSImageView.image = img
                                    Contents.shared.setCurrentImage(img)
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.RSActivity.stopAnimating()
                                    self.RSImageView.image = RSNoImage
                                    Contents.shared.setCurrentImage(RSNoImage)
                                }
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.RSActivity.stopAnimating()
                                self.RSImageView.image = RSNoImage
                                Contents.shared.setCurrentImage(RSNoImage)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.RSActivity.stopAnimating()
                            self.RSImageView.image = RSNoImage
                            Contents.shared.setCurrentImage(RSNoImage)
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.RSActivity.stopAnimating()
                        self.RSImageView.image = RSNoImage
                        Contents.shared.setCurrentImage(RSNoImage)
                    }
                }
            }
        }
        
        // at design - Date; at Task - Link
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        self.RSDateLabel.attributedText = NSAttributedString(string: Contents.shared.currentLink(), attributes: underlineAttribute)
        
        self.RSHeaderLabel.text = Contents.shared.currentHeader()
        self.RSTextLabel.text = Contents.shared.currentText()
    }
}

