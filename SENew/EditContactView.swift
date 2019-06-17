//
//  EditContactView.swift
//  SENew
//
//  Created by Milind Kudale on 09/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class EditContactView: UITableViewController {
    
    var sectioncount = 1
    var contactID = ""
    
    @IBOutlet var txtFirstName : UITextField!
    @IBOutlet var txtLastName : UITextField!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPhone : UITextField!
    @IBOutlet var txtNotes : RSKPlaceholderTextView!
    @IBOutlet var switchAddToCal : PVSwitch!
    @IBOutlet var btnCalReminderDate : UIButton!
    @IBOutlet var btnCalReminderTime : UIButton!
    
    @IBOutlet var txtAddress : UITextField!
    @IBOutlet var txtCity : UITextField!
    @IBOutlet var txtState : UITextField!
    @IBOutlet var txtCountry : UITextField!
    @IBOutlet var txtZip : UITextField!
    
    @IBOutlet var txtEmail1 : UITextField!
    @IBOutlet var txtEmail2 : UITextField!
    @IBOutlet var txtPhone1 : UITextField!
    @IBOutlet var txtPhone2 : UITextField!
    @IBOutlet var btnDob : UIButton!
    
    @IBOutlet var btnProspectFor : UIButton!
    @IBOutlet var btnProspectStatus : UIButton!
    @IBOutlet var btnProspectSource : UIButton!
    @IBOutlet var txtIndustry : UITextField!
    @IBOutlet var txtCompanyName : UITextField!
    
    @IBOutlet var btnSelectTag : UIButton!
    
    var strDob = ""
    var selectedTagTitle = ""
    var selectedTagId = "0"
    var arrTagTitle = [String]()
    var arrTagId = [String]()
    var arrProspectFor = [String]()
    var arrProspectStatus = [String]()
    var arrProspectSource = [String]()
    var arrProspectStatusID = [String]()
    var arrProspectSourceID = [String]()
    
    var prospectStatusID = "0"
    var prospectSourceID = "0"
    var calDate = ""
    var calTime = ""
    var isAddToCal = "0"
    var eventDescripId = "0"
    var isCustomTag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addFooter()
        
        let btnSave = UIButton(type: .custom)
        btnSave.frame = CGRect(x: 0, y: 0, width: 90, height: 30)
        btnSave.backgroundColor = APPBLUECOLOR
        btnSave.setTitle("Save", for: .normal)
        btnSave.setTitleColor(.white, for: .normal)
        btnSave.cornerRadius = 5.0
        btnSave.clipsToBounds = true
        
        btnSave.addTarget(self, action: #selector(actionSave(_:)), for: .touchUpInside)
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem (customView: btnSave)], animated: true)
        
        btnCalReminderDate.isHidden = true
        btnCalReminderTime.isHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDropDownData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectioncount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }else if section == 1 {
            return 5
        }else if section == 2 {
            return 3
        }else if section == 3 {
            return 5
        }else if section == 4 {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = APPBLUECOLOR
        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-30, height: headerView.frame.height-10)
        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        headerView.addSubview(label)
        
        if section == 0 {
            label.text = "Basic Information"
        }else if section == 1 {
            label.text = "Address Information"
        }else if section == 2 {
            label.text = "Other Information"
        }else if section == 3 {
            label.text = "Contact Information"
        }else if section == 4 {
            label.text = "Tag"
        }
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    
    func addFooter(){
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        customView.backgroundColor = APPORANGECOLOR
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        button.setTitle("Show other details", for: .normal)
        button.setTitle("Hide other details", for: .selected)
        button.isSelected = false
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        customView.addSubview(button)
        self.tableView.tableFooterView = customView
    }
    
    
    
    @IBAction func actionSave(_ sender:AnyObject){
        if isValidate() == true{
            var prospectForTitle = ""
            if btnProspectFor.titleLabel!.text != "Please select" && btnProspectFor.titleLabel!.text != "" {
                prospectForTitle = btnProspectFor.titleLabel!.text ?? ""
            }
            var dictParam : [String:AnyObject] = [:]
            dictParam["contact_users_id"] = userID as AnyObject
            dictParam["contact_id"] = contactID as AnyObject
            dictParam["platform"] = "3" as AnyObject
            dictParam["contact_flag"] = "1" as AnyObject
            dictParam["contact_fname"] = txtFirstName.text as AnyObject
            dictParam["contact_lname"] = txtLastName.text as AnyObject
            dictParam["contact_email"] = txtEmail.text as AnyObject
            dictParam["contact_phone"] = txtPhone.text as AnyObject
            dictParam["contact_other_email"] = txtEmail2.text as AnyObject
            dictParam["contact_work_email"] = txtEmail1.text as AnyObject
            dictParam["contact_work_phone"] = txtPhone1.text as AnyObject
            dictParam["contact_other_phone"] = txtPhone2.text as AnyObject
            dictParam["contact_company_name"] = txtCompanyName.text as AnyObject
            dictParam["contact_date_of_birth"] = strDob as AnyObject
            dictParam["contact_address"] = txtAddress.text as AnyObject
            dictParam["contact_city"] = txtCity.text as AnyObject
            dictParam["contact_zip"] = txtZip.text as AnyObject
            dictParam["contact_state"] = txtState.text as AnyObject
            dictParam["contact_country"] = txtCountry.text as AnyObject
            dictParam["contact_description"] = txtNotes.text as AnyObject
            dictParam["contact_lead_prospecting_for"] = prospectForTitle as AnyObject
            dictParam["contact_lead_status_id"] = prospectStatusID as AnyObject
            dictParam["contact_lead_source_id"] = prospectSourceID as AnyObject
            dictParam["contact_industry"] = txtIndustry.text as AnyObject
            dictParam["contact_category_title"] = self.selectedTagTitle as AnyObject
            dictParam["contact_category"] = self.selectedTagId as AnyObject
            dictParam["caldate"] = calDate as AnyObject
            dictParam["calTime"] = calTime as AnyObject
            dictParam["addToCalendar"] = isAddToCal as AnyObject
            dictParam["eventDescripId"] = eventDescripId as AnyObject
            
            OBJCOM.modalAPICall(Action: "updateCrm", param:dictParam as [String : AnyObject],  vcObject: self){
                json, staus in
                let success:String = json!["IsSuccess"] as! String
                if success == "true"{
                    OBJCOM.hideLoader()
                    let result = json!["result"] as? String ?? ""
                    let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                    
                    alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        NotificationCenter.default.post(name: Notification.Name("UpdateContactList"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                }else{
                    let result = json!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            }
        }
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToTimeString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: dt)
    }
    
    func dateToDateString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: dt)
    }
    
    func isValidate() -> Bool {
        if txtFirstName.isEmpty && txtLastName.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either first name or last name.")
            return false
        }else if txtEmail.isEmpty && txtPhone.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either email or phone number.")
            return false
        }else if !txtEmail.isEmpty && txtEmail.text?.containsWhitespace == true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmail.isEmpty && OBJCOM.validateEmail(uiObj: txtEmail.text!) != true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtPhone.isEmpty && txtPhone.text!.length < 5 || txtPhone.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than 5 digits and less than 19 digits.")
            return false
        }
        return true
    }
}


extension EditContactView {
    @IBAction func actionClose(_ sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonAction(_ sender: UIButton!) {
        if sender.isSelected {
            sectioncount = 1
            sender.isSelected = false
        }else{
            sectioncount = 5
            sender.isSelected = true
        }
        self.tableView.reloadData()
    }
    
    @IBAction func actionSwitchAddToCal(_ sender:PVSwitch){
        print(sender.isOn)
        if txtNotes.text == "" && sender.isOn == true {
            let alertVC = PMAlertController(title: "", description: "Please add notes to add reminder in calendar.", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                self.switchAddToCal.isOn = false
            }))
            self.present(alertVC, animated: true, completion: nil)
            return
        }else{
            if sender.isOn{
                let currentDate = self.dateToDateString(dt: Date())
                let currentTime = self.dateToTimeString(dt: Date())
                btnCalReminderDate.setTitle(currentDate, for: .normal)
                btnCalReminderTime.setTitle(currentTime, for: .normal)
                btnCalReminderDate.isHidden = false
                btnCalReminderTime.isHidden = false
                self.calDate = currentDate
                self.calTime = currentTime
                self.isAddToCal = "1"
            }else{
                btnCalReminderDate.isHidden = true
                btnCalReminderTime.isHidden = true
                btnCalReminderDate.setTitle("", for: .normal)
                btnCalReminderTime.setTitle("", for: .normal)
                self.calDate = ""
                self.calTime = ""
                self.isAddToCal = "0"
            }
        }
    }
    
    @IBAction func actionSetDate(_ sender:UIButton){
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: subscriptionDate, maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.calDate = formatter.string(from: dt)
            }
        }
    }
    
    @IBAction func actionSetTime(_ sender:UIButton){
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: subscriptionDate, maximumDate: nil, datePickerMode: .time) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.calTime = formatter.string(from: dt)
            }
        }
    }
    
    @IBAction func actionSetDOB(_ sender:UIButton){
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: nil, maximumDate: Date(), datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.strDob = formatter.string(from: dt)
                sender.setTitle(formatter.string(from: dt), for: .normal)
            }
        }
    }
    
    @IBAction func actionProspectingFor(_ sender:UIButton){
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrProspectFor.count {
            let item = ActionSheetItem(title: self.arrProspectFor[i], value: i)
            items.append(item)
        }
        let button = ActionSheetCancelButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionProspectStatus(_ sender:UIButton){
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrProspectStatus.count {
            let item = ActionSheetItem(title: self.arrProspectStatus[i], value: self.arrProspectStatusID[i])
            items.append(item)
        }
        let button = ActionSheetCancelButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                self.prospectStatusID = "\(item.value!)"
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionProspectSource(_ sender:UIButton){
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrProspectSource.count {
            let item = ActionSheetItem(title: self.arrProspectSource[i], value: self.arrProspectSourceID[i])
            items.append(item)
        }
        let button = ActionSheetCancelButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                self.prospectSourceID = "\(item.value!)"
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionSelectTag(_ sender:UIButton){
        
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrTagTitle.count {
            let item = ActionSheetItem(title: self.arrTagTitle[i], value: self.arrTagId[i])
            items.append(item)
        }
        let button = ActionSheetCancelButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                self.selectedTagId = "\(item.value!)"
                self.selectedTagTitle = item.title
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionManageTag(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "MyProspects", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idManageCustomTagView") as! ManageCustomTagView
        vc.crmFlag = "2"
        vc.contact_id = contactID
        vc.isUpdate = true
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
}

extension EditContactView {
    func getDataFromServer(){
        let dictParam = ["userId" : userID,
                         "platform" : "3",
                         "crmFlag" : "2",
                         "contactId" : contactID]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCrmDetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as AnyObject
                if data.count > 0 {
                    self.assignedValuesToFields(dict: data)
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getDropDownData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"2"]
        
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
                    let arrTag = dictJsonData.value(forKey: "contact_category") as! [AnyObject]
                    for tag in arrTag {
                        self.arrTagTitle.append("\(tag["userTagName"] as? String ?? "")")
                        self.arrTagId.append("\(tag["userTagId"] as? String ?? "")")
                    }
                    self.arrProspectFor = dictJsonData.value(forKey: "contact_lead_prospecting_for") as! [String]
                    let arrStatus = dictJsonData.value(forKey: "contact_lead_status_id") as! [AnyObject]
                    for obj in arrStatus {
                        self.arrProspectStatus.append(obj.value(forKey: "zo_lead_status_name") as! String)
                        self.arrProspectStatusID.append(obj.value(forKey: "zo_lead_status_id") as! String)
                    }
                    let arrSource = dictJsonData.value(forKey: "contact_lead_source_id") as! [AnyObject]
                    for obj in arrSource {
                        self.arrProspectSource.append(obj.value(forKey:"zo_lead_source_name") as! String)
                        self.arrProspectSourceID.append(obj.value(forKey:"zo_lead_source_id") as! String)
                    }
                }
                self.getDataFromServer()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func assignedValuesToFields(dict:AnyObject){
        txtFirstName.text = dict["contact_fname"] as? String ?? ""
        txtLastName.text = dict["contact_lname"] as? String ?? ""
        txtEmail.text = dict["contact_email"] as? String ?? ""
        txtPhone.text = dict["contact_phone"] as? String ?? ""
        txtNotes.text = dict["contact_description"] as? String ?? ""
        btnDob.setTitle(dict["contact_date_of_birth"] as? String ?? "", for: .normal)
        self.strDob = dict["contact_date_of_birth"] as? String ?? ""
        txtEmail1.text = dict["contact_work_email"] as? String ?? ""
        txtEmail2.text = dict["contact_other_email"] as? String ?? ""
        txtPhone1.text = dict["contact_work_phone"] as? String ?? ""
        txtPhone2.text = dict["contact_other_phone"] as? String ?? ""
        txtIndustry.text = dict["contact_industry"] as? String ?? ""
        txtCompanyName.text = dict["contact_company_name"] as? String ?? ""
        txtAddress.text = dict["contact_address"] as? String ?? ""
        txtCity.text = dict["contact_city"] as? String ?? ""
        txtState.text = dict["contact_state"] as? String ?? ""
        txtCountry.text = dict["contact_country"] as? String ?? ""
        txtZip.text = dict["contact_zip"] as? String ?? ""
        
        let tagId = "\(dict["contact_category"] as? String ?? "")"
        let tagTitle = dict["contact_category_title"] as? String ?? ""
        if tagTitle == "" {
            btnSelectTag.setTitle("Please select", for: .normal)
            self.selectedTagTitle = ""
            self.selectedTagId = "0"
        }else{
            btnSelectTag.setTitle(tagTitle, for: .normal)
            self.selectedTagTitle = tagTitle
            self.selectedTagId = tagId
        }
        
        let prospectFor = dict["contact_lead_prospecting_for"] as? String ?? ""
        if prospectFor == "" {
            btnProspectFor.setTitle("Please select", for: .normal)
        }else{
            btnProspectFor.setTitle(prospectFor, for: .normal)
        }
        let pStatus = dict["contact_lead_status_id"] as? String ?? ""
        if pStatus == "0" {
            btnProspectStatus.setTitle("Please select", for: .normal)
            prospectStatusID = "0"
        }else{
            btnProspectStatus.setTitle(arrProspectStatus[Int(pStatus)! - 1], for: .normal)
            prospectStatusID = pStatus
        }
        let pSource = dict["contact_lead_source_id"] as? String ?? ""
        if pSource == "0" {
            btnProspectSource.setTitle("Please select", for: .normal)
            prospectSourceID = "0"
        }else{
            btnProspectSource.setTitle(arrProspectSource[Int(pSource)! - 1], for: .normal)
            prospectSourceID = pSource
        }
        
        calDate = dict["caldate"] as? String ?? ""
        calTime = dict["calTime"] as? String ?? ""
        eventDescripId = "\(dict["eventDescripId"] as? String ?? "0")"
        btnCalReminderDate.setTitle(calDate, for: .normal)
        btnCalReminderTime.setTitle(calTime, for: .normal)
        if eventDescripId != "0" && eventDescripId != "" {
            switchAddToCal.isOn = true
            btnCalReminderDate.isHidden = false
            btnCalReminderTime.isHidden = false
            isAddToCal = "1"
        }else{
            switchAddToCal.isOn = false
            btnCalReminderDate.isHidden = true
            btnCalReminderTime.isHidden = true
            isAddToCal = "0"
        }
    }
}
