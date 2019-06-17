//
//  SetSelfReminder.swift
//  SENew
//
//  Created by Milind Kudale on 11/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class SetSelfReminder: UIViewController {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnSetSelfReminder : UIButton!
    @IBOutlet var btnEmail : UIButton!
    @IBOutlet var btnEmailAndSms : UIButton!
    @IBOutlet var txtInterval : UITextField!
    @IBOutlet var btnIntervalType : UIButton!
    @IBOutlet var txtNotes : GrowingTextView!
    var intervalType = ""
    var reminderType = ""
    var campaignId = ""
    var isUpdate = false
    var templateId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        btnSetSelfReminder.layer.cornerRadius = 5
        bgView.clipsToBounds = true
        btnSetSelfReminder.clipsToBounds = true
        
        if isUpdate {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.getTemplateDetails()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            btnSetSelfReminder.setTitle("Update self reminder", for: .normal)
        }else{
            
            self.updateRadioButton(btnEmail)
            reminderType = "1"
            intervalType = ""
            btnIntervalType.setTitle("Select", for: .normal)
            btnSetSelfReminder.setTitle("Set self reminder", for: .normal)
        }
        
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSetEmail(_ sender:UIButton) {
        self.updateRadioButton(btnEmail)
        reminderType = "1"
    }
    
    @IBAction func actionSetEmailAndSms(_ sender:UIButton) {
        self.updateRadioButton(btnEmailAndSms)
        reminderType = "2"
    }
    
    @IBAction func actionSetIntervalType(_ sender:UIButton) {
        let item1 = ActionSheetItem(title: "Days", value: 1)
        let item2 = ActionSheetItem(title: "Weeks", value: 2)
        let item3 = ActionSheetItem(title: "Months", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, item3, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                
                if item == item1 {
                    self.intervalType = "days"
                }else if item == item2 {
                    self.intervalType = "week"
                }else if item == item3 {
                    self.intervalType = "month"
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    
    @IBAction func actionSetSelfReminder(_ sender:UIButton) {
        if txtInterval.text == "0" || txtInterval.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please select interval time.")
        }else if intervalType == "" {
            OBJCOM.setAlert(_title: "", message: "Please select interval type.")
        }else{
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    if self.isUpdate == false{
                        self.setSelfReminderAPI(action:"addSelfEmailTemplate")
                    }else{
                        self.updateSelfReminderAPI(action:"updateSelfEmailTemplate")
                    }
                    
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func updateRadioButton(_ sender:UIButton) {
        self.btnEmail.isSelected = false
        self.btnEmailAndSms.isSelected = false
        sender.isSelected = true
    }
    
}


extension SetSelfReminder {
    func setSelfReminderAPI(action:String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepCamId":campaignId,
                         "campaignStepSendTo":reminderType,
                         "campaignStepSendInterval":self.txtInterval.text!,
                         "campaignStepSendIntervalType":intervalType,
                         "campaignStepContent":txtNotes.text!]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateECTemplateDetails"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateSelfReminderAPI(action:String){
       
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepId":templateId,
                         "campaignStepSendTo":reminderType,
                         "campaignStepSendInterval":txtInterval.text!,
                         "campaignStepSendIntervalType":intervalType,
                         "campaignStepContent":txtNotes.text!]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateECTemplateDetails"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getTemplateDetails(){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "stepId":templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getEmailTemplateById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]
                OBJCOM.hideLoader()
                print(result)
                self.reminderType = result["campaignStepSendTo"] as? String ?? ""
                if self.reminderType == "1"{
                    self.btnEmail.isSelected = true
                    self.btnEmailAndSms.isSelected = false
                }else{
                    self.btnEmail.isSelected = false
                    self.btnEmailAndSms.isSelected = true
                }
                self.txtInterval.text = result["campaignStepSendInterval"] as? String ?? ""
                self.intervalType = result["campaignStepSendIntervalType"] as? String ?? ""
                self.txtNotes.text = result["campaignStepContent"] as? String ?? ""
                self.btnIntervalType.setTitle(self.intervalType, for: .normal)
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
}
