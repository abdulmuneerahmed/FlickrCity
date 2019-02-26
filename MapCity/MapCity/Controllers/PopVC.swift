//
//  PopVC.swift
//  MapCity
//
//  Created by admin on 25/02/19.
//  Copyright © 2019 AcknoTech. All rights reserved.
//

import UIKit

class PopVC:UIViewController,UIGestureRecognizerDelegate{
    
    var passImage:UIImage!
    
    override func loadView() {
        super.loadView()
        setup()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview.image = passImage
        doubleTap()
    }
    
    lazy var imageview:UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var label:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenirnext-Demibold", size: 18)
        label.text = "Double-tap to dismiss"
        label.textAlignment = .center
        return label
    }()
    
    lazy var labelview:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        return view
    }()
    func setup(){
        view.addSubview(imageview)
        imageview.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        view.addSubview(labelview)
        labelview.setAnchor(width: view.frame.width - 50, height: 50)
        labelview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        labelview.addSubview(label)
        label.setAnchor(top: labelview.topAnchor, left: labelview.leftAnchor, bottom: labelview.bottomAnchor, right: labelview.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10)
    }
    
    func initData(forImage image:UIImage){
        self.passImage = image
    }
    
    func doubleTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopVC))
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissPopVC(){
        dismiss(animated: true, completion: nil)
    }
}
