//
//  PrivacyOptionView.swift
//  SENew
//
//  Created by Milind Kudale on 15/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class PrivacyOptionView: UIViewController {

    var searchBar : DAOSearchBar!
    var txtSearch = UITextField()
    @IBOutlet var searchView : UIView!
    @IBOutlet var tblCftList : UITableView!
    @IBOutlet var btnDisableAll : UIButton!
    
    var arrCftData = [AnyObject]()
    var arrUserId = [String]()
    var arrUserName = [String]()
    var arrUserProfile = [String]()
    var arrStatus = [AnyObject]()
    
    var arrUserIdSearch = [String]()
    var arrUserNameSearch = [String]()
    var arrUserProfileSearch = [String]()
    var arrStatusSearch = [AnyObject]()
    
    var arrSelectedForHide = [String]()
    var isFilter = false;
    var cftDisplayFlagAll = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCftList.tableFooterView = UIView()
        self.arrSelectedForHide = []
        
        
        isFilter = false;
        setupSearchBars()
        
        if cftDisplayFlagAll == "1" {
            btnDisableAll.setTitle("Enable All", for: .normal)
        }else{
            btnDisableAll.setTitle("Disable All", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCftInfoWithShowStatus()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func setupSearchBars() {
        self.searchBar = DAOSearchBar.init(frame:CGRect(x: 20.0, y: 2.5, width: 40.0, height: 30))
        self.searchBar.delegate = self
        self.txtSearch = searchBar.searchField
        self.txtSearch.delegate = self
        self.searchView.addSubview(searchBar)
    }
    
    @IBAction func actionCloseVC(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name("executeRepeatedly"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDisableAll(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Disable All" {
            self.disableAllCFT("1")
            sender.setTitle("Enable All", for: .normal)
        }else{
            self.disableAllCFT("0")
            sender.setTitle("Disable All", for: .normal)
        }
        
    }
    
    

}

extension PrivacyOptionView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFilter {
            return self.arrUserIdSearch.count
        }
        return self.arrUserId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblCftList.dequeueReusableCell(withIdentifier: "Cell") as! CFTUserListCell
        
        if isFilter {
            cell.lblCftName.text = self.arrUserNameSearch[indexPath.row]
            let userIdHide = self.arrUserIdSearch[indexPath.row]
            
            if self.arrSelectedForHide.contains(userIdHide) {
                cell.btnShowHide.isOn = false
            }else{
                cell.btnShowHide.isOn = true
            }
        }else{
            cell.lblCftName.text = self.arrUserName[indexPath.row]
            let userIdHide = self.arrUserId[indexPath.row]
            
            if self.arrSelectedForHide.contains(userIdHide) {
                cell.btnShowHide.isOn = false
            }else{
                cell.btnShowHide.isOn = true
            }
        }
        cell.configure(name: cell.lblCftName.text!)
        cell.btnShowHide.tag = indexPath.row
        cell.btnShowHide.addTarget(self, action: #selector(actionShowHide(_:)), for: .valueChanged)
        
        return cell
    }
}

extension PrivacyOptionView {
    
    @objc func actionShowHide(_ sender : PVSwitch!) {
        
        var selectedUID = ""
        if isFilter {
            selectedUID = self.arrUserIdSearch[sender.tag]
        }else{
            selectedUID = self.arrUserId[sender.tag]
        }
        
        if !sender.isOn {
            if !self.arrSelectedForHide.contains(selectedUID) {
                self.arrSelectedForHide.append(selectedUID)
            }
            self.hideVisibility(selectedUID)
            sender.isOn = false
        }else{
            if self.arrSelectedForHide.contains(selectedUID) {
                let index = self.arrSelectedForHide.index(of: selectedUID)
                self.arrSelectedForHide.remove(at: index!)
                self.showVisibility(selectedUID)
                sender.isOn = true
                self.btnDisableAll.setTitle("Disable All", for: .normal)
            }
        }
    }
    
    
    func getCftInfoWithShowStatus(){
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftInfoWithShowStatus", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrCftData = []
            self.arrUserId = []
            self.arrUserName = []
            self.arrUserProfile = []
            self.arrStatus = []
            self.arrSelectedForHide = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                let result = JsonDict!["result"] as! [AnyObject]
                //  print("result:",result)
                for obj in result {
                    self.arrCftData.append(obj)
                    let name = "\(obj["first_name"] as? String ?? "") \(obj["last_name"] as? String ?? "")"
                    self.arrUserId.append(obj["userId"] as? String ?? "")
                    self.arrUserName.append(name)
                    self.arrUserProfile.append(obj["profile_pic"] as? String ?? "")
                    self.arrStatus.append(obj["showStatus"] as AnyObject)
                }
                
                for i in 0 ..< self.arrStatus.count {
                    if "\(self.arrStatus[i])" == "0" {
                        self.arrSelectedForHide.append(self.arrUserId[i])
                    }
                }
                OBJCOM.hideLoader()
            } else {
                OBJCOM.hideLoader()
            }
            self.tblCftList.reloadData()
        };
    }
    
    func showVisibility(_ selectedid:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftShowListUser":selectedid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "showHiddenCftList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }
    
    func hideVisibility(_ selectedid:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftListUser":selectedid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "hiddenCftList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }
    
    func disableAllCFT(_ disableFlag:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "disableFlag":disableFlag]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "cftDisableToAll", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            self.cftDisplayFlagAll = JsonDict!["disableFlag"] as? String ?? "0"
            
            if self.cftDisplayFlagAll == "1" {
                self.btnDisableAll.setTitle("Enable All", for: .normal)
            }else{
                self.btnDisableAll.setTitle("Disable All", for: .normal)
            }
            
            self.getCftInfoWithShowStatus()
            OBJCOM.hideLoader()
        };
    }
}

extension PrivacyOptionView : DAOSearchBarDelegate, UITextFieldDelegate {
    func destinationFrameForSearchBar(_ searchBar: DAOSearchBar) -> CGRect {
        return CGRect(x: 20.0, y: 2.5, width: self.searchView.frame.width - 40.0, height: 30)
    }
    
    func searchBar(_ searchBar: DAOSearchBar, willStartTransitioningToState destinationState: DAOSearchBarState) {
        
    }
    
    func searchBar(_ searchBar: DAOSearchBar, didEndTransitioningFromState previousState: DAOSearchBarState) {
        
    }
    
    func searchBarDidTapReturn(_ searchBar: DAOSearchBar) {
        
    }
    
    func searchBarTextDidChange(_ searchBar: DAOSearchBar) {
        //        self.txtSearch = searchBar.searchField
        //        self.txtSearch.delegate = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        self.arrUserIdSearch = []
        self.arrUserNameSearch = []
        self.arrUserProfileSearch = []
        self.arrStatusSearch = []
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrCftData.count {
                let fName = arrUserName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                
                if fName != nil {
                    arrUserIdSearch.append(arrUserId[i])
                    arrUserNameSearch.append(arrUserName[i])
                    arrUserProfileSearch.append(arrUserProfile[i])
                    arrStatusSearch.append(arrStatus[i])
                }
            }
        } else {
            isFilter = false
        }
        tblCftList.reloadData()
    }
}

class CFTUserListCell: UITableViewCell {
    
    @IBOutlet var imgCFT : UIImageView!
    @IBOutlet var lblCftName : UILabel!
    @IBOutlet var btnShowHide : PVSwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgCFT.layer.cornerRadius = imgCFT.frame.size.height/2
        imgCFT.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(name: String) {
        lblCftName?.text = name
        imgCFT?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgCFT?.image = nil
        lblCftName?.text = nil
    }
}
