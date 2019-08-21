//
//  ApproveRequestView.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class ApproveRequestView: UIViewController {

    @IBOutlet var tblList : UITableView!
    @IBOutlet var noDataView : UIView!
    @IBOutlet var bgview : UIView!
    
    //For approve
    var arrAppAccessId = [String]()
    var arrAppUserName = [String]()
    var selectedUser = ""
    
    //For request
    var arrReqAccessId = [String]()
    var arrReqModule = [AnyObject]()
    var arrReqImg = [String]()
    var arrReqName = [String]()
    var arrReqAccessDate = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblList.tableFooterView = UIView()
        bgview.layer.cornerRadius = 10.0
        bgview.clipsToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getRequestList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getRequestList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorRequestedAndApproved", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrReqAccessId = []
            self.arrReqName = []
            self.arrReqImg = []
            self.arrReqModule = []
            self.arrReqAccessDate = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [String : Any]
                
                let requestData = data["requested"] as! [AnyObject]
                let approveData = data["approved"] as! [AnyObject]
                
                if requestData.count > 0 {
                    //requested user logic
                    for i in 0..<requestData.count {
                        self.arrReqAccessId.append(requestData[i]["accessId"] as? String ?? "")
                        self.arrReqName.append(requestData[i]["userNameReq"] as? String ?? "")
                        self.arrReqImg.append(requestData[i]["imgPath"] as? String ?? "")
                        self.arrReqModule.append(requestData[i]["accessModule"] as AnyObject)
                        self.arrReqAccessDate.append(requestData[i]["cftAccessDate"] as? String ?? "")
                    }
                    self.noDataView.isHidden = true
                }else{
                    self.noDataView.isHidden = false
                }
                
                
               
                //approved user logic
                self.arrAppAccessId = []
                self.arrAppUserName = []
                
                for i in 0..<approveData.count {
                    self.arrAppAccessId.append(approveData[i]["accessId"] as? String ?? "")
                    self.arrAppUserName.append(approveData[i]["userName"] as? String ?? "")
                }
                OBJCOM.hideLoader()
            }else{
                self.noDataView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        };
    }
}


extension ApproveRequestView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrReqName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! AccessSettingCell
        
        
            
        cell.lblName.text = self.arrReqName[indexPath.row]
        cell.configure(name: cell.lblName.text!)
        cell.lblDate.text = "Date : \(self.arrReqAccessDate[indexPath.row])"
        cell.imgBtnCal.isHidden = true
        cell.imgBtnWS.isHidden = true
        
        let tempArr = self.arrReqModule[indexPath.row] as! [AnyObject]
        if tempArr.count > 0 {
            for i in 0 ..< tempArr.count {
                let index = "\(tempArr[i])"
                if index == "1" {
                    cell.imgBtnWS.isHidden = false
                }
                if index == "2" {
                    cell.imgBtnCal.isHidden = false
                }
            }
        }
        
        cell.btnEdit.tag = indexPath.row
        cell.btnRemoveAccess.tag = indexPath.row
        cell.btnEdit.addTarget(self
            , action: #selector(actionAcceptRequest(_:)), for: .touchUpInside)
        cell.btnRemoveAccess.addTarget(self
            , action: #selector(actionRejectRequest(_:)), for: .touchUpInside)
     
        return cell
    }
}

extension ApproveRequestView {
    
    @IBAction func actionClose (_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSelectUser (_ sender:UIButton){
        
        if arrAppUserName.count == 0 {
            OBJCOM.setAlert(_title: "", message: "No approved users available yet.")
            return
        }
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrAppUserName.count {
            let item = ActionSheetItem(title: self.arrAppUserName[i], value: self.arrAppAccessId[i])
            items.append(item)
        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                
                sender.setTitle(item.title, for: .normal)
                self.selectedUser = "\(item.value!)"
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    
    @IBAction func actionRemoveAccess (_ sender:UIButton){
        
        if selectedUser == "" {
            OBJCOM.setAlert(_title: "", message: "Please select user")
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftUserId":selectedUser]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCommon(action: "removeAccess", dictParam: dictParam)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func actionAcceptRequest (_ sender:UIButton){
        
        if self.arrReqAccessId.count == 0 {
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId":self.arrReqAccessId[sender.tag]]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCommon(action: "aproveAccess", dictParam: dictParam)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func actionRejectRequest (_ sender:UIButton){
        
        if self.arrReqAccessId.count == 0 {
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId":self.arrReqAccessId[sender.tag]]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCommon(action: "rejectAccess", dictParam: dictParam)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func apiCallForCommon(action:String, dictParam:[String:String]){
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getRequestList()
                    
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
