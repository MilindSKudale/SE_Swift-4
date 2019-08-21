//
//  EditEvent.swift
//  SENew
//
//  Created by Milind Kudale on 18/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EventKit
import Sheeeeeeeeet
import AMGCalendarManager

class EditEvent: UIViewController {

    @IBOutlet var txtEventTitle : UITextField!
    @IBOutlet var txtEventTag : UITextField!
    @IBOutlet var txtFromDate : UITextField!
    @IBOutlet var txtToDate : UITextField!
    @IBOutlet var txtFromTime : UITextField!
    @IBOutlet var txtToTime : UITextField!
    @IBOutlet var switchSetReminder : PVSwitch!
    @IBOutlet var txtGoalCount : UITextField!
    @IBOutlet var txtEventDetails : GrowingTextView!
    @IBOutlet var viewSetRemindertOption : UIView!
    @IBOutlet var btnEmail : UIButton!
    @IBOutlet var btnSMS : UIButton!
    @IBOutlet var btnBoth : UIButton!
    @IBOutlet var viewRecurEvent : UIView!
    @IBOutlet var btnThisEvent : UIButton!
    @IBOutlet var btnFollowEvent : UIButton!
    @IBOutlet var btnAllEvent : UIButton!
    
    var reminder = ""
    var reminderType = ""
    var selection = ""
    var isGoogleEvent = ""
    
    var strStartDate = ""
    var startTime = Date()
    var endTime = Date()
    var startDate = Date()
    var endDate = Date()
    let eventStore = EKEventStore()
    
    var eventData : [String:AnyObject]!
    var eventId = ""
    var googleEventId = ""
    var applyAll = "1"
    var startDateValue = ""
    var reminderValue = ""
    var receiveOn = ""
    var isAppleEvent = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtToDate.delegate = self
        self.txtToTime.delegate = self
        self.txtFromDate.delegate = self
        self.txtFromTime.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        assignEventData()
        print(eventData)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchActionSetReminder(_ sender: PVSwitch) {
        if !sender.isOn {
            self.reminder = ""
            self.reminderType = ""
            self.viewSetRemindertOption.isHidden = true
        }else{
            self.viewSetRemindertOption.isHidden = false
            self.reminder = "on"
            self.reminderType = "Email"
            self.updateSetReminderRadio(btnEmail)
        }
    }

    @IBAction func actionSelectEmail(_ sender: UIButton) {
        self.updateSetReminderRadio(sender)
        self.reminderType = "Email"
    }
    
    @IBAction func actionSelectSms(_ sender: UIButton) {
        self.updateSetReminderRadio(sender)
        self.reminderType = "Sms"
    }
    
    @IBAction func actionSelectBoth(_ sender: UIButton) {
        self.updateSetReminderRadio(sender)
        self.reminderType = "Both"
    }
    
    func updateSetReminderRadio(_ sender:UIButton) {
        self.btnEmail.isSelected = false
        self.btnSMS.isSelected = false
        self.btnBoth.isSelected = false
        sender.isSelected = true
        self.reminder = "on"
    }
    
    @IBAction func actionSetOnlyThisEvent(sender: UIButton) {
        btnThisEvent.isSelected = true
        btnFollowEvent.isSelected = false
        btnAllEvent.isSelected = false
        self.applyAll = "1"
    }
    
    @IBAction func actionSetThisAndAllFollowing(sender: UIButton) {
        btnThisEvent.isSelected = false
        btnFollowEvent.isSelected = true
        btnAllEvent.isSelected = false
        self.applyAll = "2"
    }
    
    @IBAction func actionSetAllEvents(sender: UIButton) {
        btnThisEvent.isSelected = false
        btnFollowEvent.isSelected = false
        btnAllEvent.isSelected = true
        self.applyAll = "3"
    }
    
    @IBAction func actionUpdateEvent(_ sender:UIButton){
        
        if validate() == true {
            
            var dictParam : [String:String] = [:]
            dictParam["user_id"] = userID
            dictParam["platform"] = "3"
            dictParam["edit_id"] = eventData["edit_id"] as? String ?? ""
            dictParam["tag"] = txtEventTag.text
            dictParam["task_to_date"] = txtToDate.text ?? ""
            dictParam["task_to_time"] = txtToTime.text ?? ""
            dictParam["goal_id"] = txtEventTitle.text ?? ""
            dictParam["task_details"] = txtEventDetails.text ?? ""
            dictParam["complete_goals"] = txtGoalCount.text ?? ""
            dictParam["task_from_time"] = txtFromTime.text ?? ""
            dictParam["task_from_date"] = txtFromDate.text ?? ""
            dictParam["reciveOn"] = self.reminderType
            dictParam["reminder"] = self.reminder
            dictParam["applyAll"] = self.applyAll
            dictParam["googleCalRecurEvent"] = eventData["googleCalRecurEventId"] as? String ?? ""
            dictParam["randomNumberValue"] = eventData["randomNumber"] as? String ?? ""
            dictParam["repeatEventFlag"] = eventData["googleCalEventFlag"] as? String ?? ""
            dictParam["iosEventFlag"] = isAppleEvent
            dictParam["iosCalEventId"] = eventData["iosCalEventId"] as? String ?? ""
            dictParam["iosCalenderRecurData"] = eventData["iosCalenderRecurData"] as? String ?? ""
            
            print(dictParam)
            if isAppleEvent == "1" {
                let recString = eventData["iosCalenderRecurData"] as? String ?? ""
                if recString == "" {
                    self.editAppleCalenderThisEventOnly(dict : dictParam)
                }else{
                    self.updateAppCalendarEvents(dict : dictParam)
                }
                
            }else{
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.updateEvent(dict : dictParam)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                
            }
            
        }
    }
    
    func validate() -> Bool {
        
        if txtEventTitle.text! == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter event title.")
            return false
        }
        return true
        
    }
}

extension EditEvent {
    func assignEventData(){
        
        txtEventTitle.text = eventData["goal_name"] as? String
        txtEventTag.text = eventData["tag"] as? String
        txtGoalCount.text = eventData["completedGoals"] as? String
        txtEventDetails.text = eventData["task_details"] as? String
        eventId = eventData["edit_id"] as! String
        receiveOn = eventData["reciveOn"] as? String ?? ""
        isAppleEvent = "\(eventData["iosEventFlag"]!)"
        
        if receiveOn != "" {
            self.viewSetRemindertOption.isHidden = false
            self.switchSetReminder.isOn = true
            if receiveOn == "Email" {
                updateSetReminderRadio(self.btnEmail)
            }else if receiveOn == "Sms" {
                updateSetReminderRadio(self.btnSMS)
            }else if receiveOn == "Both" {
                updateSetReminderRadio(self.btnBoth)
            }
            reminderValue = "on"
        }else{
            reminderValue = ""
            self.switchSetReminder.isOn = false
            self.viewSetRemindertOption.isHidden = true
        }
        startDate = self.stringToDate(strDate: eventData["task_fromdt"] as? String ?? "")
        
        startDateValue = eventData["task_fromdt"] as? String ?? ""
        endDate = self.stringToDate(strDate: eventData["task_todt"] as? String ?? "")
        
        startTime = self.stringToDate(strDate: eventData["task_fromdt"] as? String ?? "")
        endTime = self.stringToDate(strDate: eventData["task_todt"] as? String ?? "")
        
        let sd = self.dateToString(dt: startDate)
        let ed = self.dateToString(dt: endDate)
        let st = self.dateToStringTime(dt: startTime)
        let et = self.dateToStringTime(dt: endTime)
        
        txtFromDate.text = sd
        txtToDate.text = ed
        txtFromTime.text = st
        txtToTime.text = et
        
        let isGoogle = "\(eventData["googleCalRecurEventId"]!)"
        if isGoogle != "" {
            applyAll = "1"
            viewRecurEvent.isHidden = false
            btnThisEvent.isSelected = true
            btnFollowEvent.isSelected = false
            btnAllEvent.isSelected = false
            isGoogleEvent = "Yes"
            googleEventId = "\(eventData["googleCalEventId"]!)"
        }else{
            let randomNumber = "\(eventData["randomNumber"]!)"
            if randomNumber != "" && randomNumber != "0" {
                applyAll = "1"
                viewRecurEvent.isHidden = false
                btnThisEvent.isSelected = true
                btnFollowEvent.isSelected = false
                btnAllEvent.isSelected = false
            }else{
                viewRecurEvent.isHidden = true
                btnThisEvent.isSelected = false
                btnFollowEvent.isSelected = false
                btnAllEvent.isSelected = false
            }
            isGoogleEvent = "No"
            googleEventId = ""
        }
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: strDate)!
    }
    
    func stringToDateApple(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: dt)
    }
    func dateToStringTime(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: dt)
    }
    
    func updateEvent(dict : [String:Any]){
        
        
        OBJCOM.modalAPICall(Action: "updateDailytask", param:dict as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                OBJCOM.hideLoader()
                
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("EditTaskList"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                
                
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    
    
    func updateAppCalendarEvents(dict : [String:Any]) {
        
        let item1 = ActionSheetItem(title: "Only this event", value: 1)
        let item2 = ActionSheetItem(title: "All future events", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                   self.editAppleCalenderThisEventOnly(dict : dict)
                }else if item == item2 {
                    self.editAppleCalenderAllFutureEvents(dict : dict)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func editAppleCalenderThisEventOnly(dict : [String:Any]){
        
        
        if let eventId = eventData["iosCalEventId"] {
            
            let strDt = self.stringToDateApple(strDate: "\(self.txtFromDate.text!) \(self.txtFromTime.text!)")
            let endDt = self.stringToDateApple(strDate: "\(self.txtToDate.text!) \(self.txtToTime.text!)")
            
            let event = self.eventStore.event(withIdentifier: eventId as! String)
            
            event?.startDate = strDt
            event?.endDate = endDt
            event?.title = "\(dict["goal_id"]!)"
            event?.notes = "\(dict["task_details"]!)"
            event?.recurrenceRules = nil
            
            do {
                try self.eventStore.save(event!, span: .thisEvent, commit: true)
                self.updateEvent(dict : dict)
            } catch {
                
            }
        }
    }
    
    
    func editAppleCalenderAllFutureEvents(dict : [String:Any]){
        
        if let eventId = eventData["iosCalEventId"] {
            
            let strDt = self.stringToDateApple(strDate: "\(self.txtFromDate.text!) \(self.txtFromTime.text!)")
            let endDt = self.stringToDateApple(strDate: "\(self.txtToDate.text!) \(self.txtToTime.text!)")
            
            let event = self.eventStore.event(withIdentifier: eventId as! String)
            
            event?.startDate = strDt
            event?.endDate = endDt
            event?.title = "\(dict["goal_id"]!)"
            event?.notes = "\(dict["task_details"]!)"
           
            
            do {
                try self.eventStore.save(event!, span: .futureEvents, commit: true)
                self.updateEvent(dict : dict)
            } catch {
                
            }
        }
    }
}

extension EditEvent : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: APPORANGECOLOR,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        
        if textField == txtFromDate {
            
            datePicker.show("Set Date",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: nil,
                            datePickerMode: .date) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "MM-dd-yyyy"
                                    self.txtFromDate.text = formatter.string(from: dt)
                                    self.txtToDate.text = formatter.string(from: dt)
                                    self.strStartDate = formatter.string(from: dt)
                                    self.startDate = dt
                                }
            }
            return false
        }else if textField == txtToDate {
            datePicker.show("Set Date",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: nil,
                            datePickerMode: .date) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "MM-dd-yyyy"
                                    if dt < self.startDate {
                                        OBJCOM.setAlert(_title: "", message: "'To date' should be greater than 'From date'.")
                                    }else{
                                        self.txtToDate.text = formatter.string(from: dt)
                                    }
                                }
            }
            return false
        }else if textField == txtFromTime {
            datePicker.show("Set Start Time",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: nil,
                            datePickerMode: .time) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "hh:mm a"
                                    self.txtFromTime.text = formatter.string(from: dt)
                                    self.txtToTime.text = formatter.string(from: dt.addingTimeInterval(3600))
                                    self.startTime = dt.addingTimeInterval(60)
                                }
            }
            return false
        }else if textField == txtToTime {
            datePicker.show("Set End Time",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: self.startTime,
                            datePickerMode: .time) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "hh:mm a"
                                    self.txtToTime.text = formatter.string(from: dt)
                                    self.endTime = dt
                                }
                                
            }
            return false
        }
        return true
    }
}
