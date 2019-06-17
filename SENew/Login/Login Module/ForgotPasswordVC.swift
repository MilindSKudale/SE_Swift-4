//
//  ForgotPasswordVC.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet var txtEmail : UITextField!
    var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flag = true
    }
}

extension ForgotPasswordVC {
    
    @IBAction func actionSubmit(_ sender:UIButton) {
        
        if validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.callForgotPasswordAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionCancel(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        
        if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email to reset password.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email to reset password.")
            return false
        }
        
        return true
    }
    
    func callForgotPasswordAPI(){
        
        let dictParam = ["email": txtEmail.text!]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "forgot_password", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let ResponseMessage = JsonDict!["ResponseMessage"] as? String ??
                "We could not find an account with this email address"
                UserDefaults.standard.removeObject(forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if self.flag == true {
                        self.flag = false
                        let appDelegate = AppDelegate.shared
                        appDelegate.setRootVC()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
                
                
            }else{
                if self.flag == true {
                    self.flag = false
                    let result = JsonDict!["ResponseMessage"] as? String ?? "We could not find an account with this email address"
                    OBJCOM.setAlert(_title: "", message: result)
                }
                OBJCOM.hideLoader()
            }
        };
    }
}
