//
//  RecruitDetailsView.swift
//  SENew
//
//  Created by Milind Kudale on 09/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class RecruitDetailsView: UIViewController {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var imgTag : UIImageView!
    @IBOutlet var lblEmail : UILabel!
    @IBOutlet var lblPhone : UILabel!
    @IBOutlet var lblAddress : UILabel!
    @IBOutlet var lblCity : UILabel!
    @IBOutlet var lblState : UILabel!
    @IBOutlet var lblCountry : UILabel!
    @IBOutlet var lblZip : UILabel!
    @IBOutlet var lblEC : UILabel!
    @IBOutlet var lblTC : UILabel!
    @IBOutlet var lblGrp : UILabel!
    
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnEdit : UIButton!
    var userEmail = ""
    var contactId = ""
    var crmFlag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
 
    func designUI(){
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        btnEdit.layer.cornerRadius = 5.0
        btnEdit.clipsToBounds = true
        
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        
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
    
    @IBAction func actionCancel(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionEdit(_ sender:UIButton) {
        switch crmFlag {
        case "1":
            let storyboard = UIStoryboard(name: "MyContacts", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditContactView") as! EditContactView
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.contactID = contactId
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            break
        case "2":
            let storyboard = UIStoryboard(name: "MyCustomers", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditCustomerView") as! EditCustomerView
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.contactID = contactId
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            break
        case "3":
            let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditProspectView") as! EditProspectView
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.contactID = contactId
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            break
        case "4":
            let storyboard = UIStoryboard(name: "MyRecruits", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditRecruitView") as! EditRecruitView
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.contactID = contactId
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            break
        default:
            print("Invalid input")
        }
    }
    
    @IBAction func actionAssignCampaign(_ sender:UIButton) {
        if self.userEmail == "" {
            OBJCOM.setAlert(_title: "", message: "Email-id required for assign campaigns")
            return
        }else{
            let name = lblName.text!
            let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddEmailsToEC") as! AddEmailsToEC
            vc.contactId = contactId
            vc.contactName = name
            vc.isGroup = false
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func actionMove(_ sender:UIButton) {
        
        let item1 = ActionSheetItem(title: "My Contacts", value: 1)
        let item2 = ActionSheetItem(title: "My Customers", value: 2)
        let item3 = ActionSheetItem(title: "My Prospects", value: 3)
        let item4 = ActionSheetItem(title: "My Recruits", value: 4)
        let button = ActionSheetOkButton(title: "Dismiss")
        
        var items = [ActionSheetItem]()
        if crmFlag == "1" {
            items = [item2, item3, item4, button]
        }else if crmFlag == "2" {
            items = [item1, item3, item4, button]
        }else if crmFlag == "3" {
            items = [item1, item2, item4, button]
        }else if crmFlag == "4" {
            items = [item1, item2, item3, button]
        }
        
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    self.moveProspect(prospectId: self.contactId, crmFlag:  "1")
                }else if item == item2 {
                    self.moveProspect(prospectId: self.contactId, crmFlag:  "2")
                }else if item == item3 {
                    self.moveProspect(prospectId: self.contactId, crmFlag:  "3")
                }else if item == item4 {
                    self.moveProspect(prospectId: self.contactId, crmFlag:  "4")
                }
            }
        }
        sheet.present(in: self, from: self.view)
        
    }
    
    @IBAction func actionDelete(_ sender:UIButton) {
        let alertVC = PMAlertController(title: "", description: "Do you want to delete this record?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Cancel")
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                let dictParam = ["userId": userID,
                                 "platform":"3",
                                 "contactIds":self.contactId]
                
                let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                let dictParamTemp = ["param":jsonString];
                
                typealias JSONDictionary = [String:Any]
                OBJCOM.modalAPICall(Action: "deleteMultipleRowCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                    JsonDict, staus in
                    let success:String = JsonDict!["IsSuccess"] as! String
                    if success == "true"{
                        let result = JsonDict!["result"] as AnyObject
                        let alertVC = PMAlertController(title: "", description: result as! String, image: nil, style: .alert)
                        
                        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                            if self.crmFlag == "3"{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                            }else if self.crmFlag == "1"{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                            }else if self.crmFlag == "2"{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                            }else if self.crmFlag == "4"{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertVC, animated: true, completion: nil)
                        OBJCOM.hideLoader()
                        
                    }else{
                        print("result:",JsonDict ?? "")
                        OBJCOM.hideLoader()
                    }
                    
                };
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func moveProspect(prospectId: String, crmFlag: String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contactId":prospectId,
                         "newCrmFlag" : crmFlag]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "moveRowCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result as! String, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
}

extension RecruitDetailsView {
    func getDataFromServer(){
        let dictParam = ["userId" : userID,
                         "platform" : "3",
                         "crmFlag" : crmFlag,
                         "contactId" : contactId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCrmDetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as AnyObject
                if data.count > 0 {
                    self.assignedValuesToFields(dict: data)
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func assignedValuesToFields(dict:AnyObject){
        let fname = dict["contact_fname"] as? String ?? ""
        let lname = dict["contact_lname"] as? String ?? ""
        lblName.text = "\(fname) \(lname)"
        
        lblAddress.text = dict["contact_address"] as? String ?? ""
        lblCity.text = dict["contact_city"] as? String ?? ""
        lblState.text = dict["contact_state"] as? String ?? ""
        lblCountry.text = dict["contact_country"] as? String ?? ""
        lblZip.text = dict["contact_zip"] as? String ?? ""
        userEmail = dict["contact_email"] as? String ?? ""
        
        if userEmail != "" {
            lblEmail.text = userEmail
        }else{
            lblEmail.text = "Not determine"
        }
        
        if dict["contact_phone"] as? String ?? "" != "" {
            lblPhone.text = dict["contact_phone"] as? String ?? ""
        }else{
            lblPhone.text = "Not determine"
        }
        
        if lblAddress.text == "" {
            lblAddress.text = "-"
        }
        if lblCity.text == "" {
            lblCity.text = "-"
        }
        if lblState.text == "" {
            lblState.text = "-"
        }
        if lblCountry.text == "" {
            lblCountry.text = "-"
        }
        if lblZip.text == "" {
            lblZip.text = "-"
        }
    
        let category = dict["contact_category_title"] as? String ?? ""
        if category != "" {
            if category == "Green Apple"{
                imgTag.image = #imageLiteral(resourceName: "3")
            }else if category == "Red Apple"{
                imgTag.image = #imageLiteral(resourceName: "1")
            }else if category == "Brown Apple"{
                imgTag.image = #imageLiteral(resourceName: "2")
            }else if category == "Rotten Apple"{
                imgTag.image = #imageLiteral(resourceName: "4")
            }else{
                imgTag.image = #imageLiteral(resourceName: "custom_tag2")
            }
        }else{
            imgTag.image = #imageLiteral(resourceName: "tag_blank")
        }
        
        let arrEC = dict["contact_campaignAssign"] as AnyObject
        if arrEC.count > 0 {
            let strEC = arrEC.componentsJoined(by: ", ")
            lblEC.text = strEC
        }else{
            lblEC.text = "No email campaigns assigned yet!"
        }
        
        let arrTC = dict["contact_txtCampaignAssign"] as AnyObject
        if arrTC.count > 0 {
            let strTC = arrTC.componentsJoined(by: ", ")
            lblTC.text = strTC
        }else{
            lblTC.text = "No text campaigns assigned yet!"
        }
        
        let arrGrp = dict["contact_groupAssign"] as AnyObject
        if arrGrp.count > 0 {
            let strGrp = arrGrp.componentsJoined(by: ", ")
            lblGrp.text = strGrp
        }else{
            lblGrp.text = "No groups assigned yet!"
        }
        
    }
}

extension RecruitDetailsView {
   
}

