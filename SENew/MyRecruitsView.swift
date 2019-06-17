//
//  MyProspectsView.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import Sheeeeeeeeet

class MyRecruitsView: SliderVC {
    
    var searchBar : DAOSearchBar!
    var txtSearch = UITextField()
    @IBOutlet var searchView : UIView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var btnSelectAll : UIButton!
    @IBOutlet var btnMove : UIButton!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var btnAssignCampaign : UIButton!
    @IBOutlet var btnAddToGroup : UIButton!
    @IBOutlet var noDataView : UIView!
    
    var isFilter = false;
    var strSortBy = ""
    var strSortByAsce = ""
    var selectAllRecords = false
    
    var arrSelectedRecords = [String]()
    var arrProspectData = [AnyObject]()
    var arrFirstName = [String]()
    var arrLastName = [String]()
    var arrEmail = [String]()
    var arrPhone = [String]()
    var arrProspectId = [String]()
    var arrCategory = [String]()
    var arrDesc = [String]()
    var arrDate = [String]()
    
    var arrFirstNameSearch = [String]()
    var arrLastNameSearch = [String]()
    var arrEmailSearch = [String]()
    var arrPhoneSearch = [String]()
    var arrCategorySearch = [String]()
    var arrProspectIdSearch = [String]()
    var arrDescSearch = [String]()
    var arrDateSearch = [String]()
    var arrTagTitle = [String]()
    var arrTagId = [String]()
    var prospectCsvArray:[Dictionary<String, AnyObject>] =  Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vw = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        self.setupSearchBars()
        tblList.tableFooterView = vw
        isFilter = false;
        self.strSortBy = ""
        self.strSortByAsce = ""
        self.btnDelete.isHidden = true
        self.btnMove.isHidden = true
        self.btnAssignCampaign.isHidden = true
        self.btnAddToGroup.isHidden = true
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "add_contact")) { item in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateRecruitList),
                name: NSNotification.Name(rawValue: "UpdateRecruitList"),
                object: nil)
            let storyboard = UIStoryboard(name: "MyRecruits", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddRecruitView") as! AddRecruitView
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
        actionButton.display(inViewController: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        arrSelectedRecords = []
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getProspectData(sortBy:strSortBy, isacs:self.strSortByAsce)
            self.getCategoryList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func setupSearchBars() {
        self.searchBar = DAOSearchBar.init(frame:CGRect(x: self.searchView.frame.width - 50.0, y: 2.5, width: 40.0, height: 30))
        self.searchBar.delegate = self
        self.txtSearch = searchBar.searchField
        self.txtSearch.delegate = self
        self.searchView.addSubview(searchBar)
    }
    
    @objc func UpdateRecruitList(notification: NSNotification){
        arrSelectedRecords = []
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getProspectData(sortBy:strSortBy, isacs:self.strSortByAsce)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getProspectData(sortBy:String, isacs:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"4",
                         "sortBy":sortBy,
                         "contact_category_title":isacs]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.btnDelete.isHidden = true
            self.btnMove.isHidden = true
            self.btnAssignCampaign.isHidden = true
            self.btnAddToGroup.isHidden = true
            self.btnSelectAll.isSelected = false
            
            self.arrFirstName = []
            self.arrLastName = []
            self.arrEmail = []
            self.arrPhone = []
            self.arrProspectId = []
            self.arrCategory = []
            self.arrDesc = []
            self.arrDate = []
            self.noDataView.isHidden = false
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrProspectData = JsonDict!["result"] as! [AnyObject]
                if self.arrProspectData.count > 0 {
                    self.arrFirstName = self.arrProspectData.compactMap { $0["contact_fname"] as? String }
                    self.arrLastName = self.arrProspectData.compactMap { $0["contact_lname"] as? String }
                    self.arrEmail = self.arrProspectData.compactMap { $0["contact_email"] as? String }
                    self.arrPhone = self.arrProspectData.compactMap { $0["contact_phone"] as? String }
                    self.arrProspectId = self.arrProspectData.compactMap { $0["contact_id"] as? String }
                    self.arrCategory = self.arrProspectData.compactMap { $0["contact_category"] as? String }
                    self.arrDesc = self.arrProspectData.compactMap { $0["contact_description"] as? String }
                    let aDate = self.arrProspectData.compactMap { $0["contact_created"] as? String }
                    for obj in aDate {
                        let dt = obj.components(separatedBy: " ")
                        self.arrDate.append(dt[0])
                    }
                    self.noDataView.isHidden = true
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

extension MyRecruitsView : DAOSearchBarDelegate, UITextFieldDelegate {
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
        
        arrFirstNameSearch.removeAll()
        arrLastNameSearch.removeAll()
        arrEmailSearch.removeAll()
        arrPhoneSearch.removeAll()
        arrDateSearch.removeAll()
        arrProspectIdSearch.removeAll()
        arrCategorySearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrProspectData.count {
                let fName = arrFirstName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let lName = arrLastName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let em = arrEmail[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let ph = arrPhone[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let dt = arrDate[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                
                if fName != nil || lName != nil || em != nil || ph != nil || dt != nil{
                    arrFirstNameSearch.append(arrFirstName[i])
                    arrLastNameSearch.append(arrLastName[i])
                    arrEmailSearch.append(arrEmail[i])
                    arrPhoneSearch.append(arrPhone[i])
                    arrDateSearch.append(arrDate[i])
                    arrProspectIdSearch.append(arrProspectId[i])
                    arrCategorySearch.append(arrCategory[i])
                }
            }
        } else {
            isFilter = false
        }
        tblList.reloadData()
    }
}

extension MyRecruitsView : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.arrProspectIdSearch.count
        }else { return self.arrProspectId.count }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CrmCell
        var category = ""
        if isFilter {
            let name = "\(arrFirstNameSearch[indexPath.row]) \(arrLastNameSearch[indexPath.row])"
            cell.lblUserName.text = name
            cell.lblEmail.text = arrEmailSearch[indexPath.row]
            cell.lblPhone.text = arrPhoneSearch[indexPath.row]
            cell.lblDate.text = arrDateSearch[indexPath.row]
            cell.configure(name: name)
            category = self.arrCategorySearch[indexPath.row]
            if self.arrSelectedRecords.contains(self.arrProspectIdSearch [indexPath.row]){
                cell.btnSelect.isSelected = true
            }else{
                cell.btnSelect.isSelected = false
            }
        }else{
            let name = "\(arrFirstName[indexPath.row]) \(arrLastName[indexPath.row])"
            cell.lblUserName.text = name
            
            if arrEmail[indexPath.row] != "" {
                cell.lblEmail.text = arrEmail[indexPath.row]
            }else{
                cell.lblEmail.text = "Not determine"
            }
            
            if arrPhone[indexPath.row] != "" {
                cell.lblPhone.text = arrPhone[indexPath.row]
            }else{
                cell.lblPhone.text = "Not determine"
            }
            
            cell.lblDate.text = arrDate[indexPath.row]
            cell.configure(name: name)
            category = self.arrCategory[indexPath.row]
            if self.arrSelectedRecords.contains(self.arrProspectId [indexPath.row]){
                cell.btnSelect.isSelected = true
            }else{
                cell.btnSelect.isSelected = false
            }
        }
        
        if category != "" {
            //cell.btnTag.setTitle(category, for: .normal)
            if category == "Green Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "3"), for: .normal)
            }else if category == "Red Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "1"), for: .normal)
            }else if category == "Brown Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "2"), for: .normal)
            }else if category == "Rotten Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "4"), for: .normal)
            }else{
                cell.btnTag.setImage(#imageLiteral(resourceName: "custom_tag2"), for: .normal)
            }
        }else{
            cell.btnTag.setImage(#imageLiteral(resourceName: "tag_blank"), for: .normal)
        }
        
        
        cell.btnTag.tag = indexPath.row
        cell.btnSelect.tag = indexPath.row
        cell.btnTag.addTarget(self, action: #selector(actionSetTag), for: .touchUpInside)
        cell.btnSelect.addTarget(self, action: #selector(actionSelectRecord), for: .touchUpInside)
        return cell
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let assignAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Assign", handler: { (action, view, completion) in
            //TODO: Assign
            
            if self.arrEmail[indexPath.row] == "" {
                OBJCOM.setAlert(_title: "", message: "Email-id required for assign campaigns")
                return
            }else{
                self.arrSelectedRecords.removeAll()
                var arrId = [String]()
                var arrfName = [String]()
                var arrlName = [String]()
                
                if self.isFilter {
                    arrId = self.arrProspectIdSearch
                    arrfName = self.arrFirstNameSearch
                    arrlName = self.arrLastNameSearch
                }else{
                    arrId = self.arrProspectId
                    arrfName = self.arrFirstName
                    arrlName = self.arrLastName
                }
                
                let name = "\(arrfName[indexPath.row]) \(arrlName[indexPath.row])"
                
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.UpdateRecruitList),
                    name: NSNotification.Name(rawValue: "UpdateRecruitList"),
                    object: nil)
                
                let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idAddEmailsToEC") as! AddEmailsToEC
                vc.contactId = arrId[indexPath.row]
                vc.contactName = name
                vc.isGroup = false
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                self.present(vc, animated: false, completion: nil)
            }
        })
        
        let editAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Edit", handler: { (action, view, completion) in
            //TODO: Edit
            var arrId = [String]()
            if self.isFilter {
                arrId = self.arrProspectIdSearch
            }else{
                arrId = self.arrProspectId
            }
            
            let storyboard = UIStoryboard(name: "MyRecruits", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditRecruitView") as! EditRecruitView
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.contactID = arrId[indexPath.row]
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            
        })
        
        let deleteAction = UIContextualAction.init(style: UIContextualAction.Style.destructive, title: "Delete", handler: { (action, view, completion) in
            //TODO: Delete
            self.arrSelectedRecords.removeAll()
            var arrId = [String]()
            if self.isFilter {
                arrId = self.arrProspectIdSearch
            }else{
                arrId = self.arrProspectId
            }
            let selectedID = arrId[indexPath.row]
            let alertVC = PMAlertController(title: "", description: "Do you want to delete this recruit?", image: nil, style: .alert)
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.deleteProspect(prospectId: selectedID)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        })
        
        let tagAction = UIContextualAction.init(style: UIContextualAction.Style.destructive, title: "Tag", handler: { (action, view, completion) in
            //TODO: Delete
            self.arrSelectedRecords.removeAll()
            var arrId : [String] = []
            if self.isFilter {
                arrId = self.arrProspectIdSearch
            }else{
                arrId = self.arrProspectId
            }
            let contact_id = arrId[indexPath.row]
            self.setTagCrm(contact_id:contact_id)
        })
        tagAction.image = UIImage(named: "tag_blank")
        assignAction.image = UIImage(named: "assign_wh")
        editAction.image = UIImage(named: "edit_wh")
        deleteAction.image = UIImage(named: "delete_wh")
        tagAction.backgroundColor = UIColor(red:0.90, green:0.74, blue:0.11, alpha:1.0)
        assignAction.backgroundColor = UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0)
        editAction.backgroundColor = UIColor(red:0.49, green:0.34, blue:0.89, alpha:1.0)
        deleteAction.backgroundColor = UIColor(red:0.93, green:0.33, blue:0.31, alpha:1.0)
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction, assignAction, tagAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateRecruitList),
            name: NSNotification.Name(rawValue: "UpdateRecruitList"),
            object: nil)
        var arrId = [String]()
        if self.isFilter {
            arrId = self.arrProspectIdSearch
        }else{
            arrId = self.arrProspectId
        }
        let storyboard = UIStoryboard(name: "MyRecruits", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idRecruitDetailsView") as! RecruitDetailsView
        vc.contactId = arrId[indexPath.row]
        vc.crmFlag = "4"
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
}

extension MyRecruitsView {
    @IBAction func actionSelectAll(_ sender: UIButton) {
        self.selectAllRecords = true
        self.btnDelete.isHidden = true
        self.btnMove.isHidden = true
        self.btnAssignCampaign.isHidden = true
        self.btnAddToGroup.isHidden = true
        
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        if !sender.isSelected{
            self.arrSelectedRecords.removeAll()
            for id in arrId {
                self.arrSelectedRecords.append(id)
            }
            sender.isSelected = true
            
        }else{
            self.arrSelectedRecords.removeAll()
            sender.isSelected = false
        }
        self.tblList.reloadData()
        
        if self.arrSelectedRecords.count > 0 {
            self.btnDelete.isHidden = false
            self.btnMove.isHidden = false
            self.btnAssignCampaign.isHidden = false
            self.btnAddToGroup.isHidden = false
        }
        
        print("Selected id >> ",self.arrSelectedRecords)
    }
    
    @IBAction func actionSelectRecord(_ sender: UIButton) {
        self.selectAllRecords = false
        self.btnDelete.isHidden = true
        self.btnMove.isHidden = true
        self.btnAssignCampaign.isHidden = true
        self.btnAddToGroup.isHidden = true
        
        view.layoutIfNeeded()
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        if self.arrSelectedRecords.contains(arrId[sender.tag]){
            if let index = self.arrSelectedRecords.index(of: arrId[sender.tag]) {
                self.arrSelectedRecords.remove(at: index)
            }
        }else{
            self.arrSelectedRecords.append(arrId[sender.tag])
        }
        if self.arrSelectedRecords.count > 0 {
            self.btnDelete.isHidden = false
            self.btnMove.isHidden = false
            self.btnAssignCampaign.isHidden = false
            self.btnAddToGroup.isHidden = false
        }
        self.tblList.reloadData()
    }
    
    @IBAction func actionAssignCampaignsToAllRecords(_ sender: UIButton) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateRecruitList),
            name: NSNotification.Name(rawValue: "UpdateRecruitList"),
            object: nil)
        if arrSelectedRecords.count > 0 && arrSelectedRecords.count <= 50 {
            let strContactId = arrSelectedRecords.joined(separator: ",")
            let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddMultipleEmailsToEC") as! AddMultipleEmailsToEC
            vc.className = "Recruit"
            vc.contactsId = strContactId
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
            
        }else if arrSelectedRecords.count > 50{
            OBJCOM.hideLoader()
            let alertVC = PMAlertController(title: "", description: "You can assign email campaign only 50 recruits. Please select recruits less than 50.", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                self.dismiss(animated: true, completion: nil)
            }))
        } else{
            OBJCOM.setAlert(_title: "", message: "Please select at least one recruit to continue")
            return
        }
        
    }
    
    @IBAction func actionDeleteMultipleRecord(_ sender: UIButton) {
        if self.arrSelectedRecords.count>0{
            let strSelectedID = self.arrSelectedRecords.joined(separator: ",")
            var msg = ""
            if self.selectAllRecords == true {
                msg = "Do you want to delete all recruits?"
            }else{
                msg = "Do you want to delete selected recruits?"
            }
            
            let alertVC = PMAlertController(title: "", description: msg, image: nil, style: .alert)
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                if self.selectAllRecords == true {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.deleteAllRecords()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.deleteProspect(prospectId: strSelectedID)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one or more recruit(s) to delete.")
        }
    }
    
    func deleteAllRecords(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contact_flag":"4"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteAllCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                self.selectAllRecords = false
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        };
    }
    
    func deleteProspect(prospectId: String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contactIds":prospectId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteMultipleRowCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    @IBAction func actionMoveRecord(_ sender: UIButton) {
        
        if arrSelectedRecords.count > 0 {
            let selected = arrSelectedRecords.joined(separator: ",")
            self.selectOptionsForMoveProspects(prospectId: selected)
        }
    }
    
    func selectOptionsForMoveProspects(prospectId: String) {
        let item1 = ActionSheetItem(title: "My Contacts", value: 1)
        let item2 = ActionSheetItem(title: "My Prospects", value: 2)
        let item3 = ActionSheetItem(title: "My Customers", value: 3)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item3, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    print("My contacts")
                    self.moveProspect(prospectId: prospectId, crmFlag:  "1")
                }else if item == item2 {
                    print("My Prospects")
                    self.moveProspect(prospectId: prospectId, crmFlag:  "3")
                }else if item == item3 {
                    print("My Recruits")
                    self.moveProspect(prospectId: prospectId, crmFlag:  "2")
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func moveProspect(prospectId: String, crmFlag: String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contactId":prospectId,
                         "newCrmFlag" : crmFlag]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "moveRowCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result as! String, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
           
        };
    }
    
    @IBAction func actionAddToGroup(_ sender:UIButton) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateRecruitList),
            name: NSNotification.Name(rawValue: "UpdateRecruitList"),
            object: nil)
        if self.arrSelectedRecords.count > 0 {
            let storyBoard = UIStoryboard(name:"MyProspects", bundle:nil)
            let vc = (storyBoard.instantiateViewController(withIdentifier: "idAddToGroupView")) as! AddToGroupView
            let selectedIDs = self.arrSelectedRecords.joined(separator: ",")
            vc.selectedIDs = selectedIDs
            vc.className = "Recruit"
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one Recruit.")
            return
        }
    }
}

extension MyRecruitsView {
    @IBAction func actionMoreOptions(_ sender:AnyObject) {
        
        let item2 = ActionSheetItem(title: "Import Recruits CSV", value: 2)
        let item3 = ActionSheetItem(title: "Export Recruits", value: 3)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item2, item3, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item2 {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateRecruitList),
                        name: NSNotification.Name(rawValue: "UpdateRecruitList"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idImportCsvFileVC") as! ImportCsvFileVC
                    vc.crmFlag = "4"
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    self.present(vc, animated: false, completion: nil)
                }else if item == item3 {
                    self.prospectCsvArray = []
                    for obj in self.arrProspectData {
                        self.prospectCsvArray.append(obj as! Dictionary<String, AnyObject>)
                    }
                    print(self.prospectCsvArray)
                    self.createCSV(from: self.prospectCsvArray, crmFlag: "4")
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func createCSV(from recArray:[Dictionary<String, AnyObject>], crmFlag : String) {
        
        var csvString = "fname, lname, email, phone\n"
        
        
        for dct in recArray {
            csvString = csvString.appending("\n\(String(describing: dct["contact_fname"]!)), \(String(describing: dct["contact_lname"]!)), \(String(describing: dct["contact_email"]!)), \(String(describing: dct["contact_phone"]!))")
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("csvRecruits.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            self.exportCSVAPI(crmFlag : crmFlag)
            
        } catch {
            print("error creating file")
        }
        
    }
    
    func exportCSVAPI(crmFlag : String){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "crmFlag":crmFlag,
                         "csvFileContent": ""]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "sendCsvbyEmailCrm", param:dictParam as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                
                let alertVC = PMAlertController(title: "", description: "Recruits exported successfully.", image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionSortOptions(_ sender:AnyObject) {
        
        let item1 = ActionSheetItem(title: "Sort by alphabetically", value: 1)
        let item2 = ActionSheetItem(title: "Sort by date", value: 2)
        let item3 = ActionSheetItem(title: "Sort by tag (A-Z)", value: 3)
        let item4 = ActionSheetItem(title: "Sort by tag (Z-A)", value: 4)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, item3, item4, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    self.strSortBy = ""
                    self.strSortByAsce = ""
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else if item == item2 {
                    self.strSortBy = "contact_created"
                    self.strSortByAsce = ""
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else if item == item3 {
                    self.strSortBy = ""
                    self.strSortByAsce = "1"
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else if item == item4 {
                    self.strSortBy = ""
                    self.strSortByAsce = "2"
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            }
        }
        sheet.present(in: self, from: self.view)
        
    }
}


extension MyRecruitsView {
    @IBAction func actionSetTag(_ sender: UIButton) {
        var arrId : [String] = []
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        let contact_id = arrId[sender.tag]
        setTagCrm(contact_id:contact_id)
    }
    
    func setTagCrm(contact_id:String) {
        
        
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrTagTitle.count {
            let item = ActionSheetItem(title: self.arrTagTitle[i], value: self.arrTagId[i])
            items.append(item)
        }
        let item1 = ActionSheetItem(title: "Add custom tag", value: 001)
        let item2 = ActionSheetItem(title: "Remove tag", value: 002)
        let button = ActionSheetCancelButton(title: "Dismiss")
        items.append(item1)
        items.append(item2)
        items.append(button)
        
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item.title == "Add custom tag" && item == item1 {
                    
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.setCustomTagCRM),
                        name: NSNotification.Name(rawValue: "ADDCUSTOMTAG"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idManageCustomTagView") as! ManageCustomTagView
                    vc.contact_id = contact_id
                    vc.isUpdate = false
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationStyle = .custom
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }else if item.title == "Remove tag" && item == item2 {
                    self.apiCallForUpdateTag(tag: "", tagId: "", contact_id: contact_id)
                }else{
                    self.apiCallForUpdateTag(tag: item.title, tagId: "\(item.value!)", contact_id: contact_id)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @objc func setCustomTagCRM(notification: NSNotification){
        print(notification.userInfo as Any)
        if let info = notification.userInfo {
            let tagName = info["tagName"] as? String ?? ""
            let contact_id = info["contact_id"] as? String ?? ""
            self.apiCallForUpdateTag(tag: tagName, tagId: "", contact_id: contact_id)
        }
    }
    
    func apiCallForUpdateTag(tag:String, tagId:String, contact_id:String){
        let dictParam = ["contact_id": contact_id,
                         "contact_category_title":tag,
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
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getProspectData(sortBy:self.strSortBy, isacs: self.strSortByAsce)
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
    
    func getCategoryList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"4"]
        
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
                    self.arrTagTitle = []
                    self.arrTagId = []
                    let arrTag = dictJsonData.value(forKey: "contact_category") as! [AnyObject]
                    for tag in arrTag {
                        self.arrTagTitle.append("\(tag["userTagName"] as? String ?? "")")
                        self.arrTagId.append("\(tag["userTagId"] as? String ?? "")")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
                
            }
        };
        
    }
}
