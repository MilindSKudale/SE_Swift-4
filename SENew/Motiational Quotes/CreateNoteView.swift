//
//  CreateNoteView.swift
//  SENew
//
//  Created by Milind Kudale on 25/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

var arrNotesColor = [UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0), UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0), UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0), UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0), UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0), UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)]

class CreateNoteView: UIViewController {

    @IBOutlet weak var txtViewNote : GrowingTextView!
    @IBOutlet weak var btnSetDate : UIButton!
    @IBOutlet weak var btnSetTime : UIButton!
    @IBOutlet var stackBtn : UIStackView!
    @IBOutlet var stackBtnR : UIButton!
    @IBOutlet var stackBtnB : UIButton!
    @IBOutlet var stackBtnG : UIButton!
    @IBOutlet var stackBtnV : UIButton!
    @IBOutlet var stackBtnO : UIButton!
    @IBOutlet var stackBtnWhite : UIButton!
    
    @IBOutlet weak var repeatSwitch: PVSwitch!
    @IBOutlet weak var viewRepeat : UIView!
    
    @IBOutlet weak var btnDaily : UIButton!
    @IBOutlet weak var btnWeekly : UIButton!
    @IBOutlet weak var viewDaily : UIView!
    @IBOutlet weak var viewWeekly : UIView!
    
    @IBOutlet var btnEndsOn : UIButton!
    @IBOutlet var weekBtnSun : UIButton!
    @IBOutlet var weekBtnMon : UIButton!
    @IBOutlet var weekBtnTue : UIButton!
    @IBOutlet var weekBtnWed : UIButton!
    @IBOutlet var weekBtnThu : UIButton!
    @IBOutlet var weekBtnFri : UIButton!
    @IBOutlet var weekBtnSat : UIButton!
    @IBOutlet var txtWeeks : UITextField!
    
    var arrSelectedWeekDays = [String]()
    var repeatFlag = "0"
    var repeatEndDate = ""
    var repeatNoOfWeeks = ""
    var repeatWeekDays = ""
    var minDateRepeat = Date()
    
    var setDate = ""
    var setTime = ""
    var setColor = ""
    var arrStackBtn = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func designUI(){
        arrStackBtn = [stackBtnR, stackBtnB, stackBtnG, stackBtnO, stackBtnV, stackBtnWhite]
        
        for i in 0 ..< arrStackBtn.count {
            arrStackBtn[i].backgroundColor = arrNotesColor[i]
            arrStackBtn[i].layer.cornerRadius = 15
            arrStackBtn[i].layer.borderColor = UIColor.lightGray.cgColor
            arrStackBtn[i].layer.borderWidth = 0.3
            
            arrStackBtn[i].clipsToBounds = true
            if i == arrStackBtn.count - 1 {
                arrStackBtn[i].isSelected = true
                
            }else{
                arrStackBtn[i].isSelected = false
            }
        }
        let dt = Date()
        self.minDateRepeat = dt
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        setDate = formatter.string(from: dt)
        self.repeatEndDate = formatter.string(from: self.minDateRepeat)
        formatter.dateFormat = "hh:mm a"
        setTime = formatter.string(from: dt)
        
        self.arrSelectedWeekDays = []
        let selectedDay = dt.dayNumberOfWeek()!
        let arrWeekDays = [weekBtnSun, weekBtnMon, weekBtnTue, weekBtnWed, weekBtnThu, weekBtnFri, weekBtnSat]
        let arrDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for i in 0 ..< arrWeekDays.count {
            if i == selectedDay - 1 {
                self.arrSelectedWeekDays.append(arrDays[i])
                self.setBtnSelected(arrWeekDays[i]!, true)
            }else{
                self.setBtnSelected(arrWeekDays[i]!, false)
            }
            self.setBtnBorder(arrWeekDays[i]!)
        }
        
        self.btnSetDate.setTitle(setDate, for: .normal)
        self.btnSetTime.setTitle(setTime, for: .normal)
        self.btnEndsOn.setTitle(setDate, for: .normal)
        self.setColor = ""
        
        self.repeatSwitch.isOn = false
        self.viewRepeat.isHidden = true
        
        self.repeatFlag = "0"
        txtWeeks.text = "1"
    }
    
    @IBAction func actionSetDate(_ sender:UIButton){
        
        DatePickerDialog().show("", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.setDate = formatter.string(from: dt)
                self.repeatEndDate = formatter.string(from: dt)
                self.minDateRepeat = dt
                self.btnEndsOn.setTitle(self.repeatEndDate, for: .normal)
            }
        }
    }
    
    @IBAction func actionSetTime(_ sender:UIButton){
        
        DatePickerDialog().show("", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .time) {
            (date) -> Void in
            if let dt = date {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm:ss a"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.setTime = formatter.string(from: dt)
            }
        }
        
    }
    
    @IBAction func actionSetColorRed(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "pink"
    }
    
    @IBAction func actionSetColorBlue(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "blue"
    }
    
    @IBAction func actionSetColorGreen(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "green"
    }
    
    @IBAction func actionSetColorOrange(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "orange"
    }
    
    @IBAction func actionSetColorViolet(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "violet"
    }
    
    @IBAction func actionSetColorDefault(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "white"
    }
    
    
    func updateButton(_ sender: UIButton){
        arrStackBtn.forEach { $0.isSelected = false }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func actionAddNote(_ sender:UIButton){
        if txtViewNote.text != "" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                actionAddNoteAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Please write contents in note.")
        }
    }
}

extension String {
    var withoutHtmlTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

extension CreateNoteView {
    
    func actionAddNoteAPI(){
        
        print(txtViewNote.text)
        print(String(txtViewNote.text))
        
        if self.repeatFlag == "0" {
            self.repeatEndDate = ""
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "1" {
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "2" {
            self.repeatEndDate = ""
            if self.txtWeeks.text == "" || self.txtWeeks.text == "0" {
                OBJCOM.setAlert(_title: "", message: "Please set week count greater than 0.")
                self.txtWeeks.text = "1"
                return
            }else{
                self.repeatNoOfWeeks = self.txtWeeks.text ?? "1"
            }
            
            if self.arrSelectedWeekDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select atleast one  week day for set reminder.")
                return
            }else{
                self.repeatWeekDays = self.arrSelectedWeekDays.joined(separator: ",")
            }
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteText": String(txtViewNote.text).withoutHtmlTags,
                         "scratchNoteColor":setColor,
                         "scratchNoteReminderDate":setDate,
                         "scratchNoteReminderTime":setTime,
                         "scratchNoteReminderRepeat":self.repeatFlag,
                         "scratchNoteReminderWeeklyDays":self.repeatWeekDays,
                         "scratchNoteReminderWeeklyEnds":self.repeatNoOfWeeks,
                         "scratchNoteReminderDailyEndDate":self.repeatEndDate] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["IsSuccess"] as AnyObject
                print(result)
                NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList"), object: nil)
                self.dismiss(animated: true, completion: nil)
                
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.hideLoader()
            }
            
        };
    }

    @IBAction func switchValueDidChange(_ sender: PVSwitch) {
        if repeatSwitch.isOn == true {
            self.viewRepeat.isHidden = false
            self.repeatFlag = "1"
            self.btnDaily.isSelected = true
            self.btnWeekly.isSelected = false
            self.viewDaily.isHidden = false
            self.viewWeekly.isHidden = true
        } else {
            self.viewRepeat.isHidden = true
            self.repeatFlag = "0"
        }
    }
    
    @IBAction func actionSetReminderDaily(_ sender:UIButton){
        self.btnDaily.isSelected = true
        self.btnWeekly.isSelected = false
        self.viewDaily.isHidden = false
        self.viewWeekly.isHidden = true
        self.repeatFlag = "1"
    }
    
    @IBAction func actionSetReminderWeekly(_ sender:UIButton){
        self.btnDaily.isSelected = false
        self.btnWeekly.isSelected = true
        self.viewDaily.isHidden = true
        self.viewWeekly.isHidden = false
        self.repeatFlag = "2"
    }
    
    @IBAction func actionSetEndDateForDailyReminder(_ sender:UIButton){
        DatePickerDialog().show("Reminder ends on", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: self.minDateRepeat, maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.repeatEndDate = formatter.string(from: dt)
            }
        }
    }
    
    @IBAction func actionBtnSunday(sender: UIButton) {
       // sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Sun") {
            if let index = self.arrSelectedWeekDays.index(of: "Sun") {
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Sun")
            self.setBtnSelected(sender, true)
        }
    }
    @IBAction func actionBtnMonday(sender: UIButton) {
     //   sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Mon") {
            if let index = self.arrSelectedWeekDays.index(of: "Mon"){
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Mon")
            self.setBtnSelected(sender, true)
        }
    }
    @IBAction func actionBtnTuesday(sender: UIButton) {
       // sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Tue") {
            if let index = self.arrSelectedWeekDays.index(of: "Tue") {
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Tue")
            self.setBtnSelected(sender, true)
        }
    }
    @IBAction func actionBtnWedensday(sender: UIButton) {
        //sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Wed") {
            if let index = self.arrSelectedWeekDays.index(of: "Wed") {
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Wed")
            self.setBtnSelected(sender, true)
        }
    }
    @IBAction func actionBtnThursday(sender: UIButton) {
        //sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Thu") {
            if let index = self.arrSelectedWeekDays.index(of: "Thu") {
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Thu")
            self.setBtnSelected(sender, true)
        }
    }
    @IBAction func actionBtnFriday(sender: UIButton) {
       // sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Fri") {
            if let index = self.arrSelectedWeekDays.index(of: "Fri") {
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Fri")
            self.setBtnSelected(sender, true)
        }
    }
    @IBAction func actionBtnSaterday(sender: UIButton) {
       // sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Sat") {
            if let index = self.arrSelectedWeekDays.index(of: "Sat") {
                self.arrSelectedWeekDays.remove(at: index)
                self.setBtnSelected(sender, false)
            }
        }else{
            self.arrSelectedWeekDays.append("Sat")
            self.setBtnSelected(sender, true)
        }
    }
    
    func setBtnBorder (_ btn:UIView){
        btn.layer.borderColor = APPGRAYCOLOR.cgColor
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
    }
    
    func setBtnSelected (_ btn:UIButton, _ isselected : Bool){
        if isselected == true {
            btn.backgroundColor = APPBLUECOLOR
            btn.setTitleColor(.white, for: .normal)
        }else{
            btn.backgroundColor = .white
            btn.setTitleColor(.black, for: .normal)
        }
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
