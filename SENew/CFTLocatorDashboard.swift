//
//  CFTLocatorDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 14/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import AlamofireImage
import Sheeeeeeeeet
import Instructions

var repeatCall = false

class CFTLocatorDashboard: BottomPopupViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var statusView : UIView!
    @IBOutlet var btnCurrentPosi : UIButton!
    @IBOutlet var btnFindRoute : UIButton!
    @IBOutlet var btnSearch : UIBarButtonItem!
    @IBOutlet var btnMore : UIBarButtonItem!
    
    @IBOutlet var switchStatus : PVSwitch!
    @IBOutlet weak var map: MKMapView!
    var myLocation:CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    let annotation = MKPointAnnotation()

    var arrCftUserName = [String]()
    var arrCftUserId = [Int]()
    var currentCoord = CLLocationCoordinate2D()
    var strCurrentLoc = ""
    var cftStatus = ""
    var cftDisplayFlagAll = ""
    
    let coachMarksController = CoachMarksController()
    let pointOfInterest = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                
                let alertVC = PMAlertController(title: "Allow Location Access", description: "Success Entellus needs access to your location. Turn on Location Services in your device settings.", image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
                
                alertVC.addAction(PMAlertAction(title: "Settings", style: .default, action: { () in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse:
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.startUpdatingLocation()
                }
                
                map.delegate = self
                map.mapType = .standard
                map.isZoomEnabled = true
                map.isScrollEnabled = true
                
                if let coor = map.userLocation.location?.coordinate{
                    map.setCenter(coor, animated: true)
                }
                repeatCall = true
                self.executeRepeatedly()
            }
        } else {
            print("Location services are not enabled")
        }
        
//        self.coachMarksController.dataSource = self
//        let skipView = CoachMarkSkipDefaultView()
//        skipView.setTitle("Skip", for: .normal)
//
//        self.coachMarksController.skipView = skipView
//        self.coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.5)
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.coachMarksController.start(in: .window(over: self))
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCFTStatus()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        map.showsUserLocation = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        map.showsUserLocation = false
        self.coachMarksController.stop(immediately: true)
    }
    
    public func executeRepeatedly() {
        if repeatCall == true {
            if OBJCOM.isConnectedToNetwork(){
                self.getCFTfromCurrentLocation("", "")
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1800.0) { [weak self] in
                self?.executeRepeatedly()
            }
        }else{
            return
        }
    }
    
    @objc func callExecuteReapeate(notification: NSNotification){
        repeatCall = true
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCFTStatus()
            self.executeRepeatedly()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionMoveOnCurrentLoc(_ sender:UIButton){
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func actionFindRouteAndDirection(_ sender:UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callExecuteReapeate),
            name: NSNotification.Name(rawValue: "executeRepeatedly"),
            object: nil)
        repeatCall = false
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "idRouteAndDirectionView") as? RouteAndDirectionView else { return }
        popupVC.sourceLocation = self.strCurrentLoc
        popupVC.currentCoord = self.currentCoord
        popupVC.height = 260
        popupVC.topCornerRadius = 20
        popupVC.presentDuration = 0.5
        popupVC.dismissDuration = 0.5
        popupVC.popupDelegate = self
        
        present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func actionSearch(_ sender:AnyObject){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callExecuteReapeate),
            name: NSNotification.Name(rawValue: "executeRepeatedly"),
            object: nil)
        repeatCall = false
        if arrCftUserName.count > 0 {
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateMap),
                name: NSNotification.Name(rawValue: "UpdateMap"),
                object: nil)
            
            guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "idPopupSearchView") as? PopupSearchView else { return }
            popupVC.arrCftUserName = self.arrCftUserName
            popupVC.arrCftUserId = self.arrCftUserId
            popupVC.height = self.map.frame.height
            popupVC.topCornerRadius = 10
            popupVC.presentDuration = 0.5
            popupVC.dismissDuration = 0.5
            popupVC.popupDelegate = self
            present(popupVC, animated: true, completion: nil)
        }
    }
    
    func centerMap(_ center:CLLocationCoordinate2D){
        let spanX = 0.07
        let spanY = 0.07
        self.getAddressFromLatLon(pdblLatitude: "\(center.latitude)", withLongitude: "\(center.longitude)")
        
        let newRegion = MKCoordinateRegion(center:center , span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
        map.setRegion(newRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentCoord = manager.location!.coordinate
        centerMap(locValue)
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        
        if let cpa = annotation as? mskAnnotation {
            annotationView?.image = cpa.pinImage
        }
        if let cpo = annotation as? officeAnnotation {
            annotationView?.image = cpo.offpinImage
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            return
        }
        // 2
        if view.annotation is mskAnnotation {
            let msk = view.annotation as! mskAnnotation
            let views = Bundle.main.loadNibNamed("CustomInfoWindow", owner: nil, options: nil)
            let calloutView = views?[0] as! CustomInfoWindow
            calloutView.lblName.text = msk.name
            calloutView.lblEmail.text = msk.email
            calloutView.lblPhone.text = msk.phone
            calloutView.lblDistance.text = msk.distance
            calloutView.lblTimeStamp.text = msk.timestamp
            OBJCOM.setProfileImages(imageURL: msk.userImage, imgView: calloutView.imgProfile!)
            calloutView.imgProfile.layer.cornerRadius = calloutView.imgProfile.frame.height/2
            calloutView.imgProfile.clipsToBounds = true
        
            calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height/2+10)
            
            view.addSubview(calloutView)
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        }else if view.annotation is officeAnnotation {
            let off = view.annotation as! officeAnnotation
            let views = Bundle.main.loadNibNamed("AddressInfoWindow", owner: nil, options: nil)
            let calloutView = views?[0] as! AddressInfoWindow
            calloutView.lblOfficeName.text = off.offname
            calloutView.lblEmail.text = off.offemail
            calloutView.lblDistance.text = off.offdistance
            calloutView.lblAddress.text = off.offaddress
            calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height/2+10)
            view.addSubview(calloutView)
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
            
        }
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let placeMark = placemarks?.last
                    let address = placeMark!.subLocality ?? ""
                    let city = placeMark!.locality ?? ""
                    let state = placeMark!.administrativeArea ?? ""
                    let country = placeMark!.country ?? ""
                    let zipCode = placeMark!.postalCode ?? ""
                    
                    let dict = ["lat":"\(center.latitude)",
                                "long":"\(center.longitude)",
                                "address":address,
                                "city":city,
                                "state":state,
                                "country":country,
                                "zipCode":zipCode]
                    print(dict)
                    self.strCurrentLoc = "\(address), \(city), \(state), \(country), \(zipCode)"
                    DispatchQueue.main.async {
                        self.getCFTfromCurrentLocation("","")
                        self.sendCurrentLocationToServer(dict)
                    }
                    
                }
        })
    }
}

extension CFTLocatorDashboard {
    func sendCurrentLocationToServer(_ dict:[String:String]) {
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "userLatitude":dict["lat"],
                         "userLongitude":dict["long"],
                         "userAddress":dict["address"],
                         "userCity":dict["city"],
                         "userState":dict["state"],
                         "userCountry":dict["country"],
                         "userZipcode":dict["zipCode"]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCurrentLocationUser", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                OBJCOM.hideLoader()
            } else {
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCFTfromCurrentLocation(_ lat : String, _ long : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "userLatitude":lat,
                         "userLongitude":long]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftLocationsFromUserLoc", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            self.arrCftUserName = []
            self.arrCftUserId = []
          
            
            if let result = JsonDict!["result"] as? [AnyObject] {
                print("result:",result)
            
                for obj in result {
                    let strLat = Double(obj["userLatitude"] as! String)
                    let strLong = Double(obj["userLongitude"] as! String)
                    let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "1")"
                    
                    let cftName = "\(obj["first_name"] as? String ?? "") \(obj["last_name"] as? String ?? "")"
                    self.arrCftUserName.append(cftName)
                    let i = Int("\(obj["zo_user_id"] as! String)")
                    self.arrCftUserId.append(i!)
                    
                    let coordinates = CLLocationCoordinate2D(latitude:strLat!
                        , longitude:strLong!)
                    
                    let coordinate₀ = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    let coordinate₁ = CLLocation(latitude: self.currentCoord.latitude, longitude: self.currentCoord.longitude)
                    
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMile = distanceInMeters/1609
                    let distanceInMiles =   String(format: "%.2f", distanceInMile)
                    
                    if userStatus == "2" {

                        let info1 = mskAnnotation(coordinate: coordinates)
                        info1.name = cftName
                        info1.email = obj["email"] as? String ?? ""
                        info1.phone = obj["phone"] as? String ?? ""
                        info1.distance = "\(distanceInMiles) miles"
                        info1.timestamp = "Last updated : \(obj["userLocationDate"] as? String ?? "")"
                        info1.pinImage = #imageLiteral(resourceName: "red_ic")
                        info1.pinColor = .red
                        info1.isSelect = false
                        info1.userImage = obj["profile_pic"] as? String ?? ""
                        self.map.addAnnotation(info1)
                        
                    }else{
                        let info1 = mskAnnotation(coordinate: coordinates)
                        info1.name = cftName
                        info1.email = obj["email"] as? String ?? ""
                        info1.phone = obj["phone"] as? String ?? ""
                        info1.distance = "\(distanceInMiles) miles"
                        info1.timestamp = "Last updated : \(obj["userLocationDate"] as? String ?? "")"
                        info1.pinImage = #imageLiteral(resourceName: "green_ic")
                        info1.pinColor = .green
                        info1.isSelect = false
                        info1.userImage = obj["profile_pic"] as? String ?? ""
                        self.map.addAnnotation(info1)
                    }
                }
            }
            if let cftOffices = JsonDict!["cftOffices"] as? [AnyObject] {
                for office in cftOffices {
                    let strLat = Double(office["cftOfficeLatitude"] as? String ?? "")
                    let strLong = Double(office["cftOfficeLongitude"] as? String ?? "")

                    let coordinates = CLLocationCoordinate2D(latitude:strLat!
                        , longitude:strLong!)
                    let coordinate₀ = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    let coordinate₁ = CLLocation(latitude: self.currentCoord.latitude, longitude: self.currentCoord.longitude)
                    
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMile = distanceInMeters/1609
                    let distanceInMiles =   String(format: "%.2f", distanceInMile)
                    
                    let info1 = officeAnnotation(coordinate: coordinates)
                    info1.offname = office["cftOfficeName"] as? String ?? ""
                    info1.offemail = "Email/phone : \(office["cftOfficeEmail"] as? String ?? "")"
                    info1.offdistance = "Distance : \(distanceInMiles) miles"
                    info1.offaddress = "Address : \(office["cftOfficeAddress"] as? String ?? "")"
                    info1.offpinImage = #imageLiteral(resourceName: "ic_office")
                    self.map.addAnnotation(info1)
                }
            }
            OBJCOM.hideLoader()
        };
    }
    
    func getCFTUserSearch(_ cftUserId : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "searchUserId":cftUserId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftUserLocationOnSearch", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                if let result = JsonDict!["result"] as? [AnyObject] {
                    for obj in result {
                        
                        let strLat = Double(obj["userLatitude"] as! String)
                        let strLong = Double(obj["userLongitude"] as! String)
                        let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "1")"
                        
                        let cftName = "\(obj["first_name"] as? String ?? "") \(obj["last_name"] as? String ?? "")"
//                        self.arrCftUserName.append(cftName)
//                        let i = Int("\(obj["zo_user_id"] as! String)")
//                        self.arrCftUserId.append(i!)
                        
                        let coordinates = CLLocationCoordinate2D(latitude:strLat!
                            , longitude:strLong!)
                        
                        let coordinate₀ = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        let coordinate₁ = CLLocation(latitude: self.currentCoord.latitude, longitude: self.currentCoord.longitude)
                        
                        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                        let distanceInMile = distanceInMeters/1609
                        let distanceInMiles =   String(format: "%.2f", distanceInMile)
                        
                        if userStatus == "2" {
                            
                            let info1 = mskAnnotation(coordinate: coordinates)
                            info1.name = cftName
                            info1.email = obj["email"] as? String ?? ""
                            info1.phone = obj["phone"] as? String ?? ""
                            info1.distance = "\(distanceInMiles) miles"
                            info1.timestamp = "Last updated : \(obj["userLocationDate"] as? String ?? "")"
                            info1.pinImage = #imageLiteral(resourceName: "red_ic")
                            info1.userImage = obj["profile_pic"] as? String ?? ""
                            info1.isSelect = true
                            self.map.addAnnotation(info1)
                            self.map.selectAnnotation(info1, animated: true)
                        }else{
                            let info1 = mskAnnotation(coordinate: coordinates)
                            info1.name = cftName
                            info1.email = obj["email"] as? String ?? ""
                            info1.phone = obj["phone"] as? String ?? ""
                            info1.distance = "\(distanceInMiles) miles"
                            info1.timestamp = "Last updated : \(obj["userLocationDate"] as? String ?? "")"
                            info1.pinImage = #imageLiteral(resourceName: "green_ic")
                            info1.userImage = obj["profile_pic"] as? String ?? ""
                            info1.isSelect = true
                            self.map.addAnnotation(info1)
                            self.map.selectAnnotation(info1, animated: true)
                        }
                    }
                }
                OBJCOM.hideLoader()
            } else {
                OBJCOM.hideLoader()
            }
        };
    }
}

extension CFTLocatorDashboard {
    
    @IBAction func actionMoreOptions(_ sender:AnyObject){
        let item1 = ActionSheetItem(title: "Privacy Options", value: 1)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                   
                    let storyboard = UIStoryboard(name: "CFTLocator", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idPrivacyOptionView") as! PrivacyOptionView
                    vc.cftDisplayFlagAll = self.cftDisplayFlagAll
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionUpdateCFTStatus(_ sender:PVSwitch){
        if sender.isOn {
            self.updateCFTStatus("1")
        } else {
            self.updateCFTStatus("2")
        }
    }
    
    func getCFTStatus(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftActiveStatus", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                let result = JsonDict!["result"] as! String
                print("result:",result)
                if result == "1"{
                    self.switchStatus.isOn = true
                    self.cftStatus = "1"
                }else{
                    self.switchStatus.isOn = false
                    self.cftStatus = "2"
                }
                self.cftDisplayFlagAll = JsonDict!["cftDisplayFlagAll"] as? String ?? "0"
                OBJCOM.hideLoader()
            } else {
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateCFTStatus(_ status:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftActiveStatus":status]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateCftStatus", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }
}

extension CFTLocatorDashboard : BottomPopupDelegate {
    
    func bottomPopupViewLoaded() {
        print("bottomPopupViewLoaded")
    }
    
    func bottomPopupWillAppear() {
        print("bottomPopupWillAppear")
    }
    
    func bottomPopupDidAppear() {
        print("bottomPopupDidAppear")
    }
    
    func bottomPopupWillDismiss() {
        print("bottomPopupWillDismiss")
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupDidDismiss")
    }
    
    func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat) {
        print("bottomPopupDismissInteractionPercentChanged fromValue: \(oldValue) to: \(newValue)")
    }
    
    @objc func UpdateMap(notification: NSNotification){
        print(notification.object!)
        let fileData = notification.object as! [String:AnyObject]
        print(fileData["type"] as Any)
        print(fileData["cftUserId"] as Any)
        print(fileData["location"] as Any)
        let type = fileData["type"] as? String ?? ""
        if type == "byCft" {
            let cftId = fileData["cftUserId"] as? String ?? ""
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getCFTUserSearch(cftId)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            
        }else if type == "byLocation" {
            print(fileData["strLocation"] as? String ?? "")
            print(fileData["location"] as Any)
            centerMap(fileData["location"] as! CLLocationCoordinate2D)
        }
        
    }
}


class mskAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var email: String!
    var distance: String!
    var timestamp: String!
    var userImage: String!
    var pinImage: UIImage!
    var isSelect: Bool!
    var pinColor: UIColor!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class officeAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var offname: String!
    var offemail: String!
    var offaddress: String!
    var offdistance: String!
    var offpinImage: UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class AnnotationView: MKAnnotationView
{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point)
                if isInside
                {
                    break
                }
            }
        }
        return isInside
    }
}

//// coachmarks
//extension CFTLocatorDashboard : CoachMarksControllerDataSource, CoachMarksControllerDelegate {
//    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
//        return 5
//    }
//    
//    
//    
//    func coachMarksController(_ coachMarksController: CoachMarksController,
//                              coachMarkAt index: Int) -> CoachMark {
//        switch(index) {
//        case 0:
//            return coachMarksController.helper.makeCoachMark(for: statusView)
//        case 1:
//            return coachMarksController.helper.makeCoachMark(for: btnFindRoute)
//        case 2:
//            return coachMarksController.helper.makeCoachMark(for: btnCurrentPosi)
//        case 3:
//           
//            if let buttonItem = navigationItem.rightBarButtonItems?.first {
//                let buttonItemView = buttonItem.value(forKey: "view") as? UIView
//                return coachMarksController.helper.makeCoachMark(for: buttonItemView)
//            }else{
//                return coachMarksController.helper.makeCoachMark()
//            }
//
//        case 4:
//          
//            if let buttonItem = navigationItem.rightBarButtonItems?.last {
//                let buttonItemView = buttonItem.value(forKey: "view") as? UIView
//                return coachMarksController.helper.makeCoachMark(for: buttonItemView)
//            }else{
//                return coachMarksController.helper.makeCoachMark()
//            }
//        default:
//            return coachMarksController.helper.makeCoachMark()
//        }
//        
//    }
//    
//    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
//        
//        var hintText = ""
//        
//        switch(index) {
//        case 0:
//            hintText = "Turn ON/OFF your CFT locator availability. "
//        case 1:
//            hintText = "By clicking here, you can find route between source and destination."
//        case 2:
//            hintText = "By clicking here, navigate on your current location."
//            
//        case 3:
//            hintText = "By clicking here, navigate on your current location."
//        case 4:
//            hintText = "By clicking here, navigate on your current location."
//        
//        default: break
//        }
//        
//        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation, hintText: hintText, nextText: "Next")
//        coachViews.bodyView.nextLabel.textColor = APPORANGECOLOR
//        coachViews.bodyView.hintLabel.textColor = APPBLUECOLOR
//        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
//    }
//}
