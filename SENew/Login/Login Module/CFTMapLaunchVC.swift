//
//  CFTMapLaunchVC.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import MapKit

class CFTMapLaunchVC: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView : MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.callGetAllCFT()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    }
    
    @IBAction func actionContinueToLogin(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idLoginView") as! LoginView
        //isCFTMap = true
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
}
extension CFTMapLaunchVC {
    func callGetAllCFT(){
        
        let dictParam = ["platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllCftLocation", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print("result:",result)
                for obj in result {
                    let strLat = Double(obj["userLatitude"] as! String)
                    let strLong = Double(obj["userLongitude"] as! String)
                    let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "2")"
                    
                    let center = CLLocationCoordinate2D(latitude: strLat!, longitude: strLong!)
//
                    self.mapView.setCenter(center, animated: true)
                    
                    if userStatus == "2" {
                        let annotation = ColorPointAnnotation(pinColor:.red)
                        annotation.coordinate = center
                        annotation.title = "CFT"
                        annotation.pinColor = .red
                        self.mapView.addAnnotation(annotation)
//                        let info1 = cftAnnotation(coordinate: center)
//                        info1.titlecft = "CFT"
//                        info1.pinImage = #imageLiteral(resourceName: "red_ic")
//                        self.mapView.addAnnotation(info1)
                    }else{
                        let annotation = ColorPointAnnotation(pinColor:.green)
                        annotation.coordinate = center
                        annotation.title = "CFT"
                        annotation.pinColor = .green
                        self.mapView.addAnnotation(annotation)
//                        let info1 = cftAnnotation(coordinate: center)
//                        info1.titlecft = "CFT"
//                        info1.pinImage = #imageLiteral(resourceName: "green_ic")
//                        self.mapView.addAnnotation(info1)
                    }
                }
                OBJCOM.hideLoader()
            }else{
               
                OBJCOM.hideLoader()
            }
        };
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
       // let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation")  as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
          //  annotationView!.pinTintColor = .purple
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
       
        if let cpa = annotation as? ColorPointAnnotation {
            annotationView?.pinTintColor = cpa.pinColor
        }
        return annotationView
    }
}
class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}

class cftAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var titlecft : String!
    var pinImage: UIImage!
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
