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
        dispatch_async(dispatch_get_main_queue()) {
            if let img = Contents.shared.currentImage() {
                self.RSImageView.image = img
            } else {
                self.RSImageView.image = UIImage(named: "noimg.png")
            }
            self.RSActivity.stopAnimating()
        }
        self.RSHeaderLabel.text = Contents.shared.currentHeader()
        self.RSDateLabel.text = Contents.shared.currentLink()
        self.RSTextLabel.text = Contents.shared.currentText()
    }
}

