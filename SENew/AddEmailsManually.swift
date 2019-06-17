//
//  AddEmailsManually.swift
//  SENew
//
//  Created by Milind Kudale on 10/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AddEmailsManually: UIViewController {

    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var txtFirstname : UITextField!
    @IBOutlet var txtLastname : UITextField!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtGroup : UIDropDown!
    
    
    var arrGroupTitle = [String]()
    var arrGroupID = [String]()
    var groupTitle = ""
    var groupId = ""
    var campaignName = ""
    var campaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnSave.layer.cornerRadius = 5
        btnSave.clipsToBounds = true
        lblCampaignTitle.text = campaignName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender:UIButton) {
        if isValidation() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.checkEmailIsExists(isAdd:"0")
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
}

extension AddEmailsManually {
    func getGroupData() {
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrGroupTitle = []
                self.arrGroupID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrGroupTitle.append(obj.value(forKey: "group_name") as! String)
                    self.arrGroupID.append(obj.value(forKey: "group_id") as! String)
                }
                
                self.loadDropDown()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func loadDropDown() {
        self.txtGroup.textColor = .black
        self.txtGroup.tint = .black
        self.txtGroup.optionsSize = 15.0
        self.txtGroup.placeholder = " Select Group"
        self.txtGroup.optionsTextAlignment = NSTextAlignment.left
        self.txtGroup.textAlignment = NSTextAlignment.left
        self.txtGroup.options = self.arrGroupTitle
        self.txtGroup.hideOptionsWhenSelect = true
        self.txtGroup.didSelect { (item, index) in
            if self.arrGroupTitle.count == 0 {
                OBJCOM.setAlert(_title: "", message: "No groups assigned yet.")
                return
            }
            self.groupTitle = self.arrGroupTitle[index]
            self.groupId = self.arrGroupID[index]
            
        }
    }
    
    func checkEmailIsExists(isAdd:String) {
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "email":txtEmail.text!,
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "checkCampaignAlreadyAssign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                OBJCOM.hideLoader()
                self.getEmailScheduleMessage()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func addEmailAPI(addAndAssinged:String) {
        //getEmailScheduleMessage
//        if callFirst == true {
            let dictParam = ["userId": userID,
                             "platform":"3",
                             "fname":txtFirstname.text!,
                             "lname":txtLastname.text!,
                             "email":txtEmail.text!,
                             "phone":"",
                             "groupId":groupId,
                             "campaignId":campaignId,
                             "addAndAssinged":addAndAssinged]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "assignEmailCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
                JsonDict, staus in
                
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    OBJCOM.hideLoader()
                    let result = JsonDict!["result"] as! String
                    let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        NotificationCenter.default.post(name: Notification.Name("UpdateECTemplateDetails"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                }
            };
//            callFirst = false
//        }
    }
    
    func getEmailScheduleMessage() {
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getEmailScheduleMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
                }))
                alertVC.addAction(PMAlertAction(title: "Proceed", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.addEmailAPI(addAndAssinged: "0")
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func isValidation() -> Bool{
        var isValid = true
        if txtFirstname.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter first name.")
            isValid = false
        }else if txtLastname.text == ""{
            OBJCOM.setAlert(_title: "", message: "Please enter last name.")
            isValid = false
        }else if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email address.")
            isValid = false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address.")
            isValid = false
        }else{
            isValid = true
        }
        
        return isValid
    }
}
