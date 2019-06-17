//
//  AddMultipleEmailsToEC.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AddMultipleEmailsToEC: UIViewController {

    @IBOutlet var uiView : UIView!
    @IBOutlet var ddSelectCampaign : UIDropDown!
    @IBOutlet var btnAssignCamp : UIButton!
    
    var arrCampaignTitle = [String]()
    var arrCampaignID = [String]()
    var arrStepCount = [String]()
    
    var campaignId = ""
    var contactsId = ""
    var campaignTitle = ""
    var className = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getEmailCampaignList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func designUI(){
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true
        
        btnAssignCamp.layer.cornerRadius = 5.0
        btnAssignCamp.clipsToBounds = true
    
    }
    
    @IBAction func actionCancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssignCampaign(_ sender:UIButton){
        if campaignTitle == "" {
            OBJCOM.setAlert(_title: "", message: "Please select email campaign.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getEmailScheduleMessage()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            
        }
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
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
                }))
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.assignEmailCampaignToMultipleRecords()
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
}

extension AddMultipleEmailsToEC {
    func getEmailCampaignList() {
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCrmCustomCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignID.append(obj.value(forKey: "campaignId") as! String)
                    self.arrStepCount.append("\(obj.value(forKey: "stepPresent") ?? "1")")
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
        self.ddSelectCampaign.textColor = .black
        self.ddSelectCampaign.tint = APPBLUECOLOR
        self.ddSelectCampaign.optionsSize = 14.0
        self.ddSelectCampaign.placeholder = "Select Email Campaign"
        self.ddSelectCampaign.optionsTextAlignment = NSTextAlignment.left
        self.ddSelectCampaign.textAlignment = NSTextAlignment.left
        self.ddSelectCampaign.options = self.arrCampaignTitle
        self.ddSelectCampaign.rowHeight = 40.0
        self.ddSelectCampaign.tableHeight = 150.0
        self.ddSelectCampaign.hideOptionsWhenSelect = true
        campaignTitle = ""
        self.ddSelectCampaign.didSelect { (item, index) in
            self.campaignTitle = self.arrCampaignTitle[index]
            self.campaignId = self.arrCampaignID[index]
        }
    }
    
    func assignEmailCampaignToMultipleRecords(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":self.campaignId,
                         "contactIds":self.contactsId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "assignMultipleCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let result = JsonDict!["result"] as? String ?? ""
                
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if self.className == "Prospect"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if self.className == "Contact"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                    }else if self.className == "Customer"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                    }else if self.className == "Recruit"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as? String ?? ""
                print("result:",JsonDict ?? "")
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}
