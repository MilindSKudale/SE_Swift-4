//
//  MyGroupsDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import JJFloatingActionButton

class MyGroupsDashboard: SliderVC {

    var searchBar : DAOSearchBar!
    var txtSearch = UITextField()
    @IBOutlet var searchView : UIView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var btnSelectAll : UIButton!
    @IBOutlet var btnDelete : UIButton!
    
    var isFilter = false;
    var arrGroupData = [AnyObject]()
    var arrGroupName = [String]()
    var arrGroupId = [String]()
    var arrGroupDesc = [AnyObject]()
    var arrGroupNameSearch = [String]()
    var arrGroupDescSearch = [AnyObject]()
    var arrGroupIdSearch = [String]()
    var arrSelectedRecords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBars()
        tblList.tableFooterView = UIView()
        isFilter = false;
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "add_contact")) { item in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateGroupList),
                name: NSNotification.Name(rawValue: "UpdateGroupList"),
                object: nil)
            let storyboard = UIStoryboard(name: "MyGroups", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddGroupView")
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
        }
        actionButton.display(inViewController: self)
    }
    
    func setupSearchBars() {
        self.searchBar = DAOSearchBar.init(frame:CGRect(x: self.searchView.frame.width - 50.0, y: 2.5, width: 40.0, height: 30))
        self.searchBar.delegate = self
        self.txtSearch = searchBar.searchField
        self.txtSearch.delegate = self
        self.searchView.addSubview(searchBar)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateGroupList(notification: NSNotification){
        
        arrSelectedRecords = []
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getGroupData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrGroupData = JsonDict!["result"] as! [AnyObject]
                self.arrGroupName = []
                self.arrGroupDesc = []
                
                self.btnDelete.isHidden = true
                self.btnSelectAll.isSelected = false
                
                self.arrGroupId = []
                self.arrSelectedRecords = []
                for obj in self.arrGroupData {
                    self.arrGroupName.append(obj.value(forKey: "group_name") as! String)
                    self.arrGroupDesc.append(obj.value(forKey: "group_description") as AnyObject)
                    self.arrGroupId.append(obj.value(forKey: "group_id") as! String)
                }
//                if self.arrGroupName.count > 0 {
//                    self.noRecView.isHidden = true
//                }
                
//                self.showHideMoveDeleteButtons()
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
               // self.noRecView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionSelectAll(_ sender: UIButton) {
        self.btnDelete.isHidden = false
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
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
        if self.arrSelectedRecords.count == 0 {
            self.btnSelectAll.isSelected = false
            self.btnDelete.isHidden = true
        }
        self.tblList.reloadData()
        //showHideMoveDeleteButtons()
        print("Selected id >> ",self.arrSelectedRecords)
    }
    
    @IBAction func actionSelectRecord(_ sender: UIButton) {
        view.layoutIfNeeded()
        self.btnDelete.isHidden = false
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
        }
        
        if self.arrSelectedRecords.contains(arrId[sender.tag]){
            if let index = self.arrSelectedRecords.index(of: arrId[sender.tag]) {
                self.arrSelectedRecords.remove(at: index)
            }
        }else{
            self.arrSelectedRecords.append(arrId[sender.tag])
        }
        if self.arrSelectedRecords.count == 0 {
            self.btnSelectAll.isSelected = false
            self.btnDelete.isHidden = true
        }
        print("Selected id >> ",self.arrSelectedRecords)
        self.tblList.reloadData()
        
//        showHideMoveDeleteButtons()
    }
    
    @IBAction func actionDeleteMultipleRecord(_ sender: UIButton) {
        if self.arrSelectedRecords.count>0{
            let strSelectedID = self.arrSelectedRecords.joined(separator: ",")
            let alertVC = PMAlertController(title: "", description: "Do you want to delete selected Group(s)?", image: nil, style: .alert)
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.deleteGroup(GroupId: strSelectedID)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one or more Group(s) to delete.")
        }
    }
}

extension MyGroupsDashboard {
   
    func deleteGroup(GroupId: String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "groupIds":GroupId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteMultipleRowGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getGroupData()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func editGroup(GroupId: String){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateGroupList),
            name: NSNotification.Name(rawValue: "UpdateGroupList"),
            object: nil)
        let storyboard = UIStoryboard(name: "MyGroups", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditGroupView") as! EditGroupView
        vc.groupId = GroupId
        vc.viewClass = false
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: false, completion: nil)
    }
}

extension MyGroupsDashboard : DAOSearchBarDelegate, UITextFieldDelegate {
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
//        self.txtSearch = searchBar.searchField
//        self.txtSearch.delegate = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        arrGroupNameSearch.removeAll()
        arrGroupIdSearch.removeAll()
        arrGroupDescSearch.removeAll()
        
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrGroupData.count {
                let strGName = arrGroupName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let strGDesc = arrGroupDesc[i].lowercased?.range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                
                if strGName != nil || strGDesc != nil{
                    arrGroupNameSearch.append(arrGroupName[i])
                    arrGroupIdSearch.append(arrGroupId[i])
                    arrGroupDescSearch.append(arrGroupDesc[i])
                }
            }
        } else {
            isFilter = false
        }
        tblList.reloadData()
    }
}

extension MyGroupsDashboard : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.arrGroupIdSearch.count
        }else { return self.arrGroupId.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyGroupCell
        if isFilter {
            cell.lblGroupName.text = arrGroupNameSearch[indexPath.row]
            
            if arrGroupDescSearch[indexPath.row] as? String ?? "" != "" {
                cell.lblGroupDesc.text = arrGroupDescSearch[indexPath.row] as? String ?? ""
            }else{
                cell.lblGroupDesc.text = "Not determine"
            }
            cell.configure(name: cell.lblGroupName.text!)
            
            if self.arrSelectedRecords.contains( self.arrGroupIdSearch[indexPath.row]){
                cell.btnSelect.isSelected = true
            }else{
                cell.btnSelect.isSelected = false
            }
        }else{
            cell.lblGroupName.text = arrGroupName[indexPath.row]
            if arrGroupDesc[indexPath.row] as? String ?? "" != "" {
                cell.lblGroupDesc.text = arrGroupDesc[indexPath.row] as? String ?? ""
            }else{
                cell.lblGroupDesc.text = "Not determine"
            }
            cell.configure(name: cell.lblGroupName.text!)
            if self.arrSelectedRecords.contains( self.arrGroupId[indexPath.row]){
                cell.btnSelect.isSelected = true
            }else{
                cell.btnSelect.isSelected = false
            }
        }
        
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(actionSelectRecord), for: .touchUpInside)
        return cell
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let assignAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Assign", handler: { (action, view, completion) in
            //TODO: Assign
            self.arrSelectedRecords.removeAll()
            var arrId = [String]()
            var arrGName = [String]()
            if self.isFilter {
                arrId = self.arrGroupIdSearch
                arrGName = self.arrGroupNameSearch
            }else{
                arrId = self.arrGroupId
                arrGName = self.arrGroupName
            }
            let name = "\(arrGName[indexPath.row])"
            let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddEmailsToEC") as! AddEmailsToEC
            vc.contactId = arrId[indexPath.row]
            vc.contactName = name
            vc.isGroup = true
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
            
        })
        
        let editAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Edit", handler: { (action, view, completion) in
            //TODO: Edit
            var arrId = [String]()
            if self.isFilter {
                arrId = self.arrGroupIdSearch
            }else{
                arrId = self.arrGroupId
            }
            let selectedID = arrId[indexPath.row]
            print("SelectedID >> ",selectedID)
            self.editGroup(GroupId: selectedID)
            
        })
        
        let deleteAction = UIContextualAction.init(style: UIContextualAction.Style.destructive, title: "Delete", handler: { (action, view, completion) in
            //TODO: Delete
            var arrId = [String]()
            var arrNm = [String]()
            if self.isFilter {
                arrId = self.arrGroupIdSearch
                arrNm = self.arrGroupNameSearch
            }else{
                arrId = self.arrGroupId
                arrNm = self.arrGroupName
            }
            let selectedID = arrId[indexPath.row]
            let alertVC = PMAlertController(title: "", description: "Do you want to delete '\(arrNm[indexPath.row])' group?", image: nil, style: .alert)
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.deleteGroup(GroupId: selectedID)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        })
        assignAction.image = UIImage(named: "assign_wh")
        editAction.image = UIImage(named: "edit_wh")
        deleteAction.image = UIImage(named: "delete_wh")
        assignAction.backgroundColor = UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0)
        editAction.backgroundColor = UIColor(red:0.49, green:0.34, blue:0.89, alpha:1.0)
        deleteAction.backgroundColor = UIColor(red:0.93, green:0.33, blue:0.31, alpha:1.0)
        deleteAction.backgroundColor = UIColor.red
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction, assignAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var arrId = [String]()
        if self.isFilter {
            arrId = self.arrGroupIdSearch
        }else{
            arrId = self.arrGroupId
        }
        let storyboard = UIStoryboard(name: "MyGroups", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idGroupDetailsView") as! GroupDetailsView
        vc.groupId = arrId[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
}
