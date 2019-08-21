//
//  AddToGroupView.swift
//  SENew
//
//  Created by Milind Kudale on 09/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class AddToGroupView: UIViewController {
    
    @IBOutlet var rbExistingGrp : UIButton!
    @IBOutlet var rbNewGrp : UIButton!
    @IBOutlet var btnAddGroup : UIButton!
    @IBOutlet var viewEG : UIView!
    @IBOutlet var viewNG : UIView!
    @IBOutlet var txtGroupName : UITextField!
    @IBOutlet var txtGroupDesc : UITextField!
    @IBOutlet weak var selectGroup : UIButton!
    @IBOutlet weak var stackView : UIStackView!
    
    var arrGroupTitle = [String]()
    var arrGroupId = [String]()
    
    var groupName = ""
    var groupId = ""
    var selectedIDs = ""
    var isExistingGrp = "YES"
    
    var className = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAddGroup.clipsToBounds = true
        groupName = ""
        groupId = ""
        isExistingGrp = "YES"
        stackView.addArrangedSubview(viewEG)
        stackView.addArrangedSubview(viewNG)
        self.rbExistingGrp.isSelected = true
        self.rbNewGrp.isSelected = false
        self.viewEG.isHidden = false
        self.viewNG.isHidden = true
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionCancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSelectGroup(_ sender:UIButton){
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrGroupTitle.count {
            let item = ActionSheetItem(title: self.arrGroupTitle[i], value: self.arrGroupId[i])
            items.append(item)
        }
        let button = ActionSheetCancelButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                self.groupName = item.title
                self.groupId = "\(item.value!)"
                sender.setTitle(item.title, for: .normal)
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionSelectExistingGroup(_ sender:UIButton){
        isExistingGrp = "YES"
        rbExistingGrp.isSelected = true
        self.rbNewGrp.isSelected = false
        self.viewEG.isHidden = false
        self.viewNG.isHidden = true
    }
    
    @IBAction func actionSelectNewGroup(_ sender:UIButton){
        isExistingGrp = "NO"
        
        rbExistingGrp.isSelected = false
        self.rbNewGrp.isSelected = true
        self.viewEG.isHidden = true
        self.viewNG.isHidden = false
    }
    
    @IBAction func actionAddToGroup(_ sender:UIButton){
        
        if isExistingGrp == "YES" {
            updateExistingGroup()
        }else{
            createNewGroup()
        }
    }
}


extension AddToGroupView {
    func getGroupData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                self.arrGroupTitle = []
                self.arrGroupId = []
                for obj in result {
                    self.arrGroupTitle.append(obj.value(forKey: "group_name") as! String)
                    self.arrGroupId.append(obj.value(forKey: "group_id")  as! String)
                }
                //self.loadDD()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
//    func loadDD() {
//
//        self.ddSelectGroup.options = self.arrGroupTitle
//        self.ddSelectGroup.didSelect { (option, index) in
//            print("You just select: \(option) at index: \(index)")
//            self.groupName = self.arrGroupTitle[index]
//            self.groupId = self.arrGroupId[index]
//        }
//    }
    
    func createNewGroup(){
        if txtGroupName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter group name.")
            return
        } else if self.selectedIDs == "" {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one group member.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.addToNewGroup(strSelect: selectedIDs)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func updateExistingGroup(){
        if self.groupName == "" {
            OBJCOM.setAlert(_title: "", message: "Please select group.")
            return
        }else if groupId == "" {
            OBJCOM.setAlert(_title: "", message: "Something went wrong.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.addToExistingGroup(strSelect: selectedIDs)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func addToNewGroup(strSelect:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_name":txtGroupName.text!,
                         "group_description":txtGroupDesc.text!,
                         "group_id": "0",
                         "groupExistingFlag": "0",
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCrmMultipleRowGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let result = JsonDict!["result"] as? String ?? ""
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if self.className == "Prospect"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if self.className == "Contact"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                    }else if self.className == "Customer"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                    }else if self.className == "Recruit"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func addToExistingGroup(strSelect:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_name":"",
                         "group_description":"",
                         "group_id": self.groupId,
                         "groupExistingFlag": "1",
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCrmMultipleRowGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let result = JsonDict!["result"] as? String ?? ""
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if self.className == "Prospect"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if self.className == "Contact"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                    }else if self.className == "Customer"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                    }else if self.className == "Recruit"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}
