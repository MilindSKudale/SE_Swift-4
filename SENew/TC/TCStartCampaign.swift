//
//  TCStartCampaign.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class TCStartCampaign: UIViewController {

    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var lblCampaignDate : UILabel!
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var btnRemove : UIButton!
    @IBOutlet var btnSelectAll : UIButton!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var noMemberView : UIView!
    
    var arrMemberId = [String]()
    var arrMemberName = [String]()
    var arrMemberEmail = [String]()
    var arrScheduleDate = [String]()
    var arrSelectedMemberId = [String]()
    var txtCampName = ""
    var txtCampId = ""
    var txtMessgageId = ""
    var messageText = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnSave.layer.cornerRadius = 5
        btnSave.clipsToBounds = true
        btnRemove.layer.cornerRadius = 5
        btnRemove.clipsToBounds = true
        lblCampaignTitle.text = txtCampName
        tblMemberList.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionStartCampaign(_ sender:UIButton) {
        let selectedIds = self.arrSelectedMemberId.joined(separator: ",")
        if self.arrSelectedMemberId.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one record to start camapign.")
            return
        }else{
            let alertVC = PMAlertController(title: "", description: "Are you sure you want to start current campaign for selected members?", image: nil, style: .alert)
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            }))
            alertVC.addAction(PMAlertAction(title: "Start", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.startCampaignAPICall(selectedIds:selectedIds)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionRemoveMember(_ sender:UIButton) {
        if self.arrSelectedMemberId.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one member to remove.")
            return
        }
        
        let alertVC = PMAlertController(title: "", description: "Do you really want to remove member from this campaign?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Remove", style: .default, action: { () in
            let selectId = self.arrSelectedMemberId.joined(separator: ",")
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.removeMembers(selectId)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension TCStartCampaign {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":txtCampId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAddedMemberToStartCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrMemberId = []
                self.arrMemberEmail = []
                self.arrMemberName = []
                self.arrScheduleDate = []
                let result = JsonDict!["result"] as! [String : AnyObject]
                self.lblCampaignTitle.text = result["txtCampName"] as? String ?? ""
                self.lblCampaignDate.text = "Text Campaign Created On \(result["campaignDateTime"] as? String ?? "")"
                self.messageText = result["scheduleMessage"] as? String ?? ""
                let emailDetails = result["campaignEmails"] as! [AnyObject]
                if emailDetails.count > 0 {
                    for obj in emailDetails {
                        self.arrMemberId.append(obj.value(forKey: "txtcontactCampaignId") as! String)
                        self.arrMemberEmail.append(obj.value(forKey: "contact_phone") as! String)
                        self.arrMemberName.append(obj.value(forKey: "contact_name") as! String)
                        
                        self.arrScheduleDate.append(obj.value(forKey: "email_addDate") as! String)
                    }
                   // self.btnStartCampaign.isHidden = false
                    self.noMemberView.isHidden = true
                    self.btnSelectAll.isSelected = true
                    self.arrSelectedMemberId = self.arrMemberId
                }else{
                    self.btnSelectAll.isSelected = false
                    self.noMemberView.isHidden = false
                }
                OBJCOM.hideLoader()
            }else{
                self.arrMemberId = []
                self.arrMemberEmail = []
                self.arrMemberName = []
                self.arrScheduleDate = []
                self.arrSelectedMemberId = []
//                self.btnStartCampaign.isHidden = true
                self.btnSelectAll.isSelected = false
                self.noMemberView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblMemberList.reloadData()
        };
    }
    
    func startCampaignAPICall(selectedIds:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":txtCampId,
                         "txtcontactCampaignIds":selectedIds]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "startTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getDataFromServer()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            }else{
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func removeMembers(_ memberId:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtcontactCampaignIds":memberId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeMemberFromStartCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getDataFromServer()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{ OBJCOM.hideLoader() }
        };
    }
}


extension TCStartCampaign : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrMemberName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignedMembersCell
        
        cell.lblName.text = arrMemberName[indexPath.row]
        cell.lblEmail.text = "Phone : \(arrMemberEmail[indexPath.row])"
        cell.configure(name: cell.lblName.text!)
        let selId = self.arrMemberId[indexPath.row]
        if self.arrSelectedMemberId.contains(selId){
            cell.imgSelect.image = #imageLiteral(resourceName: "check")
        }else{
            cell.imgSelect.image = #imageLiteral(resourceName: "uncheck")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selId = self.arrMemberId[indexPath.row]
        if arrSelectedMemberId.contains(selId){
            let index = arrSelectedMemberId.index(of: selId)
            self.arrSelectedMemberId.remove(at: index!)
        }else{
            self.arrSelectedMemberId.append(selId)
        }
        self.tblMemberList.reloadData()
    }
    
    @IBAction func actionSelectAll(_ sender:UIButton) {
        
        if self.arrMemberId.count == 0 {
            return
        }
        if !sender.isSelected {
            arrSelectedMemberId = arrMemberId
            sender.isSelected = true
        }else{
            arrSelectedMemberId = []
            sender.isSelected = false
        }
        self.tblMemberList.reloadData()
    }
}

