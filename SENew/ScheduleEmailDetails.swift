//
//  ScheduleEmailDetails.swift
//  SENew
//
//  Created by Milind Kudale on 11/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ScheduleEmailDetails: UIViewController {
    
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
            OBJCOM.setAlert(_title: "", message: "Please select atleast one email to delete.")
            return
        }

        let alertVC = PMAlertController(title: "", description: "Are you sure you want to delete this email from current email templates?", image: nil, style: .alert)
        
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
            OBJCOM.setAlert(_title: "", message: "You can not delete this email from current template.")
            return
        }else if self.arrSelectedRecords.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one email to delete.")
            return
        }
        
        let alertVC = PMAlertController(title: "", description: "Are you sure you want to delete this email from current and following email templates?", image: nil, style: .alert)
        
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

extension ScheduleEmailDetails : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrContactName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScheduleDetailsCell
        
        cell.lblName.text = arrContactName[indexPath.row]
        cell.lblEmail.text = "Email : \(arrContactEmail[indexPath.row])"
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

extension ScheduleEmailDetails {
    func getEmailDetails(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId,
                         "campaignStepId":templateId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getStepEmaildetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
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
                
                self.lblCampaignDate.text = "Email template created on : \(result["campaignStepAddDate"] as? String ?? "")"
                
                let emailDetails = result["emailDetails"] as! [AnyObject]
                
                if emailDetails.count > 0 {
                    
                    for obj in emailDetails {
                        self.arrContactId.append(obj.value(forKey: "contactCampaignId") as! String)
                        self.arrContactEmail.append(obj.value(forKey: "contactEmail") as! String)
                        self.arrContactName.append(obj.value(forKey: "contactName") as! String)
                        
                        self.arrReadImg.append(obj.value(forKey: "readImg") as! String)
                        self.arrScheduleDate.append(obj.value(forKey: "scheduleDate") as! String)
                        self.arrStatus.append(obj.value(forKey: "sent") as! String)
                    }
                    self.noMemberView.isHidden = true
                }else{
                    self.noMemberView.isHidden = false
                }
                
                OBJCOM.hideLoader()
            }else{
                self.noMemberView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblMemberList.reloadData()
        };
    }
    
    func deteteAPI() {

        let strEmailId = self.arrSelectedRecords.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "stepCamId":campaignId,
                         "stepid":templateId,
                         "emailDetails":strEmailId]

        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];

        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "notSendToCurrentEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in

            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                print(result)
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getEmailDetails()
                }else{ OBJCOM.NoInternetConnectionCall() }
                
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
                         "stepCamId":campaignId,
                         "stepid":templateId,
                         "emailDetails":strEmailId]

        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];

        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "notSendToCurrentAndFollowingEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in

            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                print(result)
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getEmailDetails()
                }else{ OBJCOM.NoInternetConnectionCall() }
            }else{

                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

class ScheduleDetailsCell: UITableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var lblReadStatus: UILabel!
    @IBOutlet var lblSentStatus: UILabel!
    @IBOutlet var imgSelect: UIImageView!

}
