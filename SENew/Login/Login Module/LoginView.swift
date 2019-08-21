//
//  ViewController.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import  Contacts

var arrModuleList =  [String]()
var arrModuleId =  [String]()
var arrMyToolsModuleList =  [String]()
var arrMyToolsModuleId =  [String]()

class LoginView: UIViewController {

    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var btnSecure : UIButton!
    
    var flags = true
    var window : UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPassword.isSecureTextEntry = true
        btnSecure.isSelected = false
    }
}

extension LoginView{
    @IBAction func actionForgotPassword(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idForgotPasswordVC") as! ForgotPasswordVC
        //isCFTMap = true
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionLogin(_ sender:UIButton){
        if validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.callLoginAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func validate() -> Bool {
        if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email to login.")
            return false
        } else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email to login.")
            return false
        } else if txtPassword.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter password to login.")
            return false
        }
        return true
    }
    
    @IBAction func actionHideShowPassword(_ sender:UIButton){
        if sender.isSelected {
            self.txtPassword.isSecureTextEntry = true
            btnSecure.isSelected = false
        }else{
            self.txtPassword.isSecureTextEntry = false
            btnSecure.isSelected = true
        }
    }
}


extension LoginView {
    func callLoginAPI(){
        
        let dictParam = ["email": txtEmail.text!,
                         "password":txtPassword.text!]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "login", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                let motiFlag = JsonDict!["motivationalFlag"] as! String

                if motiFlag == "yes" {
                    UserDefaults.standard.set("true", forKey: "MOTIVATIONAL")
                }else{
                    UserDefaults.standard.set("false", forKey: "MOTIVATIONAL")
                }
                
                UserDefaults.standard.set(result[0], forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                userID = userData["zo_user_id"] as! String
//                isOnboard = JsonDict!["IsGoalSetSuccess"] as! String
                
//                if deviceTokenId != "" {
//                    OBJCOM.sendUDIDToServer(deviceTokenId)
//                }
                
//                isFirstTimeChecklist = true
//                isFirstTimeEmailCampaign = true
//                isFirstTimeCftLocator = true
//                isFirstTimeTextCampaign = true
                
                selectedCellIndex = 1
                UITextField().resignFirstResponder()
                DispatchQueue.main.async(execute: {
                    OBJCOM.getPackagesInfo()
                    self.fetchAllContacts()
                    let appDelegate = AppDelegate.shared
                    appDelegate.setRootVC()
                    OBJCOM.hideLoader()
                })
                // OBJLOC.StartupdateLocation()
            }else{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func fetchAllContacts(){
        var arrContacts = [String]()
        for item in getContacts() {
            if item.isKeyAvailable(CNContactPhoneNumbersKey){
                let phoneNOs=item.phoneNumbers
                let _:String
                for item in phoneNOs{
                    arrContacts.append(item.value.stringValue)
                }
            }
        }
        UserDefaults.standard.set(arrContacts, forKey: "ALL_CONTACTS")
        UserDefaults.standard.synchronize()
    }

    func getContacts() -> [CNContact] {

        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]

        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }

        var results: [CNContact] = []

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
}

extension UIApplicationDelegate {
    static var shared: Self {
        return UIApplication.shared.delegate! as! Self
    }
}

