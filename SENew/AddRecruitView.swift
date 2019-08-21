
//
//  AddProspectView.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AddRecruitView: UITableViewController {
    
    var sectioncount = 1
    
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
    
    var calDate = ""
    var calTime = ""
    var isAddToCal = "0"
    
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectioncount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }else if section == 1 {
            return 5
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
        }
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @IBAction func actionClose(_ sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonAction(_ sender: UIButton!) {
        if sender.isSelected {
            sectioncount = 1
            sender.isSelected = false
        }else{
            sectioncount = 2
            sender.isSelected = true
        }
        self.tableView.reloadData()
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
            if sender.isOn {
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
    
    @IBAction func actionSave(_ sender:AnyObject){
        if isValidate() == true{
            
            
            var dictParam : [String:AnyObject] = [:]
            dictParam["contact_users_id"] = userID as AnyObject
            dictParam["platform"] = "3" as AnyObject
            dictParam["contact_flag"] = "4" as AnyObject
            dictParam["contact_fname"] = txtFirstName.text as AnyObject
            dictParam["contact_lname"] = txtLastName.text as AnyObject
            dictParam["contact_email"] = txtEmail.text as AnyObject
            dictParam["contact_phone"] = txtPhone.text as AnyObject
            dictParam["contact_other_email"] = "" as AnyObject
            dictParam["contact_work_email"] = "" as AnyObject
            dictParam["contact_work_phone"] = "" as AnyObject
            dictParam["contact_other_phone"] = "" as AnyObject
            dictParam["contact_company_name"] = "" as AnyObject
            dictParam["contact_date_of_birth"] = "" as AnyObject
            dictParam["contact_address"] = txtAddress.text as AnyObject
            dictParam["contact_city"] = txtCity.text as AnyObject
            dictParam["contact_zip"] = txtZip.text as AnyObject
            dictParam["contact_state"] = txtState.text as AnyObject
            dictParam["contact_country"] = txtCountry.text as AnyObject
            dictParam["contact_description"] = txtNotes.text as AnyObject
            dictParam["contact_lead_prospecting_for"] = "" as AnyObject
            dictParam["contact_lead_status_id"] = "" as AnyObject
            dictParam["contact_lead_source_id"] = "" as AnyObject
            dictParam["contact_industry"] = "" as AnyObject
            dictParam["contact_category_title"] = "" as AnyObject
            dictParam["contact_category"] = "" as AnyObject
            dictParam["contact_group"] = "" as AnyObject
            dictParam["caldate"] = calDate as AnyObject
            dictParam["calTime"] = calTime as AnyObject
            dictParam["addToCalendar"] = isAddToCal as AnyObject
            dictParam["eventDescripId"] = "0" as AnyObject
            print(dictParam)
            
            OBJCOM.modalAPICall(Action: "addCrm", param: dictParam, vcObject: self){
                json, staus in
                if let json = json {
                    let success:String = json["IsSuccess"] as? String ?? ""
                    if success == "true"{
                        let result = json["result"] as! String
                        OBJCOM.hideLoader()
                        let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                        
                        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                            NotificationCenter.default.post(name: Notification.Name("UpdateRecruitList"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertVC, animated: true, completion: nil)
                    }else{
                        let result = json["result"] as! String
                        OBJCOM.setAlert(_title: "", message: result)
                        OBJCOM.hideLoader()
                    }
                }else{
                    OBJCOM.setAlert(_title: "", message: "Something went to wrong.")
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
