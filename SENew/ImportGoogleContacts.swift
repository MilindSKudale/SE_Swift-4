//
//  ImportGoogleContacts.swift
//  SENew
//
//  Created by Milind Kudale on 09/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn
import Alamofire
import SwiftyJSON

var accountMail = ""

class ImportGoogleContacts: UIViewController {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var noData : UIView!
    @IBOutlet var btnSelectAll : UIButton!
   // @IBOutlet var btnSignIn : UIButton!
    
    private let service = GTLRGmailService()
    //fileprivate var networkController : NetworkController!
    fileprivate var accessToken : String?
    
    var arrTitle = [String]()
    var arrEmail = [String]()
    var arrSelectedContacts = [String]()
    var dictSelectedContacts = [[String:AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.google.com/m8/feeds","https://www.googleapis.com/auth/contacts.readonly"];
        
        GIDSignIn.sharedInstance().signIn()
        //btnSignIn.setTitle("Sign In", for: .normal)
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionImportGoogleContacts(_ sender:UIButton){
        print(self.dictSelectedContacts)
        if self.dictSelectedContacts.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one contact.")
            return
        }
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.importGoogleContacts(items: self.dictSelectedContacts)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

}

extension ImportGoogleContacts : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! SystemContactCell
        
        if self.arrSelectedContacts.contains (self.arrEmail[indexPath.row]){
            cell.imgSelect.image = #imageLiteral(resourceName: "check")
        }else{
            cell.imgSelect.image = #imageLiteral(resourceName: "uncheck")
        }
        
        cell.lblUserName.text = self.arrTitle[indexPath.row]
        cell.configure(name: cell.lblUserName.text!)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrEmail[indexPath.row] == "Not available" {
            OBJCOM.setAlert(_title: "", message: "Email address is not available.")
            return
        }
        let arrName = arrTitle[indexPath.row].components(separatedBy: " ")
        var fName = ""
        var lName = ""
        if arrName.count > 0 && arrName.count < 2 {
            fName = arrName[0]
            lName = ""
        }else if arrName.count > 0 && arrName.count >= 2 {
            fName = arrName[0]
            lName = arrName[1]
        }
        
        let dict = ["contact_other_email": "",
                    "contact_phone": "",
                    "contact_company_name": "",
                    "contact_country": "",
                    "contact_description": "",
                    "contact_lname": fName,
                    "contact_work_email": "",
                    "contact_flag": "1",
                    "contact_other_phone": "",
                    "contact_users_id": userID,
                    "contact_work_phone": "",
                    "contact_fname": lName,
                    "contact_address": "",
                    "contact_city": "",
                    "contact_state": "",
                    "contact_zip": "",
                    "contact_platform": "3",
                    "contact_email": arrEmail[indexPath.row]]
        
        if self.arrSelectedContacts.contains(arrEmail[indexPath.row]) {
            let index = self.arrSelectedContacts.index(of: arrEmail[indexPath.row])
            self.arrSelectedContacts.remove(at: index!)
            self.dictSelectedContacts.remove(at: index!)
        }else{
            self.dictSelectedContacts.append(dict as [String : AnyObject])
            self.arrSelectedContacts.append(arrEmail[indexPath.row])
        }
        self.tblList.reloadData()
    }
    
}

extension ImportGoogleContacts : GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if user == nil {
            OBJCOM.setAlert(_title: "", message: error.localizedDescription)
           // btnSignIn.setTitle("Sign In", for: .normal)
            OBJCOM.hideLoader()
            return
        }
        
        let urlString = "https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=500&access_token=\(user.authentication.accessToken!)&v=3.0"
        
        print(GIDSignIn.sharedInstance().scopes)
        Alamofire.request(urlString, method: .get)
            .responseJSON { response in
                
                accountMail = user.profile.email
               // self.btnSignIn.setTitle("Sign Out", for: .normal)
                switch response.result {
                case .success( _):
                    do{
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[]) as! [String : AnyObject]
                        if let res = json["feed"]!["entry"] as? [[String: Any]] {
                            print(res)
                            self.arrTitle = []
                            self.arrEmail = []
                            for i in 0 ..< res.count {
                                if let arrT = res[i]["gd$name"] as? [String: Any] {
                                    for obj in arrT["gd$fullName"] as! NSDictionary {
                                        self.arrTitle.append(obj.value as? String ?? "")
                                    }
                                    if let arrT = res[i]["gd$email"] as? [[String: Any]] {
                                        if let usersEmail = arrT[0] as? [String : Any] {
                                            if let userEmail = usersEmail["address"] {
                                                self.arrEmail.append(userEmail as? String ?? "")
                                                print(userEmail)
                                            }else{
                                                self.arrEmail.append("Not available")
                                            }
                                        }
                                    }else{
                                        self.arrEmail.append("Not available")
                                    }
                                }
                            }
                            
                            print(self.arrTitle)
                            print(self.arrEmail)
                            self.noData.isHidden = true
                            self.tblList.reloadData()
                            OBJCOM.hideLoader()
                        }
                    }catch let error as NSError{
                        self.noData.isHidden = false
                        print(error)
                        OBJCOM.setAlert(_title: "Error", message: "\(error)")
                        OBJCOM.hideLoader()
                    }
                case .failure(let error):
                    self.noData.isHidden = false
                    OBJCOM.setAlert(_title: "Error", message: "\(error.localizedDescription)")
                    print(error.localizedDescription)
                    OBJCOM.hideLoader()
                }
        }
    }
    
}


extension ImportGoogleContacts {
    @IBAction func actionSelectAllContacts(_ sender:UIButton) {
        
        if !sender.isSelected {
            sender.isSelected = true
            self.arrSelectedContacts = []
            self.dictSelectedContacts = []
            SelectAllContacts()
        }else{
            sender.isSelected = false
            deselectAllContacts()
        }
    }
    
    func SelectAllContacts(){
        
        for i in 0 ..< arrTitle.count {
            if arrEmail[i] != "Not available" || arrEmail[i] != "" {
                let arrName = arrTitle[i].components(separatedBy: " ")
                var fName = ""
                var lName = ""
                if arrName.count > 0 && arrName.count < 2 {
                    fName = arrName[0]
                    lName = ""
                }else if arrName.count > 0 && arrName.count >= 2 {
                    fName = arrName[0]
                    lName = arrName[1]
                }
                
                let dict = ["contact_other_email": "",
                            "contact_phone": "",
                            //"contact_skype_id": "",
                            "contact_company_name": "",
                            "contact_country": "",
                            "contact_description": "",
                            "contact_lname": fName,
                            "contact_work_email": "",
                            "contact_flag": "1",
                            "contact_other_phone": "",
                            //"contact_twitter_name": "",
                            "contact_users_id": userID,
                            "contact_work_phone": "",
                            "contact_fname": lName,
                            //"contact_linkedinurl": "",
                            "contact_address": "",
                            "contact_city": "",
                            "contact_state": "",
                            //"contact_facebookurl": "",
                            "contact_zip": "",
                            "contact_platform": "3",
                            "contact_email": arrEmail[i]]
                
                self.dictSelectedContacts.append(dict as [String : AnyObject])
                self.arrSelectedContacts.append(arrEmail[i])
            }
            
        }
        print(self.dictSelectedContacts)
        print(self.arrSelectedContacts)
        self.tblList.reloadData()
    }
    
    func deselectAllContacts(){
        self.arrSelectedContacts = []
        self.dictSelectedContacts = []
        self.tblList.reloadData()
    }

    @IBAction func googleSignOut(_ sender: UIButton){
        let alertVC = PMAlertController(title: "", description: "Do you really want to sign out with '\(accountMail)' account?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .default, action: { () in
        }))
        
        alertVC.addAction(PMAlertAction(title: "Sign Out", style: .default, action: { () in
            GIDSignIn.sharedInstance().signOut()
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func importGoogleContacts(items:[[String:Any]]){
        var arrForImport = [AnyObject]()
        for item in items {
            arrForImport.append(item as AnyObject)
        }
        if arrForImport.count > 0 {
            print("----------------------------------")
            let dictParam = ["userId": userID,
                             "platform":"3",
                             "contact_details":arrForImport] as [String : Any]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "importCrmDevice", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                OBJCOM.hideLoader()
                
                let alertVC = PMAlertController(title: "", description: "Google contacts imported successfully.", image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.removeDuplicateContacts()
                        NotificationCenter.default.post(name: Notification.Name("UpdateContactList"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            };
        }
    }
    
    func removeDuplicateContacts(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteDuplicateCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }

}


