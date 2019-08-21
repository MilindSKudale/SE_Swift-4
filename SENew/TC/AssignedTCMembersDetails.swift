//
//  AssignedMemberDetails.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AssignedTCMembersDetails: UIViewController {

    @IBOutlet var lblCampaignTitle : UILabel!
    //@IBOutlet var lblCampaignDate : UILabel!
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var btnSelectAll : UIButton!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var noMemberView : UIView!
    
    var arrMemberId = [String]()
    var arrMemberName = [String]()
    var arrMemberPhone = [String]()
    //var arrAssignedDate = [String]()
    var arrSelectedMemberId = [String]()
    var txtCampName = ""
    var txtCampId = ""
    var txtMessgageId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnSave.layer.cornerRadius = 5
        btnSave.clipsToBounds = true
        lblCampaignTitle.text = txtCampName
        tblMemberList.tableFooterView = UIView()
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
            OBJCOM.setAlert(_title: "", message: "Please select atleast one member to remove.")
            return
        }

        let alertVC = PMAlertController(title: "", description: "Do you really want to unassign member from this campaign?", image: nil, style: .alert)

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

extension AssignedTCMembersDetails {
    func getMemberDetails(){
        
        if txtCampId == "" {
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":txtCampId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMemberAssignedToTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrMemberId = []
            self.arrMemberName = []
            self.arrMemberPhone = []
            self.arrSelectedMemberId = []
            self.btnSelectAll.isSelected = false
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String : AnyObject]
                print(result)
                self.noMemberView.isHidden =  false
                self.lblCampaignTitle.text = result["txtCampName"] as? String ?? ""
//                self.lblCampaignDate.text = "Text campaign created on \(result["txtCampName"] as? String ?? "")"
                let memberDetails = result["memberDetails"] as! [AnyObject]
                
                for obj in memberDetails {
                    self.arrMemberName.append(obj.value(forKey: "contact_name") as! String)
                    self.arrMemberPhone.append(obj.value(forKey: "contact_phone") as! String)
                    self.arrMemberId.append(obj.value(forKey: "txtcontactCampaignId") as! String)
                }
                if memberDetails.count > 0 {
                    self.noMemberView.isHidden = true
                }else{
                    self.noMemberView.isHidden = false
                }
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noMemberView.isHidden =  false
                self.tblMemberList.reloadData()
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
        OBJCOM.modalAPICall(Action: "removeMemberFromGivenTextCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? "Member(s) removed from given text campaign!"
                
                OBJCOM.setAlert(_title: "", message: result)
                print(result)
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    DispatchQueue.main.async {
                        self.getMemberDetails()
                    }
                }else{ OBJCOM.NoInternetConnectionCall() }
            }else{ OBJCOM.hideLoader() }
        };
    }
}

extension AssignedTCMembersDetails : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrMemberName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignedMembersCell
        
        cell.lblName.text = arrMemberName[indexPath.row]
        cell.lblEmail.text = "Phone : \(arrMemberPhone[indexPath.row])"
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

