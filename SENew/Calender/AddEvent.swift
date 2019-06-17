//
//  AddEvent.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EventKit
import AMGCalendarManager

var dictForRepeate = [String:String]()

class AddEvent: UIViewController {

    @IBOutlet var txtEventTitle : UITextField!
    @IBOutlet var txtEventTag : UITextField!
    @IBOutlet var txtFromDate : UITextField!
    @IBOutlet var txtToDate : UITextField!
    @IBOutlet var txtFromTime : UITextField!
    @IBOutlet var txtToTime : UITextField!
    @IBOutlet var switchAddToGoogleCal : PVSwitch!
    @IBOutlet var switchRepeat : PVSwitch!
    @IBOutlet var switchSetReminder : PVSwitch!
    @IBOutlet var txtGoalCount : UITextField!
    @IBOutlet var txtEventDetails : GrowingTextView!
    @IBOutlet var viewRepeatOption : UIView!
    @IBOutlet var btnWeekly : UIButton!
    @IBOutlet var btnMonthly : UIButton!
    @IBOutlet var btnFor90days : UIButton!
    @IBOutlet var viewSetRemindertOption : UIView!
    @IBOutlet var btnEmail : UIButton!
    @IBOutlet var btnSMS : UIButton!
    @IBOutlet var btnBoth : UIButton!

    var reminder = ""
    var reminderType = ""
    var selection = ""
    var isGoogleEvent = ""
    
    var strStartDate = ""
    var strEndDate = ""
    var startTime = Date()
    var endTime = Date()
    var startDate = Date()
    var endDate = Date()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    func designUI(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        txtFromDate.text = formatter.string(from: date)
        txtToDate.text = formatter.string(from: date)
        strStartDate = formatter.string(from: date)
        strEndDate = formatter.string(from: date)
        formatter.dateFormat = "hh:mm a"
        self.startTime = date.addingTimeInterval(60)
        txtFromTime.text = formatter.string(from: date)
        txtToTime.text = formatter.string(from: date.addingTimeInterval(3600))
        
        self.switchAddToGoogleCal.isOn = false
        self.switchRepeat.isOn = false
        self.switchSetReminder.isOn = false
        self.viewRepeatOption.isHidden = true
        self.viewSetRemindertOption.isHidden = true
        
        self.isGoogleEvent = "No"
        dictForRepeate = ["repeatEvery":"1",
                          "repeatBy":"",
                          "day":"",
                          "ends":"",
                          "ondate":"",
                          "Occurences":""]
        
        self.reminder = ""
        self.reminderType = ""
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchActionAddToGoogleCal(_ sender: PVSwitch) {
        if !sender.isOn {
            self.isGoogleEvent = "No"
        }else{
            self.isGoogleEvent = "Yes"
        }
        
    }
    
    @IBAction func switchActionRepeat(_ sender: PVSwitch) {
        if !sender.isOn {
            self.btnWeekly.isSelected = false
            self.btnMonthly.isSelected = false
            self.btnFor90days.isSelected = false
            self.viewRepeatOption.isHidden = true
        }else{
            self.viewRepeatOption.isHidden = false
        }
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
    
    @IBAction func actionSelectWeekly(_ sender: UIButton) {
       self.updateRepeatRadio(sender)
    
        self.selection = "weekly"
        let storyboard = UIStoryboard(name: "Calender", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpWeeklyEventView") as! PopUpWeeklyEventView
        vc.strStartDate = self.strStartDate
        vc.strEndDate = self.strEndDate
        vc.endDate = self.endDate
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionSelectMonthly(_ sender: UIButton) {
        self.selection = "monthly"
        self.updateRepeatRadio(sender)
        let storyboard = UIStoryboard(name: "Calender", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpMonthlyView") as! PopUpMonthlyView
        vc.strStartDate = self.strStartDate
        vc.strEndDate = self.strEndDate
        vc.endDate = self.endDate
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionSelectFor90days(_ sender: UIButton) {
        self.updateRepeatRadio(sender)
        self.selection = "daily"
        let storyboard = UIStoryboard(name: "Calender", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpFor90days") as! PopUpFor90days
        vc.strStartDate = self.strStartDate
        vc.strEndDate = self.strEndDate
        vc.endDate = self.endDate
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
    
    func updateRepeatRadio(_ sender:UIButton) {
        self.btnWeekly.isSelected = false
        self.btnMonthly.isSelected = false
        self.btnFor90days.isSelected = false
        sender.isSelected = true
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
    
    @IBAction func actionAddEvent(_ sender: UIButton) {
        if txtEventTitle.text! == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter event name.")
            return 
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                
                if isGoogleEvent == "Yes" {
                    self.createEventGoogleCalender()
                }else{
                    self.addEventInSECalender()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func addEventInSECalender(){
        
        var dictParam : [String:String] = [:]
        dictParam["user_id"] = userID
        dictParam["platform"] = "3"
        dictParam["selection"] = self.selection
        dictParam["occurence"] = dictForRepeate["Occurences"] ?? ""
        dictParam["tag"] = txtEventTag.text ?? ""
        dictParam["goal_id"] = txtEventTitle.text ?? ""
        dictParam["task_to_date"] = txtToDate.text ?? ""
        dictParam["task_to_time"] = txtToTime.text ?? ""
        dictParam["task_details"] = txtEventDetails.text ?? ""
        dictParam["complete_goals"] = txtGoalCount.text ?? ""
        dictParam["task_from_time"] = txtFromTime.text ?? ""
        dictParam["task_from_date"] = txtFromDate.text ?? ""
        dictParam["intervalVal"] = dictForRepeate["repeatEvery"] ?? ""
        dictParam["reminder"] = reminder
        dictParam["ends"] = dictForRepeate["ends"] ?? ""
        dictParam["day"] = dictForRepeate["day"] ?? ""
        dictParam["onDate"] = dictForRepeate["ondate"] ?? ""
        dictParam["repeatBy"] = dictForRepeate["repeatBy"] ?? ""
        dictParam["reciveOn"] = self.reminderType
        dictParam["calenderGoogle"] = "0"
        print(dictParam)
        
        OBJCOM.modalAPICall(Action: "createEventAppCalender", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    DispatchQueue.main.async {
                        self.addEventInAppleCalendar(dict: dictParam)
                    }
                    NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func addEventInAppleCalendar(dict: [String:String]){
       
        AMGCalendarManager.shared.createEvent(completion: { (event) in
            guard let event = event else { return }
            let strDt = self.stringToDate(strDate: "\(dict["task_from_date"]!) \(dict["task_from_time"]!)")
            let endDt = self.stringToDate(strDate: "\(dict["task_to_date"]!) \(dict["task_to_time"]!)")
            
            event.startDate = strDt
            event.endDate = endDt
            event.title = "\(dict["goal_id"]!)"
            event.notes = "\(dict["task_details"]!)"
            let recRule = self.getRepeatValue(dict["selection"]!, interval: dict["intervalVal"]!, day: dict["day"]!)
            if recRule != nil {
                event.recurrenceRules = [recRule!]
            }
            AMGCalendarManager.shared.saveEvent(event: event)
        })
        OBJCOM.hideLoader()
    }
    
    func createEventGoogleCalender(){
        OBJCOM.hideLoader()
        var dictParam : [String:String] = [:]
        dictParam["user_id"] = userID
        dictParam["platform"] = "3"
        dictParam["selection"] = self.selection
        dictParam["occurence"] = dictForRepeate["Occurences"] ?? ""
        dictParam["tag"] = txtEventTag.text ?? ""
        dictParam["goal_id"] = txtEventTitle.text ?? ""
        dictParam["task_to_date"] = txtToDate.text ?? ""
        dictParam["task_to_time"] = txtToTime.text ?? ""
        dictParam["task_details"] = txtEventDetails.text ?? ""
        dictParam["complete_goals"] = txtGoalCount.text ?? ""
        dictParam["task_from_time"] = txtFromTime.text ?? ""
        dictParam["task_from_date"] = txtFromDate.text ?? ""
        dictParam["intervalVal"] = dictForRepeate["repeatEvery"] ?? ""
        dictParam["reminder"] = reminder
        dictParam["ends"] = dictForRepeate["ends"] ?? ""
        dictParam["day"] = dictForRepeate["day"] ?? ""
        dictParam["onDate"] = dictForRepeate["ondate"] ?? ""
        dictParam["repeatBy"] = dictForRepeate["repeatBy"] ?? ""
        dictParam["reciveOn"] = self.reminderType
        dictParam["calenderGoogle"] = "1"
        print(dictParam)
       
        NotificationCenter.default.post(name: Notification.Name("CreateGoogleEvent"), object: nil, userInfo: dictParam)
        self.dismiss(animated: true, completion: nil)
        OBJCOM.hideLoader()
    }
    
    func getRepeatValue (_ option : String, interval : String, day : String) -> EKRecurrenceRule?{
        switch option {
        case "daily":
            let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: Int(interval)!, end: nil)
            return rule
        case "weekly":
            var weekDays = [EKRecurrenceDayOfWeek]()
            let dayVal = day.components(separatedBy: ",")
            for obj in dayVal {
                weekDays.append(self.getWeekDays(obj)!)
            }
            let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: Int(interval)!, daysOfTheWeek: weekDays, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
            return rule
        case "monthly":
            let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: Int(interval)!, end: nil)
            return rule
        default:
            return nil
        }
    }
    
    func getWeekDays(_ day:String) -> EKRecurrenceDayOfWeek?{
        switch day {
        case "SU":
            return EKRecurrenceDayOfWeek(.sunday)
        case "MO":
            return EKRecurrenceDayOfWeek(.monday)
        case "TU":
            return EKRecurrenceDayOfWeek(.tuesday)
        case "WE":
            return EKRecurrenceDayOfWeek(.wednesday)
        case "TH":
            return EKRecurrenceDayOfWeek(.thursday)
        case "FR":
            return EKRecurrenceDayOfWeek(.friday)
        case "SA":
            return EKRecurrenceDayOfWeek(.saturday)
        default:
            return nil
        }
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        return dateFormatter.date(from: strDate)!
    }
}

extension AddEvent : UITextFieldDelegate {
    
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
                                        self.strEndDate = formatter.string(from: dt)
                                        self.endDate = dt
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
        
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}

