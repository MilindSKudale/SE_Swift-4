//
//  RouteAndDirectionView.swift
//  SENew
//
//  Created by Milind Kudale on 15/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import MapKit

class RouteAndDirectionView: BottomPopupViewController {

    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    @IBOutlet var txtSource : UITextField!
    @IBOutlet var txtDest : UITextField!
    @IBOutlet var btnFindRoute : UIButton!
    
    var sourceLocation = ""
    var currentCoord = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnFindRoute.layer.cornerRadius = 5
        self.btnFindRoute.clipsToBounds = true
        self.txtSource.isUserInteractionEnabled = false
        self.txtSource.text = sourceLocation
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("executeRepeatedly"), object: nil)
        repeatCall = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionFindRoute(_ sender: UIButton) {
        if self.txtDest.text != "" {
    
            var destLoc = CLLocationCoordinate2D()
            coordinates(forAddress: self.txtDest.text!) {
                (location) in
                guard let location = location else {
                    return
                }
                destLoc = location
                self.openAppleNavigationMap(self.currentCoord, destLoc)
            }
           
        }else{
            OBJCOM.setAlert(_title: "", message: "Please enter destination location to find out route.")
        }
    }
    
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    func openAppleNavigationMap(_ strSource : CLLocationCoordinate2D, _ strDest:CLLocationCoordinate2D){
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: strSource.latitude, longitude:  strSource.longitude)))
        source.name = sourceLocation

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: strDest.latitude, longitude: strDest.longitude)))
        destination.name = self.txtDest.text

        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    override func getPopupHeight() -> CGFloat {
        return height ?? CGFloat(300)
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
}
