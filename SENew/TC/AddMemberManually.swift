//
//  AddMemberManually.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AddMemberManually: UIViewController, UITextFieldDelegate {

    @IBOutlet var bgView : UIView!
    @IBOutlet var lblCampTitle : UILabel!
    @IBOutlet var txtFirstName : UITextField!
    @IBOutlet var txtLastName : UITextField!
    @IBOutlet var txtMobile : UITextField!
    @IBOutlet var btnAdd : UIButton!
    @IBOutlet var btnAddAndStartCamp : UIButton!
    
    var txtCampName = ""
    var txtCampId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAdd.layer.cornerRadius = 5.0
        btnAddAndStartCamp.layer.cornerRadius = 5.0
        
        bgView.clipsToBounds = true
        btnAdd.clipsToBounds = true
        btnAddAndStartCamp.clipsToBounds = true
        
        txtMobile.delegate = self
        lblCampTitle.text = txtCampName
    }

    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssign(_ sender:UIButton){
        if Validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForAddMemberManually("0")
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionAddAndStartCampaign(_ sender:UIButton){
        if Validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForAddMemberManually("1")
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
}

extension AddMemberManually {
    func apiCallForAddMemberManually(_ addAndAssinged:String){
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtcontactMainCampaignId":self.txtCampId,
                         "fname":self.txtFirstName.text!,
                         "lname":self.txtLastName.text!,
                         "email": "",
                         "phone":self.txtMobile.text!,
                         "addAndAssinged":addAndAssinged] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addMemberManually", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateTCTemplateDetails"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    func Validate() -> Bool {
        if txtFirstName.text == "" && txtLastName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter either first name or last name.")
            OBJCOM.hideLoader()
            return false
        }else if txtMobile.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter phone number.")
            OBJCOM.hideLoader()
            return false
        }else if txtMobile.text != "" {
            if txtMobile.text!.length < 5 || txtMobile.text!.length > 19 {
                OBJCOM.setAlert(_title: "", message: "Phone number should be greater than or equal to 5 digits and less than or equal to 19 digits.")
                OBJCOM.hideLoader()
                return false
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let set = NSCharacterSet(charactersIn: "0123456789+- ().,;'").inverted
        if textField == txtMobile  {
            return string.rangeOfCharacter(from: set) == nil
        }
        return true
    }
}
