//
//  Feedback.swift
//  SENew
//
//  Created by Milind Kudale on 21/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class Feedback: UIViewController {

    @IBOutlet var txtName : UITextField!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPhone : UITextField!
    @IBOutlet var btnFeedback : UIButton!
    @IBOutlet var btnSupport : UIButton!
    @IBOutlet var txtDesc : GrowingTextView!
    @IBOutlet var btnSend : UIButton!
    var emailType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.layer.cornerRadius = 5.0
        btnSend.clipsToBounds = true
        btnFeedback.isSelected = true
        btnSupport.isSelected = false
        emailType = "Feedback"
    }
    
    @IBAction func btnFeedback(_ sender: UIButton) {
        btnFeedback.isSelected = true
        btnSupport.isSelected = false
        emailType = "Feedback"
    }
    
    @IBAction func btnSupport(_ sender: UIButton) {
        btnFeedback.isSelected = false
        btnSupport.isSelected = true
        emailType = "support"
    }
    
    @IBAction func actionSend(_ sender: UIButton) {
        if validate() == true {
            apiCallForSendFeedback()
        }
    }
    
    func apiCallForSendFeedback(){
        
        if validate() == true {
            let dictParam = ["user_id": userID,
                             "name":txtName.text!,
                             "email": txtEmail.text!,
                             "message":txtDesc.text!,
                             "mail_type": emailType,
                             "phone": txtPhone.text!] as [String : String]
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "sendFeedback", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    self.txtName.text = ""
                    self.txtEmail.text = ""
                    self.txtPhone.text = ""
                    self.txtDesc.text = ""
                    
                    self.btnFeedback.isSelected = true
                    self.btnSupport.isSelected = false
                    self.emailType = "Feedback"
                    
                    OBJCOM.hideLoader()
                }else{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            };
        }
    }
    
    func validate() -> Bool {
        
        if txtName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter name.")
            return false
        }else if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email address.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address.")
            return false
        }else if txtPhone.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter phone number.")
            return false
        }else if (txtPhone.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than or equal to 5 digits.")
            return false
        }else if (txtPhone.text?.length)! > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be less than or equal to 19 digits.")
            return false
        }else if emailType == "" {
            OBJCOM.setAlert(_title: "", message: "Please select mail type.")
            return false
        }else if txtDesc.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter your message.")
            return false
        }
        
        return true
    }

}
