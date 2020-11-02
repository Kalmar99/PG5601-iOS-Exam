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

class MapsViewController: UIViewController, CLLocationManagerDelegate,UITabBarControllerDelegate {
    
    @IBOutlet weak var mapView : MKMapView!;
    @IBOutlet weak var switchButton : UISwitch!;
    @IBOutlet weak var weatherDetails: WeatherDetails!;
    
    var lat: Double? = nil
    var lon: Double? = nil
    
    var locationUpdateDelegate: locationUpdateDelegate?
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Map"

        //Configure location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0;
        locationManager.delegate = self;
        
        tabBarController?.delegate = self;
        
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
    
    @IBAction func longPressAddAnnotation(sender: UILongPressGestureRecognizer) {
        
        if(sender.state == .began) {
            
            //Get location
            let location = sender.location(in: mapView)
            let cords = mapView.convert(location, toCoordinateFrom: mapView)
            
            //Remove old annotations
            mapView.removeAnnotations(mapView.annotations)
            
            let point = MapPoint(title: "Selected",locationName: "User Selected", coordinate: cords)
            mapView.addAnnotation(point)
            
            getLocationData(lat: cords.latitude, lon: cords.longitude)
            
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
    
    func getLocationData(lat: Double, lon: Double) {
        let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
        fetcher.getWeatherByCords(lat: lat, lon: lon) { (result) in
            switch(result) {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.weatherDetails.updateData(lat: lat, lon: lon, data: data.hours[0])
                    }
                case .failure(let error):
                    print(error)
        }}
    }
    
    //Delegate functions:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if(viewController is ForecastViewController) {
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
