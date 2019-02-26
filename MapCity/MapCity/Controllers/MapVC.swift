//
//  ViewController.swift
//  MapCity
//
//  Created by admin on 24/02/19.
//  Copyright © 2019 AcknoTech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage


class MapVC: UIViewController,UIGestureRecognizerDelegate {
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius:Double = 10000
    var bottomViewHeightAnchor:NSLayoutConstraint!
    var buttonBottomAnchor:NSLayoutConstraint!
    var spinner:UIActivityIndicatorView?
    var progressLbl:UILabel?
    var imgeUrlArray = [String]()
    var imageArray = [UIImage]()
    override func loadView() {
        super.loadView()
        setup()
    }
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadMapTools()
        
        configureLocationServises()
        addDoubleTap()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        bottomView.addSubview(collectionView!)
        registerForPreviewing(with: self, sourceView: collectionView!)
    }
    
    
    //MAPVIEW
    lazy var mapView:MKMapView = {
        let map = MKMapView()
        //        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsBuildings = true
        map.showsPointsOfInterest = true
        map.showsUserLocation = true
        return map
    }()
    
    lazy var bannerView:UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(red: 246/255, green: 166/255, blue: 35/255, alpha: 1)
        
        return view
    }()
    
    lazy var label:UILabel = {
        let label = UILabel()
        label.text = "Double-tap to drop a pin and photos"
        label.textAlignment = .center
        label.font = UIFont(name: "Avenirnext-Demibold", size: 20)
        label.textColor = .white
//        label.backgroundColor = UIColor(red: 246/255, green: 166/255, blue: 35/255, alpha: 1)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var button:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "locationButton"), for: .normal)
        btn.addTarget(self, action: #selector(centerMapButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    lazy var bottomView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //    Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    // Loading All View in loadView
    func setup(){
        //Add mapview
       navigationController?.navigationBar.barTintColor = UIColor(red: 246/255, green: 166/255, blue: 35/255, alpha: 1)
        view.addSubview(mapView)
        mapView.setAnchor(top: view.safeTopAnchor, left: view.safeLeftAnchor, bottom: view.bottomAnchor, right: view.safeRightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        navigationItem.titleView = bannerView

        bannerView.addSubview(label)
        label.setAnchor(width: view.frame.width - 30, height: 30)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),
            ])
        //Add Bottom View
        view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.leftAnchor.constraint(equalTo: view.safeLeftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.safeRightAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            
            ])
        bottomViewHeightAnchor = bottomView.heightAnchor.constraint(equalToConstant: 0)
        bottomViewHeightAnchor.isActive = true
        
        
        //Add button
        view.addSubview(button)
        button.setAnchor(top: nil, left: nil, bottom: nil, right: view.safeRightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10)
        button.setAnchor(width: 60, height: 60)
        buttonBottomAnchor = button.bottomAnchor.constraint(equalTo: bottomView.topAnchor,constant: -10)
        buttonBottomAnchor.isActive = true
        
        
    }
    
    
    
    //MapView Settings
    func loadMapTools(){
        mapView.delegate = self
        
    }
    
    //    Creating Tap gesture user can double tap and create pin
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 1
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    //Add Swipe Gestre to bottom view
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipe.direction = .down
        bottomView.addGestureRecognizer(swipe)
    }
    
    
    //Animate the Bottom View and set the heigth
    
    func animatedView(){
        
        UIView.animate(withDuration: 0.5) {
            self.bottomViewHeightAnchor.constant = self.view.frame.height/2 - 60
            self.view.layoutIfNeeded()
        }
    }
    
    //Adding Spinner
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        //        spinner?.frame = CGRect(origin: CGPoint(x: bottomView.frame.width/2, y: bottomView.frame.height/2), size: CGSize(width: 80, height: 80))
        spinner?.hidesWhenStopped = true
        spinner?.center = CGPoint(x: bottomView.frame.width/2, y: (bottomView.frame.height/2 ) -  (spinner?.frame.size.height)!)
        collectionView!.addSubview(spinner!)
        
        spinner?.startAnimating()
        //
    }
    //Remove Spinner
    func removeSpinnerandLabel(){
        if spinner != nil{spinner?.removeFromSuperview()}
        if progressLbl != nil{progressLbl?.removeFromSuperview()}
    }
    //Adding Progress LAbel
    func addProgressLabel(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: 10, y: bottomView.frame.height/2 + (spinner?.frame.height)! + 25, width: bottomView.frame.width - 10, height: 50)
        
        progressLbl?.font = UIFont(name: "Avenir Next", size: 20)
        progressLbl?.text = "Loading..."
        progressLbl?.textColor = .darkGray
        progressLbl?.textAlignment = .center
        collectionView!.addSubview(progressLbl!)
    }
    
    //    Sticking to portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if UIDevice.current.userInterfaceIdiom == .phone{
            return .portrait
        }
        else{
            return .all
        }
    }
    
    
    //MARK:- Selectors
    
    //    Selector For Center the Map View
    @objc func centerMapButtonPressed(){
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMaponUserLocation()
        }
    }
    
    // selector For Swipe The Bottom View
    @objc func dismissView(){
        cancelAllSession()
        UIView.animate(withDuration: 0.5) {
            self.bottomViewHeightAnchor.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    //  Location Configuration
    func configureLocationServises(){
        //        Checking Device Level Location is on/off
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            //            locationManager.requestAlwaysAuthorization()
            checkLocationAuthorization()
        }else{
            return
        }
        
    }
    
    
    //    Location Settings
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
    }
    
    //        Checking Authorization Status
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerMaponUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            centerMaponUserLocation()
            locationManager.startUpdatingLocation()
            
        case .denied:
            //show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            break
        }
    }
    
    
    
}//Class End


extension MapVC: MKMapViewDelegate{
    
    //Customizing Pin
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    //    Centering the MAP When User Location Finds
    func centerMaponUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else{return}
        let coordinateregion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateregion, animated: true)
    }
    
    //    Drop Pin Function
    //MARK:-Selector
    @objc func dropPin(sender:UITapGestureRecognizer){
        
        removepin()
        removeSpinnerandLabel()
        cancelAllSession()
        imageArray = []
        imgeUrlArray = []
        collectionView?.reloadData()
        animatedView()
        addSwipe()
        addSpinner()
        addProgressLabel()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        //         print(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40))
        
        
        let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        //        print(touchPoint)
        retrieveUrl(forAnnotation: annotation) { (finished) in
//            print(self.imgeUrlArray)
//
            if finished {
                self.retrieveImages(handler: { (finish) in
                    if finish{
                        self.removeSpinnerandLabel()
                        //reload CollectionView
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    
    //    Remove Pin
    func removepin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrl(forAnnotation annotation:DroppablePin,handler: @escaping (_ status:Bool) ->() ){
//        imgeUrlArray = []
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
//            print(response)
            guard let json = response.result.value as? Dictionary<String,AnyObject> else{return}
            let photosDict = json["photos"] as! Dictionary<String,AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photosDictArray{
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imgeUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping (_ status:Bool)->()){
//        imageArray = []
        for url in imgeUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else{return}
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 Images Downloaded"
                
                if self.imageArray.count == self.imgeUrlArray.count{
                    handler(true)
                }
            }
        }
    }
    
    //CanCel All Downloade sesions
    
    func cancelAllSession(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloaddata) in
            sessionDataTask.forEach({ $0.cancel() })
            downloaddata.forEach({ $0.cancel() })
        }
    }
}


extension MapVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    
}

extension MapVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Number of item in array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else{return UICollectionViewCell()}
        let imagefromIndex = imageArray[indexPath.row]
        let imageview = UIImageView(image: imagefromIndex)
        cell.addSubview(imageview)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let popVC = PopVC()
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC,animated: true,completion: nil)
    }
}


extension MapVC: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location),let cell = collectionView?.cellForItem(at: indexPath) else{return nil}
        let VC = PopVC()
        VC.initData(forImage: imageArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return VC
        
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
