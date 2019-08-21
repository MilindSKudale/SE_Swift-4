//
//  LocationTracker.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/08/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import CoreLocation

var OBJLOC = LocationTracker()

class LocationTracker: NSObject, CLLocationManagerDelegate {

    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var bgtimer = Timer()
    
    var current_time = NSDate().timeIntervalSince1970
    var timer = Timer()
    var f = 0
    private var locman = CLLocationManager()
    private var startTime: Date?
    
    func StartupdateLocation() {
        locman.requestAlwaysAuthorization()
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            
            locman.delegate = self
            locman.startUpdatingLocation()
            locman.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locman.activityType = CLActivityType.otherNavigation
            locman.distanceFilter = 1
            locman.headingFilter = 1
            locman.startMonitoringSignificantLocationChanges()

        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            locman.delegate = self
            locman.startUpdatingLocation()
            locman.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locman.activityType = CLActivityType.otherNavigation
            locman.distanceFilter = 1
            locman.headingFilter = 1
            locman.startMonitoringSignificantLocationChanges()
        case .authorizedWhenInUse:
            locman.delegate = self
            locman.startUpdatingLocation()
            locman.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locman.activityType = CLActivityType.otherNavigation
            locman.distanceFilter = 1
            locman.headingFilter = 1
            locman.startMonitoringSignificantLocationChanges()
        }
    }
    
    func StopUpdateLocation() {
        locman.stopMonitoringSignificantLocationChanges()
//        locman.allowsBackgroundLocationUpdates = false
//        locman.pausesLocationUpdatesAutomatically = true
        locman.stopUpdatingLocation()
    
        if #available(iOS 11.0, *) {
            locman.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while requesting new coordinates")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let _ = manager.location {
            self.latitude = manager.location!.coordinate.latitude
            self.longitude = manager.location!.coordinate.longitude
            let userLocation :CLLocation = locations[0] as CLLocation
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if (error != nil){
                    print("error in reverseGeocode")
                }
                
                if placemarks != nil {
                    print(placemarks as Any)
                    let placeMark = placemarks?.last
                    
                    let dict = ["lat":"\(self.latitude)",
                        "long":"\(self.longitude)",
                        "address":placeMark!.subLocality ?? "",
                        "city":placeMark!.locality ?? "",
                        "state":placeMark!.administrativeArea ?? "",
                        "country":placeMark!.country ?? "",
                        "zipCode":placeMark!.postalCode ?? ""]
                    print(dict)
                    OBJCOM.sendCurrentLocationToServer(dict)
                    self.locman.stopUpdatingLocation()
                }
            }
        }
    }
}

extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

