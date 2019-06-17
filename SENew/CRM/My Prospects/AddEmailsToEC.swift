//
//  AddEmailsToEC.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AddEmailsToEC: UIViewController {

    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var DDSelectCampaign : UIDropDown!
    @IBOutlet var btnAssign : UIButton!
    @IBOutlet var lblContactName : UILabel!
    @IBOutlet var tblAssignedCamp : UITableView!
    @IBOutlet var bgView : UIView!

    var arrCampaignTitle = [String]()
    var arrCampaignId = [AnyObject]()
    var arrAvailCampaign = [String]()
    var arrUnAssignCampaignTitle = [String]()
    var arrUnAssignCampaignId = [AnyObject]()
    var arrAddedCampaignTitle = [String]()
    var arrAddedCampaignId = [AnyObject]()
    var campaignTitle = ""
    var campaignId = ""
    var contactId = ""
    var contactName = ""
    var isGroup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAssign.clipsToBounds = true
        tblAssignedCamp.tableFooterView = UIView()
        
        if isGroup == true {
            lblTitle.text = "Add group to 'Email Campaigns'"
        }else{
            lblTitle.text = "Add email to 'Email Campaigns'"
        }
        
        lblContactName.text = contactName
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func loadDropDown() {
        self.DDSelectCampaign.textColor = .black
        self.DDSelectCampaign.tint = APPBLUECOLOR
        self.DDSelectCampaign.optionsSize = 14.0
        self.DDSelectCampaign.placeholder = "Select email campaign"
        self.DDSelectCampaign.optionsTextAlignment = NSTextAlignment.left
        self.DDSelectCampaign.textAlignment = NSTextAlignment.left
        self.DDSelectCampaign.options = self.arrCampaignTitle
        self.DDSelectCampaign.hideOptionsWhenSelect = true
        self.DDSelectCampaign.tableHeight = 150.0
        campaignTitle = ""
        self.DDSelectCampaign.didSelect { (item, index) in
            self.campaignTitle = self.arrCampaignTitle[index]
            self.campaignId = self.arrCampaignId[index] as! String
        }
    }

    @IBAction func actionCancel(_ sender : UIButton){
        NotificationCenter.default.post(name: Notification.Name("UpdateProspectList"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssignCampaign(_ sender : UIButton){
        if campaignTitle != "" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getEmailScheduleMessage()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.hideLoader()
            OBJCOM.setAlert(_title: "", message: "Please select email campaign to assign.")
        }
    }
    
    @objc func actionUnAssignCampaign(_ sender : UIButton){
        let assignId = arrUnAssignCampaignId[sender.tag]
        
        let alertVC = PMAlertController(title: "", description: "Do you want to unassign selected campaign?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            
        }))
        alertVC.addAction(PMAlertAction(title: "Unassign", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.UnAssignCampaign(assignId:assignId as! String)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func actionDeleteCampaign(_ sender : UIButton){
        let assignId = self.arrAddedCampaignId[sender.tag]
        
        let alertVC = PMAlertController(title: "", description: "Do you want to delete selected campaign?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.removeCampaign(assignId: assignId as! String)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
//    @IBAction func actionSelectCampaign(_ sender : UIButton){
//        if self.arrCampaignTitle.count > 0 {
//            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            for i in 0..<self.arrCampaignTitle.count{
//                alert.addAction(UIAlertAction(title: self.arrCampaignTitle[i], style: .default , handler:{ (UIAlertAction)in
//                    self.campaignTitle = self.arrCampaignTitle[i]
//                    self.campaignId = "\(self.arrCampaignId[i])"
//                    self.btnSelectCampaign.setTitle(self.campaignTitle, for: .normal)
//                }))
//            }
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
}

extension AddEmailsToEC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrUnAssignCampaignTitle.count == 0 {
            return 1
        }else{
            return arrUnAssignCampaignTitle.count
        }
        //        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblAssignedCamp.dequeueReusableCell(withIdentifier: "Cell") as! AssignCampaignCell
        
        if arrUnAssignCampaignTitle.count == 0 {
            cell.lblCampaignName.text = "No email campaign(s) assigned yet!"
            cell.lblCampaignName.textColor = .red
            cell.btnUnAssignCampaign.isHidden = true
        }else{
            cell.btnUnAssignCampaign.isHidden = false
            cell.lblCampaignName.textColor = .black
            cell.lblCampaignName.text = self.arrUnAssignCampaignTitle[indexPath.row]
            cell.btnUnAssignCampaign.setImage(UIImage(named: "ic_btnUnassign"), for: .normal)
            cell.btnUnAssignCampaign.tag = indexPath.row
            cell.btnUnAssignCampaign.addTarget(self, action: #selector(actionUnAssignCampaign(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
   
}

extension AddEmailsToEC {
    func getDataFromServer() {
        var dictParam = [String:String]()
        
        if isGroup == true {
            dictParam = ["userId": userID,
                         "platform":"3",
                         "groupId":contactId]
        }else{
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactId":contactId]
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCrmAssignUnassignCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                let campData = result["assingCamp"] as! [AnyObject]
                let unAssignCampData = result["unAssingCamp"] as! [AnyObject]
                //let addedCampData = result["addedCamp"] as! [AnyObject]
                
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                self.arrAvailCampaign = []
                
                for obj in campData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "campaignId") as AnyObject)
                    self.arrAvailCampaign.append("\(obj.value(forKey: "campaignTemplateExits") ?? "1")")
                }
                self.arrUnAssignCampaignId = []
                self.arrUnAssignCampaignTitle = []
                for obj in unAssignCampData {
                    self.arrUnAssignCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrUnAssignCampaignId.append(obj.value(forKey: "contactCampaignId") as AnyObject)
                }
                
                //                self.arrAddedCampaignId = []
                //                self.arrAddedCampaignTitle = []
                //                for obj in addedCampData {
                //                    self.arrAddedCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                //                    self.arrAddedCampaignId.append(obj.value(forKey: "contactCampaignId") as AnyObject)
                //                }
                
                OBJCOM.hideLoader()
                self.loadDropDown()
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblAssignedCamp.reloadData()
        };
    }
    
    func UnAssignCampaign(assignId : String) {
        var dictParam  = [String:String]()
        if isGroup == true {
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignId":assignId,
                         "fromGroup" : "1"]
        }else{
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignId":assignId]
        }
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "unAssignCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    self.getDataFromServer()
                }))
                self.present(alertVC, animated: true, completion: nil)
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func removeCampaign(assignId : String) {
        var dictParam  = [String:String]()
        if isGroup == true {
            return
        }else{
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignId":assignId]
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    self.getDataFromServer()
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func AssignCampaign() {
        
        if campaignTitle != "" {
            var dictParam = [String:String]()
            if isGroup == true {
                dictParam = ["userId": userID,
                             "platform":"3",
                             "groupId":contactId,
                             "campaignId":campaignId]
            }else{
                dictParam = ["userId": userID,
                             "platform":"3",
                             "contactId":contactId,
                             "campaignId":campaignId]
            }
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "assignCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as! String
                    print(result)
                    let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        self.getDataFromServer()
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                    OBJCOM.hideLoader()
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                }
            };
            
        }else{
            OBJCOM.hideLoader()
            OBJCOM.setAlert(_title: "", message: "Please select email campaign to assign.")
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
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
                   
                }))
                alertVC.addAction(PMAlertAction(title: "Proceed", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.AssignCampaign()
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
