//
//  ManageCustomTagView.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ManageCustomTagView: UIViewController {

    @IBOutlet var txtAddTag : UITextField!
    @IBOutlet var btnAdd : UIButton!
    @IBOutlet var tblTagList : UITableView!
    
    var arrTagName = [String]()
    var arrTagId = [String]()
    var arrTagIdPredefine = [String]()
    
    var contact_id = ""
    var crmFlag = ""
    var tagName = ""
    var tagId = ""
    var isUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    func designUI(){
        
        btnAdd.clipsToBounds = true
        tblTagList.tableFooterView = UIView()
        self.btnAdd.setTitle("Add", for: .normal)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCategoryList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddTag(_ sender:UIButton){
        if sender.titleLabel?.text == "Add" {
            if isUpdate == false {
                if self.txtAddTag.text != ""{
                    let tagName = ["tagName":self.txtAddTag.text!,
                                   "contact_id":contact_id]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ADDCUSTOMTAG"), object: nil, userInfo: tagName)
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    OBJCOM.setAlert(_title: "", message: "Please add your custom tag name.")
                }
            }else{
                if self.txtAddTag.text != "" {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.apiCallForUpdateTag(tagName: self.txtAddTag.text!, tagId: "0", contact_id: contact_id)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                } else{
                    OBJCOM.setAlert(_title: "", message: "Please add your custom tag name.")
                }
            }
            
        }else{
            if self.txtAddTag.text != "" {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                      self.updateTag(tagName: self.txtAddTag.text!, tagId: tagId)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            } else{
                OBJCOM.setAlert(_title: "", message: "Please add your custom tag name.")
            }
        }
        
        
    }
}

extension ManageCustomTagView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTagName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblTagList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTagCell
        cell.lblTagName.text = self.arrTagName[indexPath.row]
        cell.btnRemove.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(removeCustomTag(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(editCustomTag(_:)), for: .touchUpInside)
        return cell
    }
    
    
    @objc func editCustomTag(_ sender:UIButton) {
        self.isUpdate = true
        self.btnAdd.setTitle("Update", for: .normal)
        tagName = self.arrTagName[sender.tag]
        tagId = self.arrTagId[sender.tag]
        self.txtAddTag.text = tagName
    }
    
    func updateTag(tagName:String, tagId:String){
        let dictParam = ["contact_users_id": userID,
                         "userTagId":tagId,
                         "tagName":tagName,
                         "contact_platform":"3"]
    
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateCustomTag", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: dictJsonData)
                self.txtAddTag.text = ""
                self.tagName = ""
                self.tagId = ""
                self.isUpdate = false
                self.btnAdd.setTitle("Add", for: .normal)
                self.getCategoryList()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
                
            }
            self.tblTagList.reloadData()
        };
    }
    
    @objc func removeCustomTag(_ sender:UIButton) {
        print(sender.tag)
        
        let alertVC = PMAlertController(title: "", description: "Are you sure you want to remove this tag? If assigned to other records will also get removed?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
            
        alertVC.addAction(PMAlertAction(title: "Remove", style: .default, action: { () in
            let tagId = self.arrTagId[sender.tag]
            let dictParam = ["contact_users_id": userID,
                             "userTagId":tagId]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "removeCustomTag", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let dictJsonData = JsonDict!["result"] as? String ?? ""
                    OBJCOM.setAlert(_title: "", message: dictJsonData)
                    OBJCOM.hideLoader()
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                    
                }
                self.tblTagList.reloadData()
            };
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func getCategoryList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":crmFlag]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "fillDropDownCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                if dictJsonData.count > 0 {
                    self.arrTagName = []
                    self.arrTagId = []
                    let arrTag = dictJsonData.value(forKey: "contact_category") as! [AnyObject]
                    for tag in arrTag {
                        let isPredefined = "\(tag["userTagUserId"] as? String ?? "")"
                        if isPredefined != "-1"{
                            self.arrTagName.append("\(tag["userTagName"] as? String ?? "")")
                            self.arrTagId.append("\(tag["userTagId"] as? String ?? "")")
                        }
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
                
            }
            self.tblTagList.reloadData()
        };
        
    }
    
    func apiCallForUpdateTag(tagName:String, tagId:String, contact_id:String){
        let dictParam = ["contact_id": contact_id,
                         "contact_category_title":tagName,
                         "contact_platform": "3",
                         "contact_category":tagId,
                         "contact_users_id":userID]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateTag", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                self.txtAddTag.text = ""
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCategoryList()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
