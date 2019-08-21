//
//  EditAccessSetting.swift
//  SENew
//
//  Created by Milind Kudale on 16/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class EditAccessSetting: UIViewController {

    @IBOutlet var lblName : UILabel!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var btnCalender : UIButton!
    @IBOutlet var btnWeeklyScore : UIButton!
    @IBOutlet var btnSave : UIButton!
    
    var accessImage : [UIImage] = [#imageLiteral(resourceName: "cal"), #imageLiteral(resourceName: "card")]
    var arrSelectedModule = [String]()
    var accessData = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.accessData)
        loadViewDesign()
    }

    
    func loadViewDesign(){
        
        lblName.text = self.accessData["userNameReq"] as? String ?? ""
        txtEmail.text = self.accessData["userEmailReq"] as? String ?? ""
        arrSelectedModule = self.accessData["accessModule"] as! [String]
        
        for _ in 0 ..< arrSelectedModule.count {
            if arrSelectedModule.contains("1"){
                btnWeeklyScore.isSelected = true
            }else{
                btnWeeklyScore.isSelected = false
            }
            
            if arrSelectedModule.contains("2"){
                btnCalender.isSelected = true
            }else{
                btnCalender.isSelected = false
            }
        }
        btnSave.layer.cornerRadius = 5.0
        btnSave.clipsToBounds = true
    
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSetCalender(_ sender:UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
            if arrSelectedModule.contains("2") {
                let index = arrSelectedModule.index(of: "2")
                arrSelectedModule.remove(at: index!)
            }
        }else{
            sender.isSelected = true
            if arrSelectedModule.contains("2") == false {
                arrSelectedModule.append("2")
            }
        }
    }
    
    @IBAction func actionSetWSC(_ sender:UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
            if arrSelectedModule.contains("1") {
                let index = arrSelectedModule.index(of: "1")
                arrSelectedModule.remove(at: index!)
            }
        }else{
            sender.isSelected = true
            if arrSelectedModule.contains("1") == false {
                arrSelectedModule.append("1")
            }
        }
    }
    
    @IBAction func actionSendRequest(_ sender:UIButton){
        
        let strModule = self.arrSelectedModule.joined(separator: ",")
        print(strModule)
        if validate() == true {
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSendAccessRequest(strModule)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func apiCallForSendAccessRequest(_ module : String){
        
        let accessId = self.accessData["accessId"] as? String ?? ""
        if accessId == "" {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId": accessId,
                         "moduleName":module]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "changeAccess", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateUI"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func validate() -> Bool {
        
        if self.arrSelectedModule.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one access module to send request.")
            return false
        }
        
        return true
    }

}
