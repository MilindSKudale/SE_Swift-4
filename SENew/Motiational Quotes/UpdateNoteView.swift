//
//  UpdateNoteView.swift
//  SENew
//
//  Created by Milind Kudale on 25/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class UpdateNoteView: UIViewController {

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
    var noteId = ""
    var isView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if noteId == "" {
            return
        }
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getScratchnoteById()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
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
                actionUpdateNoteAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Please write contents in note.")
        }
    }

}

extension UpdateNoteView {
    
    func assignDataToFields(_ data: AnyObject){
        let str = data["scratchNoteText"] as? String ?? ""
        txtViewNote.text = str.htmlToString
        let dtStr = data["scratchNoteReminderDate"] as? String ?? "0000-00-00 00:00"
        let arrDateTime = dtStr.components(separatedBy: " ")
        setDate = arrDateTime[0]
        setTime = arrDateTime[1]
        self.btnSetDate.setTitle(setDate, for: .normal)
        self.btnSetTime.setTitle(setTime, for: .normal)
        self.setColor = data["scratchNoteColor"] as? String ?? ""
        self.selectColor(self.setColor)
        
        let endDtStr = data["scratchNoteReminderDailyEndDate"] as? String ?? "0000-00-00 00:00:00"
        let arrRepeatEndDate = endDtStr.components(separatedBy: " ")
        if endDtStr == "0000-00-00 00:00:00" {
            let dt = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.btnEndsOn.setTitle(formatter.string(from: dt), for: .normal)
            self.repeatEndDate = formatter.string(from: dt)
        }else{
            self.btnEndsOn.setTitle(arrRepeatEndDate[0], for: .normal)
            self.repeatEndDate = arrRepeatEndDate[0]
        }
        
        self.repeatFlag = data["scratchNoteReminderRepeat"] as? String ?? "0"
        if self.repeatFlag == "0" {
            self.repeatSwitch.isOn = false
            self.viewRepeat.isHidden = true
            // self.repeatEndDate = ""
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "1" {
            self.repeatSwitch.isOn = true
            self.viewRepeat.isHidden = false
            self.btnDaily.isSelected = true
            self.btnWeekly.isSelected = false
            self.viewDaily.isHidden = false
            self.viewWeekly.isHidden = true
            
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "2" {
            self.repeatSwitch.isOn = true
            self.viewRepeat.isHidden = false
            self.btnDaily.isSelected = false
            self.btnWeekly.isSelected = true
            self.viewDaily.isHidden = true
            self.viewWeekly.isHidden = false
            
            // self.repeatEndDate = ""
            self.repeatNoOfWeeks = data["scratchNoteReminderWeeklyEnds"] as? String ?? "1"
            self.txtWeeks.text = self.repeatNoOfWeeks
            
            self.repeatWeekDays = data["scratchNoteReminderWeeklyDays"] as? String ?? ""
            
            let arrWeekDays = [weekBtnSun, weekBtnMon, weekBtnTue, weekBtnWed, weekBtnThu, weekBtnFri, weekBtnSat]
            let arrDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            self.arrSelectedWeekDays = []
            if self.repeatWeekDays != "" {
                let arrSelectedDays = self.repeatWeekDays.components (separatedBy: ",")
                
                for i in 0 ..< arrDays.count {
                    if arrSelectedDays.contains(arrDays[i]){
                        self.setBtnSelected(arrWeekDays[i]!, true)
                        self.arrSelectedWeekDays.append(arrDays[i])
                    }else{
                        self.setBtnSelected(arrWeekDays[i]!, false)
                    }
                    
                }
            }else{
                for i in 0 ..< arrWeekDays.count {
                    self.setBtnSelected(arrWeekDays[i]!, false)
                }
            }
        }
    }
    
    func getScratchnoteById(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteId":noteId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                self.assignDataToFields(result)
                OBJCOM.hideLoader()
            }else{
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func actionUpdateNoteAPI(){
        
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
                         "scratchNoteId":noteId,
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
        OBJCOM.modalAPICall(Action: "editScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["IsSuccess"] as AnyObject
                print(result)
                if self.isView == true {
                    NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList1"), object: nil)
                    self.presentingViewController?.presentingViewController?.dismiss (animated: true, completion: nil)
                }else{
                    NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                
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
    
    func selectColor(_ color:String){
        if color == "blue" {
            updateButton(arrStackBtn[1])
        }else if color == "pink" {
            updateButton(arrStackBtn[0])
        }else if color == "green" {
            updateButton(arrStackBtn[2])
        }else if color == "orange" {
            updateButton(arrStackBtn[3])
        }else if color == "violet" {
            updateButton(arrStackBtn[4])
        }else if color == "white"{
            updateButton(arrStackBtn[5])
        }else{
            updateButton(arrStackBtn[5])
        }
    }
}
