//
//  MapPoint.swift
//  CleverWeather
//
//  Created by Jonas on 11/2/20.
//

import UIKit
import MapKit

class MapPoint : NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title;
        self.locationName = locationName;
        self.coordinate = coordinate
        super.init()
    }
}
