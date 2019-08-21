//
//  TCSetTimeInterval.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class TCSetTimeInterval: UIViewController, UITextFieldDelegate {

    @IBOutlet var lblTemplateTitle : UILabel!
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnSetInterval : UIButton!
    @IBOutlet weak var btnImmediate: UIButton!
    @IBOutlet weak var btnSchedule: UIButton!
    @IBOutlet weak var btnReapeat: UIButton!
    @IBOutlet weak var btnIntervalType: UIButton!
    @IBOutlet weak var txtInterval: UITextField!
    @IBOutlet weak var txtRepeatEveryWeeks: UITextField!
    @IBOutlet weak var txtRepeatEndsOn: UITextField!
    
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var viewReapeat: UIView!
    
    var arrSelectedDays = [String]()
    @IBOutlet var btnDaysCollection: [UIButton]!
    var endsOnWeeksCount = 1
    var timeIntervalValue = ""
    var timeIntervalType = "Select"
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    var templateId = ""
    var templateTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnSetInterval.layer.cornerRadius = 5
        btnSetInterval.clipsToBounds = true
        lblTemplateTitle.text = templateTitle
        
        self.updateRadioButton(self.btnImmediate)
        viewSchedule.isHidden = true
        viewReapeat.isHidden = true
        btnIntervalType.setTitle("Select", for: .normal)
        txtRepeatEndsOn.text = "\(endsOnWeeksCount)"
        txtRepeatEndsOn.text = timeIntervalValue
        txtRepeatEveryWeeks.text = "1"
        
        txtRepeatEveryWeeks.delegate = self
        txtInterval.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTemplateDetails()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSetTimeInterval(_ sender:UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.updateTimeIntervalAPICall()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

}

extension TCSetTimeInterval {
    @IBAction func actionSetImmediate(_ sender:UIButton) {
        self.isImmediate = "1"
        self.updateRadioButton(sender)
        self.viewSchedule.isHidden = true
        self.viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.5) {
        }
    }
    @IBAction func actionSetSchedule(_ sender:UIButton) {
        self.isImmediate = "2"
        self.updateRadioButton(sender)
        self.viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.viewSchedule.isHidden = false
        }
    }
    @IBAction func actionSetRepeat(_ sender:UIButton) {
        self.isImmediate = "3"
        self.updateRadioButton(sender)
        self.viewSchedule.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.viewReapeat.isHidden = false
        }
    }
    
    func updateRadioButton(_ sender:UIButton) {
        self.btnImmediate.isSelected = false
        self.btnSchedule.isSelected = false
        self.btnReapeat.isSelected = false
        sender.isSelected = true
    }
}

extension TCSetTimeInterval {
    @IBAction func actionSelectIntervalType(_ sender:UIButton) {
        let item1 = ActionSheetItem(title: "Days", value: 1)
        let item2 = ActionSheetItem(title: "Weeks", value: 2)
        let item3 = ActionSheetItem(title: "Hours", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item3, item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                
                if item == item1 {
                    self.timeIntervalType = "days"
                }else if item == item2 {
                    self.timeIntervalType = "week"
                }else if item == item3 {
                    self.timeIntervalType = "hours"
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
}

extension TCSetTimeInterval {
    @IBAction func actionSetWeekDaysForRepeat(_ sender : UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case 1:
            if self.arrSelectedDays.contains("Sun") == false {
                self.arrSelectedDays.append("Sun")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sun")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 2:
            if self.arrSelectedDays.contains("Mon") == false {
                self.arrSelectedDays.append("Mon")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Mon")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 3:
            if self.arrSelectedDays.contains("Tue") == false {
                self.arrSelectedDays.append("Tue")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Tue")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 4:
            if self.arrSelectedDays.contains("Wed") == false {
                self.arrSelectedDays.append("Wed")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Wed")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
                
            }
            break
        case 5:
            if self.arrSelectedDays.contains("Thu") == false {
                self.arrSelectedDays.append("Thu")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Thu")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 6:
            if self.arrSelectedDays.contains("Fri") == false {
                self.arrSelectedDays.append("Fri")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Fri")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 7:
            if self.arrSelectedDays.contains("Sat") == false {
                self.arrSelectedDays.append("Sat")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sat")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        default:
            break
        }
        
        print(self.arrSelectedDays)
    }
    
    @IBAction func actionIncreaseDecreaseCount(_ sender : UIButton){
        if sender.tag == 111 {
            if endsOnWeeksCount > 1 {
                endsOnWeeksCount = endsOnWeeksCount - 1
            }
        }else if sender.tag == 222 {
            if endsOnWeeksCount < 31 {
                endsOnWeeksCount = endsOnWeeksCount + 1
            }
        }
        txtRepeatEndsOn.text = "\(endsOnWeeksCount)"
    }
}

extension TCSetTimeInterval {
    func getTemplateDetails(){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTextMessageById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]
                OBJCOM.hideLoader()
                
                
                self.timeIntervalValue = result["txtTemplateInterval"] as? String ?? "0"
                self.timeIntervalType = result["txtTemplateIntervalType"] as? String ?? "hours"
                let reminderType = result["txtTemplateRepeat"] as? String ?? "0"
                
                
                
                if reminderType == "1" {
                    self.updateRadioButton(self.btnReapeat)
                    self.isImmediate = "3"
                    self.view.layoutIfNeeded()
                    self.viewSchedule.isHidden = true
                    UIView.animate(withDuration: 0.3, animations: {
                        self.viewReapeat.isHidden = false
                        self.view.layoutIfNeeded()
                    })
                    
                    self.repeatWeeks = result["txtempRepeatWeeks"] as? String ?? "0"
                    self.repeatOn = result["txtempRepeatDays"] as? String ?? ""
                    self.repeatEnd = result["txtempRepeatEndOccurrence"] as? String ?? "0"
                    
                    self.txtRepeatEveryWeeks.text = self.repeatWeeks
                    self.txtRepeatEndsOn.text = self.repeatEnd
                    self.endsOnWeeksCount = Int(self.repeatEnd)!
                    self.txtInterval.text = ""
                    self.btnIntervalType.setTitle("Select", for: .normal)
                    self.timeIntervalValue = ""
                    self.timeIntervalType = ""
                    
                    let dayArray = self.repeatOn.components(separatedBy: ",")
                    for day in dayArray {
                        if day != "" {
                            self.arrSelectedDays.append(day)
                        }
                    }
                    
                    if self.arrSelectedDays.count > 0 {
                        for view in self.btnDaysCollection as [UIView] {
                            if let btn = view as? UIButton {
                                if self.arrSelectedDays.contains ((btn.titleLabel?.text)!){
                                    btn.backgroundColor = APPBLUECOLOR
                                    btn.setTitleColor(.white, for: .normal)
                                }else{
                                    btn.backgroundColor = .white
                                    btn.setTitleColor(.black, for: .normal)
                                }
                            }
                        }
                    }
                }else{
                    self.repeatWeeks = ""
                    self.repeatOn = ""
                    self.repeatEnd = ""
                    self.txtRepeatEveryWeeks.text = "1"
                    self.endsOnWeeksCount = 1
                    self.txtInterval.text = ""
                    self.btnIntervalType.setTitle("Select", for: .normal)
                    
                    
                    if self.timeIntervalValue == "0" {
                        self.updateRadioButton(self.btnImmediate)
                        
                        self.isImmediate = "1"
                        self.view.layoutIfNeeded()
                        self.viewReapeat.isHidden = true
                        self.viewSchedule.isHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                        })
                    }else{
                        
                        self.txtInterval.text = self.timeIntervalValue
                        self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
                        self.updateRadioButton(self.btnSchedule)
                        
                        self.isImmediate = "2"
                        self.view.layoutIfNeeded()
                        self.viewReapeat.isHidden = true
                        self.viewSchedule.isHidden = false
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                            self.viewSchedule.isHidden = false
                        })
                    }
                }
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
    
    func updateTimeIntervalAPICall(){
        
        print(timeIntervalValue)
        if self.isImmediate == "3" {
            
            self.repeatWeeks = self.txtRepeatEveryWeeks.text!
            self.repeatOn = self.arrSelectedDays.joined(separator: ",")
            self.repeatEnd = self.txtRepeatEndsOn.text!
            
            if self.repeatWeeks == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter week(s) count.")
                OBJCOM.hideLoader()
                return
            }else if self.arrSelectedDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select weekdays.")
                OBJCOM.hideLoader()
                return
            }
        }else if self.isImmediate == "2" {
            if self.btnIntervalType.titleLabel?.text == "Select" {
                OBJCOM.setAlert(_title: "", message: "Please select interval type.")
                OBJCOM.hideLoader()
                return
            }else if self.txtInterval.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please select interval count.")
                OBJCOM.hideLoader()
                return
            }
        }
        if self.isImmediate == "1" || self.isImmediate == "2" {
            self.repeatWeeks = ""
            self.repeatOn = ""
            self.repeatEnd = ""
            if self.isImmediate == "1" {
                self.timeIntervalValue = ""
                self.timeIntervalType = ""
            }else{
                self.timeIntervalValue = self.txtInterval.text!
            }
        }else{
            if self.arrSelectedDays.count > 0 {
                self.repeatOn = self.arrSelectedDays.joined(separator: ",")
            }
            self.repeatWeeks = txtRepeatEveryWeeks.text ?? "1"
            self.repeatEnd = self.txtRepeatEndsOn.text ?? "\(endsOnWeeksCount)"
        }
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":self.templateId,
                         "txtTemplateInterval":self.timeIntervalValue,
                         "txtTemplateIntervalType":self.timeIntervalType,
                         "selectType": self.isImmediate,
                         "repeat_every_weeks":self.txtRepeatEveryWeeks.text!,
                         "repeat_on":self.repeatOn,
                         "repeat_ends_after":self.repeatEnd] as [String : Any] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "setTxtCampTimeInterval", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateTCTemplateDetails"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
}
