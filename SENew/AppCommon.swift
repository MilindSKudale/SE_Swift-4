//
//  AppCommon.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class AppCommon: UIViewController , URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var window: UIWindow?
    private var parameters:[String:AnyObject]?
    var _headers : HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        _headers["Accept"] = "application/json, text/json, text/javascript, text/html"
    }
    
    func modalAPICall(Action: String,param : [String : AnyObject]?, vcObject:UIViewController, completionHandler: @escaping ([String:Any]?, Int?) -> ()){
        let BaselUrl = (SITEURL+"\(Action)")
        parameters = param
        print("BaselUrl : ", BaselUrl)
        print("parameters : ", parameters ?? "parameter missing")
        
        Alamofire.request(BaselUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: _headers).responseJSON(completionHandler:{ response in
            
            switch response.result {
            case .success(_):
                print(response.result.value as Any)
                let  JSON : [String:Any]
                if let json = response.result.value {
                    JSON = json as! [String : Any]
                    completionHandler(JSON , 1)
                }
            case .failure(let error):
                print(error)
                self.hideLoader()
            }
        })
    }
    
    func getPackagesInfo(){
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            if userData.count > 0 {
                userID = userData["zo_user_id"] as? String ?? ""
                let dictParam = ["userId": userID,
                                 "platform":"3"]
                
                let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                let dictParamTemp = ["param":jsonString];
                
                typealias JSONDictionary = [String:Any]
                OBJCOM.modalAPICall(Action: "customizeModuleList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                    JsonDict, staus in
                    
                    arrModuleList = []
                    arrModuleId = []
                    
                    let success:String = JsonDict!["IsSuccess"] as? String ?? ""
                    if success == "true"{
                        if let result = JsonDict!["result"] as? [AnyObject] {
                            arrModuleList = result.compactMap { $0["moduleName"] as? String }
                            arrModuleId = result.compactMap { $0["moduleId"] as? String }
                            
                            UserDefaults.standard.set(arrModuleId, forKey: "PACKAGES")
                            UserDefaults.standard.set(arrModuleList, forKey: "PACKAGESNAME")
                            UserDefaults.standard.synchronize()
                        }
                        
                        if let showMenuList = JsonDict!["showMenuList"] as? [AnyObject] {
                            arrMyToolsModuleList = showMenuList.compactMap { $0["moduleName"] as? String }
                            arrMyToolsModuleId = showMenuList.compactMap { $0["moduleId"] as? String }
                        }
                        
                    }else{
                        OBJCOM.hideLoader()
                    }
                };
            }
        }
    }
    
    func NoInternetConnectionCall() {
        self.hideLoader()
       
        let alertVC = PMAlertController(title: "", description: "Make sure your device is connected to the internet.", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: nil))
        self.window?.rootViewController?.present(alertVC, animated: true, completion: nil)
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    
    
    func isConnectedToNetwork() -> Bool {
        if Reachability.connectedToNetwork() == true {
            return true
        } else {
            return false
        }
    }
    
    func showNetworkAlert(){
        
        self.hideLoader()
        self.setAlert(_title: "", message: "Make sure your device is connected to the internet.")
        
    }
    
    func setAlert(_title : String, message : String){
        let alertVC = PMAlertController(title: _title, description: message, image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: nil))
        topMostController().present(alertVC, animated: true, completion: nil)
    }
    
    func setLoader() {
        SKActivityIndicator.spinnerColor(APPORANGECOLOR)
        SKActivityIndicator.statusTextColor(APPGRAYCOLOR)
        SKActivityIndicator.statusLabelFont(UIFont.boldSystemFont (ofSize: 15.0))
        SKActivityIndicator.spinnerStyle(.spinningCircle)
        SKActivityIndicator.show("Please wait...", userInteractionStatus: false)
    }
    
    func hideLoader() {
        SKActivityIndicator.dismiss()
    }
    
    func popUp(context ctx: UIViewController, msg: String) {
        
        let toast = UILabel(frame:
            CGRect(x: 20, y: ctx.view.frame.size.height / 2,
                   width: ctx.view.frame.size.width - 40, height: 60))
        
        toast.backgroundColor = UIColor.black
        toast.textColor = UIColor.white
        toast.textAlignment = .center;
        toast.numberOfLines = 0
        toast.lineBreakMode = .byWordWrapping
        toast.font = UIFont.systemFont(ofSize: 15)
        toast.layer.cornerRadius = 10;
        toast.clipsToBounds  =  true
        toast.text = msg
        
        ctx.view.addSubview(toast)
        
        UIView.animate(withDuration: 2.0, delay: 1.5,
                       options: .curveEaseOut, animations: {
                        toast.alpha = 0.0
        }, completion: {(isCompleted) in
            toast.removeFromSuperview()
        })
    }
    
    func validateEmail(uiObj:String)  -> Bool{
        var isValidEmail: Bool {
            do {
                let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
                return regex.firstMatch(in: uiObj, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, uiObj.count)) != nil
            } catch {
                print("Mail not valid");
                return false;
            }
        }
        return isValidEmail;
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func importCSVfile(_ file:Data, filename:String, crmFlag:String, completionHandler: @escaping ([String:Any]?) -> ()) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "contact_flag":crmFlag]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)importCsvCrmAndroid", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
        print(URL2)
        print(parameters)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData as Data, withName: "upload", fileName: filename, mimeType: "text/plain")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, with: URL2 , encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    if let JsonDict = response.result.value as? [String : Any]{
                        print(JsonDict)
                        completionHandler(JsonDict)
                        self.hideLoader()
                    }else {
                        OBJCOM.setAlert(_title: "", message: "Failed to import file.")
                        self.hideLoader()
                    }
                }
            case .failure(_):
                self.hideLoader()
                break
            }
        })
    }
    
    func setImages(imageURL: String, imgView:UIImageView) {
        Alamofire.request(imageURL).responseImage { response in
            
            if let image = response.result.value {
                imgView.image = image
            }else{
                imgView.image = #imageLiteral(resourceName: "no_image")
            }
        } 
    }
    
    func setProfileImages(imageURL: String, imgView:UIImageView) {
        Alamofire.request(imageURL).responseImage { response in
            imgView.contentMode = .scaleToFill
            if let image = response.result.value {
                imgView.image = image
            }else{
                imgView.image = #imageLiteral(resourceName: "profile")
            }
        }
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: dt)
    }
    
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
            print("API CALL ==================\n \(success) ")
            OBJCOM.hideLoader()
        };
    }
    
    func sendUDIDToServer(_ deviceId: String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "deviceId":deviceId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateDeviceForPushNotification", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                print(result)
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
}
