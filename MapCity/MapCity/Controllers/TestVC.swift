//
//  TestVC.swift
//  MapCity
//
//  Created by admin on 26/02/19.
//  Copyright © 2019 AcknoTech. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class ClickVC:UIViewController{
    let apiKey = "https://pixabay.com/api/?key=11726893-c8c57f551beebf3407d1d646f&image_type=all&page=2&per_page=40&pretty=true"
    var inti:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fire(){_ in
        }
        
    }
    func fire(_ handler:@escaping (Bool)->()){
        Alamofire.request(apiKey).responseJSON { (response) in
            print(response)
            
            handler(true)
        }
    }
}
