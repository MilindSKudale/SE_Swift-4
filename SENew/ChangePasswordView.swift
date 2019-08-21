//
//  ChangePasswordView.swift
//  SENew
//
//  Created by Milind Kudale on 21/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ChangePasswordView: UIViewController {

    @IBOutlet var txtCurrentPass : UITextField!
    @IBOutlet var txtNewPass : UITextField!
    @IBOutlet var txtConfirmPass : UITextField!
    @IBOutlet var btnUpdatePass : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdatePass.layer.cornerRadius = 5.0
        btnUpdatePass.clipsToBounds = true
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPassword(_ sender:UIButton){
        
        if validatePassword() == true {
            var dictParam = [String:String]()
            dictParam["user_id"] = userID
            dictParam["oldpassword"] = txtCurrentPass.text ?? ""
            dictParam["newpassword"] = txtNewPass.text ?? ""
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "updatePassword", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    //
                    OBJCOM.hideLoader()
                    let alertVC = PMAlertController(title: "", description: "Your current session will be get logged out. Make sure your new Log In credentials are correct. Please Log In again.", image: nil, style: .alert)
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        UserDefaults.standard.removeObject(forKey: "USERINFO")
                        UserDefaults.standard.synchronize()
                        let appDelegate = AppDelegate.shared
                        appDelegate.setRootVC()
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
    
    func validatePassword() -> Bool {
        if txtCurrentPass.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter current password.")
            return false
        }else if txtCurrentPass.text!.length < 5 {
            OBJCOM.setAlert(_title: "", message: "Current password should be greater than or equal to 5 characters.")
            return false
        } else if txtNewPass.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter new password.")
            return false
        } else if txtNewPass.text!.length < 5 {
            OBJCOM.setAlert(_title: "", message: "New password should be greater than or equal to 5 characters.")
            return false
        } else if txtConfirmPass.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter confirm password.")
            return false
        } else if txtConfirmPass.text != txtNewPass.text {
            OBJCOM.setAlert(_title: "", message: "New password and confirm password does not match. New password and confirm password fields must be same.")
            return false
        }
        return true
    }

}
