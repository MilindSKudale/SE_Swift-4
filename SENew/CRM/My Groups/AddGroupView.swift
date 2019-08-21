//
//  AddGroupView.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Sheeeeeeeeet

class AddGroupView: UIViewController {
    
    @IBOutlet var stackView : UIStackView!
    @IBOutlet var systemContactView : UIView!
    @IBOutlet var importCsvView : UIView!
    @IBOutlet var EmailCampaignView : UIView!
    @IBOutlet var topBar : SMTabbar!
    @IBOutlet var tblContactList : UITableView!
    @IBOutlet var txtGrpName : UITextField!
    @IBOutlet var txtDesc : UITextField!
    @IBOutlet var lblCsvFile : UILabel!
    
    var searchBar : DAOSearchBar!
    var txtSearch = UITextField()
    @IBOutlet var searchView : UIView!
    @IBOutlet var btnSelectAllSC : UIButton!
    @IBOutlet var lblSelectedCount : UILabel!
    
    @IBOutlet var btnSystemContact : UIButton!
    @IBOutlet var btnImportContact : UIButton!
    @IBOutlet var btnEmailCampaigns : UIButton!
    
    var docController:UIDocumentInteractionController!
    var dictCsvData = [String:AnyObject]()
    
    var mainArrayList = [String]()
    var mainArrayID = [String]()
    var mainArrayListSearch = [String]()
    var mainArrayIDSearch = [String]()
    var arrContactList = [String]()
    var arrProspectList = [String]()
    var arrCustomerList = [String]()
    var arrRecruitList = [String]()
    var arrContactID = [String]()
    var arrProspectID = [String]()
    var arrCustomerID = [String]()
    var arrRecruitID = [String]()
    var arrSelectedIDs = [String]()
    
    var isFilter = false
    var isImportCsv = false
    var fromEmailCampaigns = false
    
    @IBOutlet var btnStatusRead : UIButton!
    @IBOutlet var btnStatusNotRead : UIButton!
    @IBOutlet var tblMemberList : UITableView!
  //  @IBOutlet var lblTblTitle : UILabel!
    @IBOutlet var noEmailListView : UIView!
   // @IBOutlet var btnSelectAllECRec : UIButton!
    var arrSelectedEmailsCampIDs = [String]()
    
    var arrCampaignFname = [String]()
    var arrCampaignLname = [String]()
    var arrCampaignTitle = [String]()
    var arrCampaignID = [String]()
    var arrCampEmailList = [String]()
    var arrCampEmailID = [String]()
    var campaignTitle = ""
    var campaignId = ""
    var isReadFlag = "1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addArrangedSubview(systemContactView)
        stackView.addArrangedSubview(importCsvView)
        stackView.addArrangedSubview(EmailCampaignView)
        systemContactView.isHidden = false
        importCsvView.isHidden = true
        EmailCampaignView.isHidden = true
        self.btnSelectAllSC.isSelected = false
        
        setupTabbar()
        setupSearchBars()
        updateRadio(btnSystemContact)
        self.isImportCsv = false
        self.fromEmailCampaigns = false
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getContactList()
            self.getProspectList()
            self.getCustomerList()
            self.getRecruitList()
            self.getCampaignData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        tblContactList.tableFooterView = UIView()
        tblMemberList.tableFooterView = UIView()
    }
    
   
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender:UIButton){
        if txtGrpName.text == ""{
            OBJCOM.setAlert(_title: "", message: "Please enter group name.")
        } else{
            var strSelect = ""
            if self.fromEmailCampaigns == true {
                if self.arrSelectedEmailsCampIDs.count > 0 {
                    strSelect = self.arrSelectedEmailsCampIDs.joined(separator: ",")
                    self.addGroup(strSelect: strSelect)
                }else{
                    self.addGroup(strSelect: "")
                }
            }else if self.isImportCsv == true {
                self.importCSVfileInGroup(dictCsvData["fileData"] as! Data, filename: dictCsvData["fileName"] as! String, completionHandler: { JsonDict in
                    let success:String = JsonDict!["IsSuccess"] as! String
                    if success == "true"{
                        let result = JsonDict!["result"] as? String ?? "Group created successfully!"
                        OBJCOM.hideLoader()
                        
                        let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                        
                        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                            NotificationCenter.default.post(name: Notification.Name("UpdateGroupList"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertVC, animated: true, completion: nil)

                    }else{
                        OBJCOM.hideLoader()
                        let result = JsonDict!["result"] as? String ?? "Nothing to import!"
                        OBJCOM.setAlert(_title: "", message: result)
                    }
                }
                )
            }else{
                // if self.arrSelectedIDs.count > 0 {
                strSelect = self.arrSelectedIDs.joined(separator: ",")
                self.addGroup(strSelect: strSelect)
                // }
            }
        }
    }
    
    @IBAction func actionSystemContact(_ sender:UIButton){
        systemContactView.isHidden = false
        importCsvView.isHidden = true
        EmailCampaignView.isHidden = true
        self.isImportCsv = false
        self.fromEmailCampaigns = false
        updateRadio(sender)
    }

    @IBAction func actionImportCsv(_ sender:UIButton){
        systemContactView.isHidden = true
        importCsvView.isHidden = false
        EmailCampaignView.isHidden = true
        self.isImportCsv = true
        self.fromEmailCampaigns = false
        updateRadio(sender)
    }

    @IBAction func actionEmailCampaigns(_ sender:UIButton){
        systemContactView.isHidden = true
        importCsvView.isHidden = true
        EmailCampaignView.isHidden = false
        self.isImportCsv = false
        self.fromEmailCampaigns = true
        self.btnStatusRead.isSelected = true
        self.btnStatusNotRead.isSelected = false
        updateRadio(sender)
    }
    
    func updateRadio(_ sender:UIButton){
        btnSystemContact.isSelected = false
        btnImportContact.isSelected = false
        btnEmailCampaigns.isSelected = false
        sender.isSelected = true
    }
    
    func addGroup(strSelect:String){
      
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_name":txtGrpName.text!,
                         "group_description":txtDesc.text!,
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                let groupName = "\(JsonDict!["group_name"] ?? "")"
                let result = JsonDict!["result"] as? String ?? ""
                print(result)
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: "Group '\(groupName)' created successfully.", image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateGroupList"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}

extension AddGroupView : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblContactList {
            if isFilter {
                return self.mainArrayListSearch.count
            }else { return mainArrayList.count }
        }else if tableView == tblMemberList {
            return self.arrCampaignFname.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cells = UITableViewCell()
        if tableView == tblContactList {
            let cell = tblContactList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SystemContactCell
            if isFilter {
                cell.lblUserName.text = self.mainArrayListSearch[indexPath.row]
                cell.configure(name: cell.lblUserName.text!)
                let selId = self.mainArrayIDSearch[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    cell.imgSelect.image = #imageLiteral(resourceName: "check")
                }else{
                    cell.imgSelect.image = #imageLiteral(resourceName: "uncheck")
                }
            }else{
                cell.lblUserName.text = self.mainArrayList[indexPath.row]
                cell.configure(name: cell.lblUserName.text!)
                let selId = self.mainArrayID[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    cell.imgSelect.image = #imageLiteral(resourceName: "check")
                }else{
                    cell.imgSelect.image = #imageLiteral(resourceName: "uncheck")
                }
            }
            cells = cell
        }else if tableView == tblMemberList {
            let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SystemContactCell
            cell.lblUserName.text = "\(self.arrCampaignFname[indexPath.row]) \(self.arrCampaignLname[indexPath.row])"
            cell.configure(name: cell.lblUserName.text!)
            if arrSelectedEmailsCampIDs.contains (arrCampEmailID[indexPath.row]) {
                cell.imgSelect.image = #imageLiteral(resourceName: "check")
            }else{
                cell.imgSelect.image = #imageLiteral(resourceName: "uncheck")
            }
            cells = cell
        }
        return cells
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblContactList {
            if isFilter {
                let selId = self.mainArrayIDSearch[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    if let index = self.arrSelectedIDs.index(of: selId) {
                        self.arrSelectedIDs.remove(at: index)
                    }
                }else{
                    self.arrSelectedIDs.append(selId)
                }
            }else{
                let selId = self.mainArrayID[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    if let index = self.arrSelectedIDs.index(of: selId) {
                        self.arrSelectedIDs.remove(at: index)
                    }
                }else{
                    self.arrSelectedIDs.append(selId)
                }
            }
            self.lblSelectedCount.text = "(\(self.getSelectedCount())/\(self.mainArrayID.count))"
            self.tblContactList.reloadData()
        }else if tableView == tblMemberList {
            let selId = self.arrCampEmailID[indexPath.row]
            if self.arrSelectedEmailsCampIDs.contains(selId){
                if let index = self.arrSelectedEmailsCampIDs.index(of: selId) {
                    self.arrSelectedEmailsCampIDs.remove(at: index)
                }
            }else{
                self.arrSelectedEmailsCampIDs.append(selId)
            }
            self.tblMemberList.reloadData()
        }
    }
}

// from system contacts

extension AddGroupView : DAOSearchBarDelegate, UITextFieldDelegate {
    func destinationFrameForSearchBar(_ searchBar: DAOSearchBar) -> CGRect {
        return CGRect(x: 10.0, y: 2.5, width: self.searchView.frame.width - 20.0, height: 30)
    }
    
    func searchBar(_ searchBar: DAOSearchBar, willStartTransitioningToState destinationState: DAOSearchBarState) {
    }
    
    func searchBar(_ searchBar: DAOSearchBar, didEndTransitioningFromState previousState: DAOSearchBarState) {
    }
    
    func searchBarDidTapReturn(_ searchBar: DAOSearchBar) {
    }
    
    func searchBarTextDidChange(_ searchBar: DAOSearchBar) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        mainArrayListSearch.removeAll()
        mainArrayIDSearch.removeAll()
        if textfield.text?.count != 0 {
            for i in 0 ..< mainArrayList.count {
                let strGName = mainArrayList[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                if strGName != nil {
                    mainArrayListSearch.append(mainArrayList[i])
                    mainArrayIDSearch.append(mainArrayID[i])
                    
                }
            }
        } else {
            isFilter = false
        }
        tblContactList.reloadData()
    }

    func setupSearchBars() {
        self.searchBar = DAOSearchBar.init(frame:CGRect(x: self.searchView.frame.width - 50.0, y: 2.5, width: 40.0, height: 30))
        self.searchBar.delegate = self
        self.txtSearch = searchBar.searchField
        self.txtSearch.delegate = self
        self.searchView.addSubview(searchBar)
    }
    
    func setupTabbar(){
        self.automaticallyAdjustsScrollViewInsets = false
        let list : [String] = ["Contacts", "Customers", "Prospects", "Recruits"]
        self.topBar.buttonWidth = self.systemContactView.frame.width/4
        self.topBar.moveDuration = 0.4
        self.topBar.fontSize = 16.0
        self.topBar.linePosition = .bottom
        self.topBar.lineWidth = self.systemContactView.frame.width/4
        self.topBar.selectTab(index: 0)
        self.topBar.configureSMTabbar(titleList: list) { (index) -> (Void) in
            if index == 0 {
                self.actionShowContactList()
            }else if index == 1 {
                self.actionShowCustomerList()
            }else if index == 2 {
                self.actionShowProspectList()
            }else if index == 3 {
                self.actionShowRecruitList()
            }
            print(index)
        }
    }
    
    
     func actionShowContactList (){
        self.btnSelectAllSC.isSelected = false
       // topBar.selectTab(index: 0)
        mainArrayList = arrContactList
        mainArrayID = arrContactID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        self.lblSelectedCount.text = "(\(self.getSelectedCount())/\(self.mainArrayID.count))"
        isFilter = false
//        txtSearch.text = ""
        searchBar.searchField.resignFirstResponder()
        self.tblContactList.reloadData()
    }
    
    func actionShowProspectList (){
        self.btnSelectAllSC.isSelected = false
      //  topBar.selectTab(index: 2)
        mainArrayList = arrProspectList
        mainArrayID = arrProspectID
        
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        self.lblSelectedCount.text = "(\(self.getSelectedCount())/\(self.mainArrayID.count))"
        isFilter = false
//        txtSearch.text = ""
        searchBar.searchField.resignFirstResponder()
        self.tblContactList.reloadData()
    }
    
    func actionShowCustomerList (){
        self.btnSelectAllSC.isSelected = false
       // topBar.selectTab(index: 1)
        mainArrayList = arrCustomerList
        mainArrayID = arrCustomerID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        self.lblSelectedCount.text = "(\(self.getSelectedCount())/\(self.mainArrayID.count))"
        isFilter = false
        searchBar.searchField.resignFirstResponder()
        self.tblContactList.reloadData()
    }
    
     func actionShowRecruitList (){
        self.btnSelectAllSC.isSelected = false
    //    topBar.selectTab(index: 1)
        mainArrayList = arrRecruitList
        mainArrayID = arrRecruitID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        self.lblSelectedCount.text = "(\(self.getSelectedCount())/\(self.mainArrayID.count))"
        isFilter = false
        searchBar.searchField.resignFirstResponder()
    
        self.tblContactList.reloadData()
    }
    
    func getContactList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrContactList = []
                self.arrContactID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrContactList.append(name)
                        self.arrContactID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                self.mainArrayList = self.arrContactList
                self.mainArrayID = self.arrContactID
                self.setupTabbar()
//                self.tblContactList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getProspectList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrProspectList = []
                self.arrProspectID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrProspectList.append(name)
                        self.arrProspectID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCustomerList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"2"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrCustomerList = []
                self.arrCustomerID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrCustomerList.append(name)
                        self.arrCustomerID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getRecruitList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"4"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrRecruitList = []
                self.arrRecruitID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrRecruitList.append(name)
                        self.arrRecruitID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionSelectAllRecords(_ btn : UIButton){
        
        if btn.isSelected {
            if isFilter {
                for i in 0 ..< self.mainArrayIDSearch.count {
                    let selId = self.mainArrayIDSearch[i]
                    if self.arrSelectedIDs.contains(selId){
                        if let index = self.arrSelectedIDs.index(of: selId) {
                            self.arrSelectedIDs.remove(at: index)
                        }
                    }else{
                        self.arrSelectedIDs.append(selId)
                    }
                }
            }else{
                for i in 0 ..< self.mainArrayID.count {
                    let selId = self.mainArrayID[i]
                    if self.arrSelectedIDs.contains(selId){
                        if let index = self.arrSelectedIDs.index(of: selId) {
                            self.arrSelectedIDs.remove(at: index)
                        }
                    }else{
                        self.arrSelectedIDs.append(selId)
                    }
                }
            }
            btn.isSelected = false
        }else{
            btn.isSelected = true
            if isFilter {
                for obj in self.mainArrayIDSearch {
                    if !self.arrSelectedIDs.contains(obj) {
                        self.arrSelectedIDs.append(obj)
                    }
                }
            }else{
                for obj in self.mainArrayID {
                    if !self.arrSelectedIDs.contains(obj) {
                        self.arrSelectedIDs.append(obj)
                    }
                }
            }
        }
      self.lblSelectedCount.text = "(\(self.getSelectedCount())/\(self.mainArrayID.count))"
      self.tblContactList.reloadData()
    }
    
    func getSelectedCount() -> Int {
        var count = 0
        for obj in self.mainArrayID {
            if self.arrSelectedIDs.contains(obj) {
                count = count + 1
            }
        }
        return count
    }
}

// import csv
extension AddGroupView : UINavigationControllerDelegate, UIDocumentPickerDelegate {
    @IBAction func actionSelectCsvFile(_ btn : UIButton){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
                OBJCOM.hideLoader()
                let statusCode = response?.mimeType
                print("Success: \(String(describing: statusCode))")
                self.dictCsvData = ["fileData":data!,
                                    "fileName": URL.lastPathComponent!] as [String : AnyObject]
                DispatchQueue.main.async(execute: {
                    self.lblCsvFile.text = "\(URL.lastPathComponent!)"
                    self.isImportCsv = true
                })
            }else {
                // Failure
                self.isImportCsv = false
                OBJCOM.hideLoader()
                print("Failure: %@", error!.localizedDescription)
            }
        });
        task.resume()
    }
    
    
    
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url = \(url)")
        
        let pathExtention = url.pathExtension
        if pathExtention == "csv" || pathExtention == "CSV" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.downloadfile(URL: url as NSURL)
            }else{
                OBJCOM.showNetworkAlert()
            }
        } else{
            OBJCOM.setAlert(_title: "", message: "File format is not supported.")
            self.isImportCsv = false
        }
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func importCSVfileInGroup(_ file:Data, filename:String, completionHandler: @escaping ([String:Any]?) -> ()) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "groupId":"0",
                          "groupName":self.txtGrpName.text!]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)importGroupCSV", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
        print(URL2)
        print(parameters)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData as Data, withName: "upload", fileName: filename, mimeType: "text/plain")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, with: URL2 , encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    if let JsonDict = response.result.value as? [String : Any]{
                        print(JsonDict)
                        completionHandler(JsonDict)
                        OBJCOM.hideLoader()
                    }else {
                        OBJCOM.setAlert(_title: "", message: "Failed to import file.")
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(_):
                OBJCOM.hideLoader()
                break
            }
        })
    }
}


//Email campaigns
extension AddGroupView {
    @IBAction func actionSelectReadStatus (_ sender:UIButton){
        
        if self.arrSelectedEmailsCampIDs.count > 0 {
            
            let alertVC = PMAlertController(title: "", description: "You can create group either from members who read emails or not read emails.", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            }))
            alertVC.addAction(PMAlertAction(title: "Continue", style: .default, action: { () in
                self.btnStatusRead.isSelected = true
                self.btnStatusNotRead.isSelected = false
                //    self.btnSelectAllECRec.isSelected = false
                self.arrSelectedEmailsCampIDs = []
                if self.campaignTitle != " Select Email Campaign" && self.campaignTitle != "" {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getCampaignStatusList(campaignId: self.campaignId, readFlag: "1")
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        }else{
            self.btnStatusRead.isSelected = true
            self.btnStatusNotRead.isSelected = false
           // self.btnSelectAllECRec.isSelected = false
            self.arrSelectedEmailsCampIDs = []
            if self.campaignTitle != " Select Email Campaign" && self.campaignTitle != "" {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCampaignStatusList(campaignId: self.campaignId, readFlag: "1")
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
        }
    }
    
    @IBAction func actionSelectNotReadStatus (_ sender:UIButton){
        
        if self.arrSelectedEmailsCampIDs.count > 0 {
            
            let alertVC = PMAlertController(title: "", description: "You can create group either from members who read emails or not read emails.", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            }))
            alertVC.addAction(PMAlertAction(title: "Continue", style: .default, action: { () in
                self.arrSelectedEmailsCampIDs = []
                self.btnStatusRead.isSelected = false
                self.btnStatusNotRead.isSelected = true
                //   self.btnSelectAllECRec.isSelected = false
                if self.campaignTitle != " Select Email Campaign" && self.campaignTitle != "" {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getCampaignStatusList(campaignId: self.campaignId, readFlag: "0")
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            }))
            self.present(alertVC, animated: true, completion: nil)

        }else{
            self.arrSelectedEmailsCampIDs = []
            self.btnStatusRead.isSelected = false
            self.btnStatusNotRead.isSelected = true
         //   self.btnSelectAllECRec.isSelected = false
            if self.campaignTitle != " Select Email Campaign" && self.campaignTitle != "" {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCampaignStatusList(campaignId: self.campaignId, readFlag: "0")
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
        }
    }
    
    func getCampaignData() {
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaignForGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignID.append(obj.value(forKey: "campaignId") as! String)
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionSelectCampaign (_ sender:UIButton) {
        if arrCampaignTitle.count == 0 {
            return
        }
       // let title = ActionSheetTitle(title: "Select email campaign")
        var items = [ActionSheetItem]()
        //items.append(title)
        for i in 0 ..< self.arrCampaignTitle.count {
            
            let item = ActionSheetItem(title: self.arrCampaignTitle[i], value: self.arrCampaignID[i])
            items.append(item)
            
        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                
                sender.setTitle(item.title, for: .normal)
                self.campaignTitle = item.title
                self.campaignId = "\(item.value!)"
                self.btnStatusRead.isSelected = true
                self.btnStatusNotRead.isSelected = false
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCampaignStatusList(campaignId: self.campaignId, readFlag: "1")
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
               // self.tblMemberList.reloadData()
               
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func getCampaignStatusList(campaignId : String, readFlag : String) {
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campId":campaignId,
                         "readFlag":readFlag]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaignStatusList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignFname = []
                self.arrCampaignLname = []
                self.arrCampEmailList = []
                self.arrCampEmailID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignFname.append(obj.value(forKey: "contact_fname") as? String ?? "")
                    self.arrCampaignLname.append(obj.value(forKey: "contact_lname") as? String ?? "")
                    self.arrCampEmailList.append(obj.value(forKey: "contact_email") as? String ?? "")
                    self.arrCampEmailID.append(obj.value(forKey: "contact_id") as? String ?? "")
                }
                self.noEmailListView.isHidden = true
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noEmailListView.isHidden = false
                self.arrCampEmailList = []
                self.arrCampEmailID = []
                self.arrCampaignFname = []
                self.arrCampaignLname = []
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }
        };
    }
    
//    @IBAction func selectAllRecordFromEmailCampList(_ sender:UIButton){
//        if self.btnSelectAllECRec.isSelected {
//            self.btnSelectAllECRec.isSelected = false
//            self.arrSelectedEmailsCampIDs.removeAll()
//        }else{
//            self.btnSelectAllECRec.isSelected = true
//            self.arrSelectedEmailsCampIDs = self.arrCampEmailID
//        }
//        self.tblMemberList.reloadData()
//    }
    
}

