//
//  ViewController.swift
//  Restaurant Roulette
//
//  Created by Jared Cassoutt on 10/26/20.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var matchingItems = [MKMapItem]()
    let safeLocation = CLLocation(latitude: 0.00, longitude: 0.00)
    var radius = 15
    
    struct Restaurants {
        static var randomlySelected: MKMapItem?
    }
    
    @IBOutlet weak var mainMap: MKMapView!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var randomSelectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        locationManager = CLLocationManager()
        // Ask for Authorisation from the User.
        locationManager?.requestAlwaysAuthorization()
          // For use in foreground
        locationManager?.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
            locationManager?.requestLocation()
            currentLocation = locationManager?.location
        }
        
        radiusSlider.value = Float(radius)
        updateMainMap()
    }

    func milesToMeters(distance: Int) -> Int {
        return Int(distance*1609)
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        radius = Int(sender.value)
        radiusLabel.text = "Radius: \(radius) miles"
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: false)
    }
    
    @IBAction func randomlySelectButton(_ sender: UIButton) {
        randomlySelect()
    }
    
    func randomlySelect() {
        DispatchQueue.main.async {
            self.currentLocation = self.locationManager?.location
            self.getRestaurants(radius: self.milesToMeters(distance: self.radius), location: self.currentLocation ?? self.safeLocation) { restraunts in
                self.matchingItems = restraunts
                self.generateSelectionAlert(restaurant: restraunts.randomElement()!)
            }
        }
    }
    
}


extension ViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
        locationManager?.stopUpdatingLocation()
        UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
        }
    }

    func getRestaurants(radius: Int, location: CLLocation, completion: @escaping ([MKMapItem])->()) {
        //location is the users current location and radius is in meters
        let searchRequest = MKLocalSearch.Request()
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: CLLocationDistance(radius), longitudinalMeters: CLLocationDistance(radius))
        searchRequest.naturalLanguageQuery = "Food"
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            completion(response.mapItems)
        }
    }
    
    func updateMap(view mapView: MKMapView, cornerRadius: Int) {
        mapView.layer.cornerRadius = CGFloat(cornerRadius)
        mapView.camera.centerCoordinate = CLLocationCoordinate2D(latitude: currentLocation?.coordinate.latitude ?? safeLocation.coordinate.latitude, longitude: currentLocation?.coordinate.longitude ?? safeLocation.coordinate.longitude)
        mapView.camera.centerCoordinateDistance = CLLocationDistance(self.milesToMeters(distance: radius))
    }
    
    func updateMainMap() {
        DispatchQueue.main.async {
            self.getRestaurants(radius: self.milesToMeters(distance: self.radius), location: self.currentLocation ?? self.safeLocation) { restraunts in
                self.mainMap.addAnnotations(restraunts.map{$0.placemark})
            }
        }
    }
    
    @objc func timerDidFire(_ sender: Any) {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
                locationManager?.requestLocation()
                currentLocation = locationManager?.location
                DispatchQueue.main.async {
                    self.updateMap(view: self.mainMap, cornerRadius: 15)
                    self.updateMainMap()
                }
            }
        }
    }
}

extension ViewController {
    func generateSelectionAlert(restaurant: MKMapItem) {
        let alert = UIAlertController(title: restaurant.name, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        print(restaurant.description)
        
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
            self.makeCall(restaurant: restaurant)
        }))
        alert.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
            self.getDirections(to: restaurant)
        }))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
            self.randomlySelect()
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        let mapView = MKMapView(frame: CGRect(x: 15, y: 40, width: UIScreen.main.bounds.width-50, height: 190))
        self.updateMap(view: mapView, cornerRadius: 10)
        mapView.addAnnotation(restaurant.placemark)
        alert.view.addSubview(mapView)
    }
    
    func makeCall(restaurant: MKMapItem) {
        if let phoneNumber = restaurant.phoneNumber?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ""),
                let url = URL(string: "telprompt://" + phoneNumber) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Unable to call because number is nil")
            }
    }
    
    func getDirections(to restaurant: MKMapItem) {
        let latitude = restaurant.placemark.coordinate.latitude
        let longitude = restaurant.placemark.coordinate.longitude
        UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/maps?saddr=&daddr=\(latitude),\(longitude)")! as URL)
    }

}

extension UIImage {
    //helper function to access online images from api
    public static func getAt(url: URL, success: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.global().async {
            if let newData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    success(UIImage(data: newData))
                }
            } else {
                DispatchQueue.main.async {
                    success(nil)
                }
            }
        }
    }

}
