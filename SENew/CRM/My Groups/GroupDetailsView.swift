//
//  GroupDetailsView.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class GroupDetailsView: UIViewController {

    var groupId = ""
    var arrGroupData = [String:AnyObject]()
    var arrGroupProspect = [String]()
    var arrGroupContact = [String]()
    var arrGroupCustomer = [String]()
    var arrGroupRecruit = [String]()
    var arrAssignedCamp = [String]()
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblGroupName : UILabel!
    @IBOutlet var lblGroupDesc : UILabel!
    @IBOutlet var lblContactList : UILabel!
    @IBOutlet var lblCustomerList : UILabel!
    @IBOutlet var lblProspectList : UILabel!
    @IBOutlet var lblRecruitList : UILabel!
    @IBOutlet var lblAssignedCamp : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgUser.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupDetails()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionEditGroup(_ sender:UIButton){
        
        let storyboard = UIStoryboard(name: "MyGroups", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditGroupView") as! EditGroupView
        vc.groupId = groupId
        vc.viewClass = true
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: false, completion: nil)
    }
    
    func getGroupDetails(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "groupId":groupId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getDetailGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
               
                self.arrGroupData = JsonDict!["result"] as! [String:AnyObject]
                
                self.lblGroupName.text = self.arrGroupData["group_name"] as? String ?? ""
                self.configure(name: self.lblGroupName.text!)
                self.lblGroupDesc.text = self.arrGroupData["group_description"] as? String ?? ""
                self.arrAssignedCamp = []
                self.arrGroupContact = []
                self.arrGroupCustomer = []
                self.arrGroupProspect = []
                self.arrGroupRecruit = []

                self.arrGroupContact = self.arrGroupData["contact"]!["name"] as! [String]
                self.arrGroupCustomer = self.arrGroupData["customer"]!["name"] as! [String]
                self.arrGroupProspect = self.arrGroupData["prospect"]!["name"] as! [String]
                self.arrGroupRecruit = self.arrGroupData["recruit"]!["name"] as! [String]
                self.arrAssignedCamp = self.arrGroupData["campName"] as! [String]
                
                if self.arrGroupContact.count > 0 {
                    let listContacts = self.arrGroupContact.joined(separator: ", ")
                    self.lblContactList.text = listContacts
                }else{
                    self.lblContactList.text = "No contacts added yet."
                }
                
                if self.arrGroupCustomer.count > 0 {
                    let listCustomers = self.arrGroupCustomer.joined(separator: ", ")
                    self.lblCustomerList.text = listCustomers
                }else{
                    self.lblCustomerList.text = "No customers added yet."
                }
                
                if self.arrGroupProspect.count > 0 {
                    let listProspects = self.arrGroupProspect.joined(separator: ", ")
                    self.lblProspectList.text = listProspects
                }else{
                    self.lblProspectList.text = "No prospects added yet."
                }
                
                if self.arrGroupRecruit.count > 0 {
                    let listRecruits = self.arrGroupRecruit.joined(separator: ", ")
                    self.lblRecruitList.text = listRecruits
                }else{
                    self.lblRecruitList.text = "No recruits added yet."
                }
                
                if self.arrAssignedCamp.count > 0 {
                    let listRecruits = self.arrAssignedCamp.joined(separator: ", ")
                    self.lblAssignedCamp.text = listRecruits
                }else{
                    self.lblAssignedCamp.text = "No email campaigns assigned yet."
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func configure(name: String) {
        lblGroupName?.text = name
        imgUser?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
}
