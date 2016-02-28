//
//  ViewController.swift
//  forArcsinus
//
//  Created by Roman Spirichkin on 27/02/16.
//  Copyright © 2016 Perfect W. All rights reserved.
//

import UIKit

class RSOneContentVC: UIViewController {

    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet weak var RSHeaderLabel: UILabel!
    @IBOutlet weak var RSDateLabel: UILabel!
    @IBOutlet weak var RSTextLabel: UILabel!
    
    var RSURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let img = contents[i].image {
            self.RSImageView.image = Contents.shared.image(<#T##i: Int##Int#>) .image(0) //content .image(0)
//        } else {
//            Alamofire.request(.GET, RSURLSite+self.contents[i].imgUrl).responseString { response in
//                if let data = response.data {
//                    let img = UIImage(data: data)
//                    cell.RSImageView.image = img
//                    self.contents[i].image = img
//                }
//            }
//        }
//        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

