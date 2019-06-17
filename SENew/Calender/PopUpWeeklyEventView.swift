//
//  PopUpWeeklyEventView.swift
//  SENew
//
//  Created by Milind Kudale on 18/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class PopUpWeeklyEventView: UIViewController {
   
    @IBOutlet var bgView : UIView!
    @IBOutlet var txtRepeatEveryWeek: UITextField!
    @IBOutlet var txtRepeatEndsOn: UITextField!
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnEndDate: UIButton!
    @IBOutlet var btnNever: UIButton!
    @IBOutlet var btnAfter: UIButton!
    @IBOutlet var btnEndsOn: UIButton!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var btnDaysCollection: [UIButton]!
    
    var strStartDate = ""
    var strEndDate = ""
    var endDate = Date()
    var strEventEndType = ""
    var strSelectedDays = ""
    var arrSelectedDays = [String]()
    var strRepeatBy = ""
    var strOccurance = ""
    var endsOnWeeksCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    func designUI(){
        
        print(getDayOfWeek() as Any)
        
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        
        btnSave.layer.cornerRadius = 5.0
        btnSave.clipsToBounds = true
        
        self.txtRepeatEveryWeek.text = "1"
        self.txtRepeatEndsOn.text = "\(self.endsOnWeeksCount)"
        self.btnStartDate.setTitle(self.strStartDate, for: .normal)
        self.btnEndDate.setTitle(self.strEndDate, for: .normal)
        
        let arrDays = ["SU","MO","TU","WE","TH","FR","SA"]
        for i in 0 ..< btnDaysCollection.count {
            if i == self.getDayOfWeek() - 1 {
                arrSelectedDays.append(arrDays[i])
                btnDaysCollection[i].backgroundColor = APPBLUECOLOR
                btnDaysCollection[i].setTitleColor(.white, for: .normal)
            }
        }
        
//        arrSelectedDays = ["SU","MO","TU","WE","TH","FR","SA"]
//        for obj in btnDaysCollection {
//            obj.backgroundColor = APPBLUECOLOR
//            obj.setTitleColor(.white, for: .normal)
//        }
        self.btnStartDate.isEnabled = false
        updateRadioButtons(self.btnNever)
        strEventEndType = "never"
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender: UIButton) {
        if arrSelectedDays.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select a weekday.")
            return
        }
        if strEventEndType == "after" {
            strOccurance = txtRepeatEndsOn.text!
        }
        var strEndOn = ""
        if strEventEndType == "endOn" {
            strEndOn = btnEndDate.titleLabel!.text!
        }
        strSelectedDays = self.arrSelectedDays.joined(separator: ",")
        dictForRepeate = ["repeatEvery":self.txtRepeatEveryWeek.text!,
                          "repeatBy":strRepeatBy,
                          "day":strSelectedDays,
                          "ends":strEventEndType,
                          "ondate":strEndOn,
                          "Occurences":strOccurance]
        self.dismiss(animated: true, completion: nil)
    }
}

extension PopUpWeeklyEventView {
    @IBAction func actionSetWeekDaysForRepeat(_ sender : UIButton){
        print(sender.tag)
        switch sender.tag {
        case 1:
            if self.arrSelectedDays.contains("SU") == false {
                self.arrSelectedDays.append("SU")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "SU")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 2:
            if self.arrSelectedDays.contains("MO") == false {
                self.arrSelectedDays.append("MO")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "MO")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 3:
            if self.arrSelectedDays.contains("TU") == false {
                self.arrSelectedDays.append("TU")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "TU")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 4:
            if self.arrSelectedDays.contains("WE") == false {
                self.arrSelectedDays.append("WE")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "WE")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
                
            }
            break
        case 5:
            if self.arrSelectedDays.contains("TH") == false {
                self.arrSelectedDays.append("TH")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "TH")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 6:
            if self.arrSelectedDays.contains("FR") == false {
                self.arrSelectedDays.append("FR")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "FR")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 7:
            if self.arrSelectedDays.contains("SA") == false {
                self.arrSelectedDays.append("SA")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "SA")
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
    
    @IBAction func actionNever(_ sender : UIButton){
        updateRadioButtons(sender)
        strEventEndType = "never"
    }
    
    @IBAction func actionAfter(_ sender : UIButton){
        updateRadioButtons(sender)
        strEventEndType = "after"
    }
    
    @IBAction func actionEndsOn(_ sender : UIButton){
        updateRadioButtons(sender)
        strEventEndType = "endOn"
    }
    
    func updateRadioButtons(_ sender:UIButton) {
        self.btnNever.isSelected = false
        self.btnAfter.isSelected = false
        self.btnEndsOn.isSelected = false
        sender.isSelected = true
        
        if sender == btnNever {
            txtRepeatEndsOn.isUserInteractionEnabled = false
            btnEndDate.isEnabled = false
        }else if sender == btnAfter {
            txtRepeatEndsOn.isUserInteractionEnabled = true
            btnEndDate.isEnabled = false
        }else if sender == btnEndsOn {
            btnEndDate.isEnabled = true
            txtRepeatEndsOn.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func actionIncreaseDecreaseCount(_ sender : UIButton){
        if txtRepeatEndsOn.isUserInteractionEnabled == true {
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
    
    @IBAction func actionSetEndsDate(_ sender : UIButton){
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: APPORANGECOLOR,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        datePicker.show("Set Date",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: endDate,
                        datePickerMode: .date) { (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM-dd-yyyy"
                                
                                self.btnEndDate.setTitle(formatter.string(from: dt), for: .normal)
                                
                            }
        }
    }
    
    func getDayOfWeek() -> Int {
        let weekDay = Calendar.current.component(.weekday, from: Date())
        return weekDay
    }
}

