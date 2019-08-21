//
//  PopUpFor90days.swift
//  SENew
//
//  Created by Milind Kudale on 18/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class PopUpFor90days: UIViewController {

    @IBOutlet var bgView : UIView!
    @IBOutlet var txtRepeatEveryWeek: UITextField!
    @IBOutlet var txtRepeatEndsOn: UITextField!
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnEndDate: UIButton!
    @IBOutlet var btnNever: UIButton!
    @IBOutlet var btnAfter: UIButton!
    @IBOutlet var btnEndsOn: UIButton!
    @IBOutlet var btnSave: UIButton!
    
    var strStartDate = ""
    var strEndDate = ""
    var strEventEndType = ""
    var strRepeatBy = ""
    var strOccurance = ""
    var endDate = Date()
    var endsOnWeeksCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        btnSave.layer.cornerRadius = 5.0
        btnSave.clipsToBounds = true
         designUI()
    }
    
    func designUI(){
        
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        btnSave.layer.cornerRadius = 5.0
        btnSave.clipsToBounds = true
        
        self.txtRepeatEveryWeek.text = "1"
        self.txtRepeatEndsOn.text = "\(self.endsOnWeeksCount)"
        self.btnStartDate.setTitle(self.strStartDate, for: .normal)
        self.btnEndDate.setTitle(self.strEndDate, for: .normal)
        self.btnStartDate.isEnabled = false
        updateRadioButtons(self.btnNever)
        strEventEndType = "never"
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender: UIButton) {
        
        if strEventEndType == "after" {
            strOccurance = txtRepeatEndsOn.text!
        }
        var strEndOn = ""
        if strEventEndType == "endOn" {
            strEndOn = btnEndDate.titleLabel!.text!
        }
        
        dictForRepeate = ["repeatEvery":self.txtRepeatEveryWeek.text!,
                          "repeatBy":strRepeatBy,
                          "day":"",
                          "ends":strEventEndType,
                          "ondate":strEndOn,
                          "Occurences":strOccurance]
        self.dismiss(animated: true, completion: nil)
    }
}

extension PopUpFor90days {
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
}
