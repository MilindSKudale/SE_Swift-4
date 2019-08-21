//
//  AssignedMemberDetails.swift
//  SENew
//
//  Created by Milind Kudale on 10/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AssignedMemberDetails: UIViewController {

    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var lblCampaignDate : UILabel!
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var btnSelectAll : UIButton!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var noMemberView : UIView!
    
    var arrMemberId = [String]()
    var arrMemberName = [String]()
    var arrMemberEmail = [String]()
    var arrAssignedDate = [String]()
    var arrSelectedMemberId = [String]()
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
            self.getMemberDetails()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUnassignMembers(_ sender:UIButton) {
        if self.arrSelectedMemberId.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one email to remove.")
            return
        }
        
        let alertVC = PMAlertController(title: "", description: "Do you really want to unassign member from this campaign?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
            let selectId = self.arrSelectedMemberId.joined(separator: ",")
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.unassignMembers(selectId)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        
        self.present(alertVC, animated: true, completion: nil)
        
        
    }
}

extension AssignedMemberDetails {
    func getMemberDetails(){
        
        if campaignId == "" {
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMemberAssignedToEmailCampaign", param : dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrMemberId = []
            self.arrMemberName = []
            self.arrMemberEmail = []
            self.arrAssignedDate = []
            self.arrSelectedMemberId = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String : AnyObject]
                print(result)
                self.btnSelectAll.isSelected = false
                self.arrSelectedMemberId = []
                self.lblCampaignTitle.text = result["campaignTitle"] as? String ?? self.campaignName
                self.lblCampaignDate.text = "Email campaign created on \(result["campaignDateTime"] as? String ?? "")"
                let memberDetails = result["memberDetails"] as! [AnyObject]
                
                for obj in memberDetails {
                    self.arrMemberName.append(obj.value(forKey: "contact_name") as! String)
                    self.arrMemberEmail.append(obj.value(forKey: "contact_email") as! String)
                    self.arrMemberId.append(obj.value(forKey: "contactCampaignId") as! String)
                    self.arrAssignedDate.append(obj.value(forKey: "contactCampaignDate") as! String)
                }
                self.noMemberView.isHidden = true
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.btnSelectAll.isSelected = false
                self.arrSelectedMemberId = []
                let campDetails = JsonDict!["responseCampDetails"] as! [String : AnyObject]
                self.lblCampaignTitle.text = self.campaignName
                self.lblCampaignDate.text = "Email campaign created on \(campDetails["campaignDateTime"] as? String ?? "")"
                self.noMemberView.isHidden = false
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
                
            }
            
        };
    }
    
    func unassignMembers(_ memberId:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignIds":memberId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeMemberFromGivenEmailCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? "Email removed from given email campaign!"
                OBJCOM.setAlert(_title: "", message: result)
                print(result)
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getMemberDetails()
                }else{ OBJCOM.NoInternetConnectionCall() }
            }else{ OBJCOM.hideLoader() }
        };
    }
}

extension AssignedMemberDetails : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrMemberName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignedMembersCell
        
        cell.lblName.text = arrMemberName[indexPath.row]
        cell.lblEmail.text = "Email : \(arrMemberEmail[indexPath.row])"
        cell.lblPhone.text = "Assigned on : \(arrAssignedDate[indexPath.row])"
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


class AssignedMembersCell: UITableViewCell {
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var imgSelect: UIImageView!
    
    func configure(name: String) {
        lblName?.text = name
        imgUser?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgUser?.image = nil
        lblName?.text = nil
    }
}
