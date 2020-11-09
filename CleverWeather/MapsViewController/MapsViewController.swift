//
//  MapsViewController.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit
import MapKit
import CoreLocation

protocol locationUpdateDelegate {
    func locationUpdated(lat: Double, lon: Double);
}

protocol WeatherDetailsDelegate {
    func updateData(lat: Double, lon: Double, data: NextHours)
}

class MapsViewController: UIViewController,UITabBarControllerDelegate, CLLocationManagerDelegate,WeatherDetailDelegate {
    
    @IBOutlet weak var mapView : MKMapView!;
    @IBOutlet weak var switchButton : UISwitch!;
    @IBOutlet weak var weatherDetails: WeatherDetails!;
    
    @IBOutlet weak var sliderConstraint: NSLayoutConstraint!
    
    var lat: Double? = nil
    var lon: Double? = nil
    
    var slideUp = false;
    
    var annontationCords : (lat: Double, lon: Double)?
    
    var locationUpdateDelegate: locationUpdateDelegate?
    
    let locationManager = CLLocationManager()
    
    let api = ForecastFetcher(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Map"
        
      
        
        sliderConstraint.constant = 0;

        
        tabBarController?.delegate = self;
        api.delegate = weatherDetails
        locationManager.delegate = self;
        weatherDetails.delegate = self;
    
        //Configure location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0;
        
        
        if(switchButton.isOn) {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true;
        }
        
        // Set start location
        let location = CLLocation(latitude: 59.91, longitude: 10.74);
        let hk = MapPoint(title: "Høyskolen Kristiania", locationName: "Dronningens Gate",
                          coordinate: CLLocationCoordinate2D(latitude: 59.91, longitude: 10.74))
        mapView.centerOnCords(location: location)
        mapView.addAnnotation(hk)

    }
    
    func slideUpAnimation() {
        UIView.animate(withDuration: 1, animations: {
            self.sliderConstraint.constant = 99;
            self.view.layoutIfNeeded()
        })
        
        slideUp = true;
    }
    
    @IBAction func longPressAddAnnotation(sender: UILongPressGestureRecognizer) {
        
        if(sender.state == .began) {
            
            //Get location
            let location = sender.location(in: mapView)
            let cords = mapView.convert(location, toCoordinateFrom: mapView)
            
            //Remove old annotations
            mapView.removeAnnotations(mapView.annotations)
            
            let point = MapPoint(title: "Selected",locationName: "User Selected", coordinate: cords)
            mapView.addAnnotation(point)
            print("Touch")
            annontationCords = (lat: cords.latitude, lon: cords.longitude)
            api.getDailyForecast(lat: cords.latitude, lon: cords.longitude)
            if !slideUp {
                slideUpAnimation()
            }
        }
        
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
    
    //Delegate functions:
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if(viewController is ForecastViewController) {
            
            print(lat,lon)
            guard lat != nil && lon != nil else {
                return;
            }
            locationUpdateDelegate?.locationUpdated(lat: lat!, lon: lon!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        print("Location!")
        print(lat,lon)
    }
    
    func getLocation() -> (lat: Double?, lon: Double?) {
        
        return annontationCords!
    }
    

}

private extension MKMapView {
    func centerOnCords(location: CLLocation, displayRadius: CLLocationDistance = 1000) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: displayRadius, longitudinalMeters: displayRadius)
        setRegion(region, animated: true)
    }
}
