//
//  MapsViewController.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit
import MapKit
import CoreLocation

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

protocol locationUpdateDelegate {
    func locationUpdated(lat: Double, lon: Double);
}

class MapsViewController: UIViewController, CLLocationManagerDelegate,UITabBarControllerDelegate {
    
    @IBOutlet weak var mapView : MKMapView!;
    @IBOutlet weak var switchButton : UISwitch!;
    
    var lat: Double? = nil
    var lon: Double? = nil
    
    var locationUpdateDelegate: locationUpdateDelegate?
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Map"
                
        //Ask for permission to track user.
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0;
        locationManager.delegate = self;
        
        tabBarController?.delegate = self;
        
        if(switchButton.isOn) {
            print("Location")
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true;
        }
        
        let location = CLLocation(latitude: 59.91, longitude: 10.74);
        let hk = MapPoint(title: "Høyskolen Kristiania", locationName: "Dronningens Gate",
                          coordinate: CLLocationCoordinate2D(latitude: 59.91, longitude: 10.74))
        mapView.centerOnCords(location: location)
        mapView.addAnnotation(hk)
        
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
    }
   
    @IBAction func didTouchUpInside(sender: Any) {
        if(switchButton.isOn) {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if(viewController is ViewController) {
            guard lat != nil && lon != nil else {
                return;
            }
            locationUpdateDelegate?.locationUpdated(lat: lat!, lon: lon!)
        }
    }
        
}

private extension MKMapView {
    func centerOnCords(location: CLLocation, displayRadius: CLLocationDistance = 1000) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: displayRadius, longitudinalMeters: displayRadius)
        setRegion(region, animated: true)
    }
}
