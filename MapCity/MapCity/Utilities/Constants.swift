//
//  Constants.swift
//  MapCity
//
//  Created by admin on 25/02/19.
//  Copyright © 2019 AcknoTech. All rights reserved.
//

import Foundation

let apiKey = "5ae1048494963caec21c2fdcdbe88edf"

func flickrUrl(forApiKey key:String,withAnnotation annotation:DroppablePin, andNumberOfPhotos number:Int)->String{
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
    return url
}
