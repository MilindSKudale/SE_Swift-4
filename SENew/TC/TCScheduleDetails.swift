//
//  TCScheduleDetails.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class TCScheduleDetails: UIViewController {

    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var lblCampaignDate : UILabel!
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var btnDeleteAllFollow : UIButton!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var noMemberView : UIView!
    
    var arrContactId = [String]()
    var arrContactEmail = [String]()
    var arrContactName = [String]()
    var arrReadImg = [String]()
    var arrScheduleDate = [String]()
    var arrStatus = [String]()
    var arrSelectedRecords = [String]()
    
    var templateName = ""
    var templateId = ""
    var campaignId = ""
    var isRepeateTemplate = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.layer.cornerRadius = 10
        btnDelete.layer.cornerRadius = 5
        btnDeleteAllFollow.layer.cornerRadius = 5
        
        bgView.clipsToBounds = true
        btnDelete.clipsToBounds = true
        btnDeleteAllFollow.clipsToBounds = true
        
        lblCampaignTitle.text = templateName
        self.lblCampaignDate.text = "Email template created on :"
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailDetails()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDelete(_ sender:UIButton) {
        if self.arrSelectedRecords.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one member to delete.")
            return
        }
        
        let alertVC = PMAlertController(title: "", description: "Are you sure you want to delete this member from current text message?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.deteteAPI()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func actionDeleteAllFollowing(_ sender:UIButton) {
        
        if self.isRepeateTemplate == "Repeat" {
            OBJCOM.setAlert(_title: "", message: "You can not delete this member from current text message.")
            return
        }else if self.arrSelectedRecords.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one member to delete.")
            return
        }
        
        let alertVC = PMAlertController(title: "", description: "Are you sure you want to delete this member from current and following text message?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.deteteAllFollowingAPI()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }

}

extension TCScheduleDetails : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrContactName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScheduleDetailsCell
        
        cell.lblName.text = arrContactName[indexPath.row]
        cell.lblEmail.text = "Phone : \(arrContactEmail[indexPath.row])"
        cell.lblPhone.text = "Scheduled on : \(arrScheduleDate[indexPath.row])"
        let selId = self.arrContactId[indexPath.row]
        if self.arrSelectedRecords.contains(selId){
            cell.imgSelect.image = #imageLiteral(resourceName: "check")
        }else{
            cell.imgSelect.image = #imageLiteral(resourceName: "uncheck")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selId = self.arrContactId[indexPath.row]
        if arrSelectedRecords.contains(selId){
            let index = arrSelectedRecords.index(of: selId)
            self.arrSelectedRecords.remove(at: index!)
        }else{
            self.arrSelectedRecords.append(selId)
        }
        self.tblMemberList.reloadData()
    }
}

extension TCScheduleDetails {
    func getEmailDetails(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtTemplateId":templateId,
                         "txtTemplateCampId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTxtMsgAssigndetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrContactId = []
            self.arrContactEmail = []
            self.arrContactName = []
            
            self.arrReadImg = []
            self.arrScheduleDate = []
            self.arrStatus = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String : AnyObject]
                print(result)
                self.lblCampaignTitle.text = result["campaignStepTitle"] as? String ?? ""
                self.lblCampaignDate.text = "Text message created on : \(result["txtTemplateAddDate"] as? String ?? "")"
                
                let emailDetails = result["memberDetails"] as! [AnyObject]
                
                if emailDetails.count > 0 {
                    
                    for obj in emailDetails {
                        self.arrContactId.append(obj.value(forKey: "txtcontactCampaignId") as! String)
                        self.arrContactEmail.append(obj.value(forKey: "contactPhone") as! String)
                        self.arrContactName.append(obj.value(forKey: "contactName") as! String)
                        
                        self.arrReadImg.append(obj.value(forKey: "readImg") as! String)
                        self.arrScheduleDate.append(obj.value(forKey: "scheduleDate") as! String)
                        
                        self.arrStatus.append(obj.value(forKey: "sent") as! String)
                    }
                    self.noMemberView.isHidden = true
                }else{
                    self.noMemberView.isHidden = false
                }
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.tblMemberList.reloadData()
                self.noMemberView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func deteteAPI() {
        
        let strEmailId = self.arrSelectedRecords.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtTemplateId":templateId,
                         "txtTemplateCampId":campaignId,
                         "emailDetails":strEmailId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "notSendToCurrentTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getEmailDetails()
                    }else{ OBJCOM.NoInternetConnectionCall() }
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func deteteAllFollowingAPI() {
        
        let strEmailId = self.arrSelectedRecords.joined(separator: ",")
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtTemplateCampId":campaignId,
                         "txtTemplateId":templateId,
                         "emailDetails":strEmailId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "notSendToCurrentAndFollowingTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getEmailDetails()
                    }else{ OBJCOM.NoInternetConnectionCall() }
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
