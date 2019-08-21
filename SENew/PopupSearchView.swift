//
//  PopupSearchView.swift
//  SENew
//
//  Created by Milind Kudale on 15/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import MapKit

class PopupSearchView: BottomPopupViewController {

    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    @IBOutlet var btnCFT : UIButton!
    @IBOutlet var btnLocation : UIButton!
    @IBOutlet var txtCFTSearch : SearchTextField!
    @IBOutlet var txtLocationSearch : SearchTextField!
   // @IBOutlet var viewCft : UIView!
    @IBOutlet var viewbg : UIView!
    @IBOutlet var btnSearch : UIButton!
    
    var arrCftUserName = [String]()
    var arrCftUserId = [Int]()
    var selectedCftUserForSearch = ""
    var isCFT = true
    var CftUserId = ""
    
    var arrLocation = [String]()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var matchingResult:[MKMapItem] = []
    var placeMark:MKPlacemark? = nil
    
    var matchedItem = MKMapItem()
    var itemName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewbg.layer.cornerRadius = 10
        self.viewbg.clipsToBounds = true
        self.txtCFTSearch.isHidden = false
        self.txtLocationSearch.isHidden = true
        self.btnCFT.isSelected = true
        self.btnLocation.isSelected = false
        isCFT = true
        
        self.btnSearch.layer.cornerRadius = 5
        self.btnSearch.clipsToBounds = true
        
        txtCFTSearch.startVisibleWithoutInteraction = false
        txtCFTSearch.filterStrings(self.arrCftUserName)
        
        txtLocationSearch.startVisibleWithoutInteraction = false
        txtLocationSearch.filterStrings(self.arrLocation)
        txtLocationSearch.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        
        // Set the delegate for the Completer
        searchCompleter.delegate = self
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("executeRepeatedly"), object: nil)
        repeatCall = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnSearch(_ sender: UIButton) {
        if isCFT == true {
            if txtCFTSearch.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter CFT user's name.")
            }else{
                let username = self.txtCFTSearch.text
                for item in self.arrCftUserName {
                    if item.lowercased().contains(username!.lowercased()) {
                        let index = self.arrCftUserName.index(of:item)
                        self.CftUserId = "\(self.arrCftUserId[index!])"
                        
                        var dict = [String:AnyObject]()
                        dict = ["type":"byCft",
                                "cftUserId":self.CftUserId,
                                "strLocation":"",
                                "location":""] as [String : AnyObject]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateMap"), object: dict)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }else{
            if self.txtLocationSearch.text != "" {
                
                var searchLoc = CLLocationCoordinate2D()
                coordinates(forAddress: self.txtLocationSearch.text!) {
                    (location) in
                    guard let location = location else {
                        return
                    }
                    searchLoc = location
                    var dict = [String:AnyObject]()
                    dict = ["type":"byLocation",
                            "cftUserId":"",
                            "strLocation":self.txtLocationSearch.text!,
                            "location":searchLoc] as [String : AnyObject]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateMap"), object: dict)
                    self.dismiss(animated: true, completion: nil)
//                    if OBJCOM.isConnectedToNetwork(){
//                        self.getCFTfromLocationSearch (self.txtLocationSearch.text!)
//                    }else{
//                        OBJCOM.NoInternetConnectionCall()
//                    }
                }
                
            }else{
                OBJCOM.setAlert(_title: "", message: "Please enter destination location to find out route.")
            }
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
    
    @IBAction func actionCFTUserSearch(_ sender: UIButton) {
        isCFT = true
        self.txtCFTSearch.isHidden = false
        self.txtLocationSearch.isHidden = true
        self.btnCFT.isSelected = true
        self.btnLocation.isSelected = false
    }
    
    @IBAction func actionLocationSearch(_ sender: UIButton) {
        isCFT = false
        self.txtCFTSearch.isHidden = true
        self.txtLocationSearch.isHidden = false
        self.btnCFT.isSelected = false
        self.btnLocation.isSelected = true
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

extension PopupSearchView: MKLocalSearchCompleterDelegate {
    
    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        
        self.searchResults.removeAll()
        
        // send the text to the completer
        searchCompleter.queryFragment = self.txtLocationSearch.text!
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print(completer.results.description)
        self.arrLocation = []
        searchResults = completer.results
        for obj in searchResults {
            self.arrLocation.append(obj.title)
        }
        print(self.arrLocation)
        txtLocationSearch.filterStrings(self.arrLocation)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
//
//        let title = "Location Update Eroor"
//        let message = "Your location could not be determined"
        
       // OBJCOM.showAlert(_title : title, message: message, fromController: self)
        
    }
}
