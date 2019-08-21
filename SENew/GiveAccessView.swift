//
//  GiveAccessView.swift
//  SENew
//
//  Created by Milind Kudale on 16/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class GiveAccessView: UIViewController {

    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var btnCalender : UIButton!
    @IBOutlet var btnWeeklyScore : UIButton!
    @IBOutlet var btnSend : UIButton!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var noRecordVw : UIView!
    
    var accessImage : [UIImage] = [#imageLiteral(resourceName: "cal"), #imageLiteral(resourceName: "card")]
    var arrSelectedModule = [String]()
    var data = [AnyObject]()
    var accessData = [[String:AnyObject]]()
    var arrAccessId = [String]()
    var arrModule = [AnyObject]()
    var arrImg = [String]()
    var arrName = [String]()
    var arrEmail = [String]()
    var arrAccessDate = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.layer.cornerRadius = 5.0
        btnSend.clipsToBounds = true
        tblMemberList.tableFooterView = UIView()
        
        loadViewDesign()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func loadViewDesign(){
        btnCalender.isSelected = true
        btnWeeklyScore.isSelected = true
        arrSelectedModule = ["1", "2"]
        txtEmail.text = ""
        
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionCalender(_ sender:UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            if arrSelectedModule.contains("2") {
                let index = arrSelectedModule.index(of: "2")
                arrSelectedModule.remove(at: index!)
            }
        }else{
            sender.isSelected = true
            if arrSelectedModule.contains("2") == false {
                arrSelectedModule.append("2")
            }
        }
    }

    @IBAction func actionWeeklyScore(_ sender:UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            if arrSelectedModule.contains("1") {
                let index = arrSelectedModule.index(of: "1")
                arrSelectedModule.remove(at: index!)
            }
        }else{
            sender.isSelected = true
            if arrSelectedModule.contains("1") == false {
                arrSelectedModule.append("1")
            }
        }
    }
    
    @IBAction func actionSendRequest(_ sender:UIButton) {
        self.txtEmail.resignFirstResponder()
        let strModule = self.arrSelectedModule.joined(separator: ",")
        print(strModule)
        if validate() == true {
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSendAccessRequest(strModule)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func validate() -> Bool {
        
        if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter email to send request.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Enter valid email to send request.")
            return false
        }else if self.arrSelectedModule.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one access module to send request.")
            return false
        }
        
        return true
    }

}

extension GiveAccessView {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.accessData = []
            self.arrAccessId = []
            self.arrName = []
            self.arrEmail = []
            self.arrImg = []
            self.arrModule = []
            self.arrAccessDate = []
            
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                
                //requested user logic
                for i in 0..<data.count {
                    self.accessData.append(data[i] as! [String:AnyObject])
                    self.arrAccessId.append(data[i]["accessId"] as? String ?? "")
                    self.arrName.append(data[i]["userNameReq"] as? String ?? "")
                    self.arrImg.append(data[i]["imgPath"] as? String ?? "")
                    self.arrModule.append(data[i]["accessModule"] as AnyObject)
                    self.arrAccessDate.append(data[i]["cftAccessDate"] as? String ?? "")
                }
                self.noRecordVw.isHidden = true
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noRecordVw.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
}

extension GiveAccessView : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell") as! AccessSettingCell
        
        cell.lblName.text = self.arrName[indexPath.row]
        cell.lblDate.text = "Date : \(self.arrAccessDate[indexPath.row])"
        cell.btnEdit.tag = indexPath.row
        cell.btnRemoveAccess.tag = indexPath.row
        cell.configure(name: cell.lblName.text!)
        
        cell.imgBtnCal.isHidden = true
        cell.imgBtnWS.isHidden = true

        let tempArr = self.arrModule[indexPath.row] as! [AnyObject]
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

        cell.btnEdit.addTarget(self
            , action: #selector(actionEdit(_:)), for: .touchUpInside)
        cell.btnRemoveAccess.addTarget(self
            , action: #selector(actionRemoveAccess(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func actionEdit(_ sender:UIButton){
        self.txtEmail.resignFirstResponder()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateUI),
            name: NSNotification.Name(rawValue: "UpdateUI"),
            object: nil)
        if let vc = UIStoryboard(name: "CFT", bundle: nil).instantiateViewController(withIdentifier: "idEditAccessSetting") as? EditAccessSetting {
            print(self.accessData[sender.tag])
            vc.accessData = self.accessData[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @objc func actionRemoveAccess(_ sender:UIButton){
        self.txtEmail.resignFirstResponder()
        let alertVC = PMAlertController(title: "", description: "Do you really want to remove access?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Remove", style: .default, action: { () in
            let accessId = self.arrAccessId[sender.tag]
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.removeUserAccess(accessId:accessId)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    func removeUserAccess(accessId : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId":accessId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeManager", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                self.getDataFromServer()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForSendAccessRequest(_ module : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "managerEmail": self.txtEmail.text!,
                         "moduleName":module]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "requestAccess", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                self.loadViewDesign()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @objc func updateUI(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
}


class AccessSettingCell: UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var imgBtnCal : UIButton!
    @IBOutlet var imgBtnWS : UIButton!
    
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnRemoveAccess : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(name: String) {
        lblName?.text = name
        imgView?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView?.image = nil
        lblName?.text = nil
    }
    
}
