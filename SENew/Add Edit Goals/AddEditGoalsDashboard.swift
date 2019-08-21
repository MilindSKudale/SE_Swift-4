//
//  AddEditGoalsDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

var strCSA = ""
var strCA = ""
var strBLA = ""

class AddEditGoalsDashboard: SliderVC, UITextFieldDelegate{
    
    @IBOutlet var btnSelectDate : UIButton!
    @IBOutlet var lblLast90dayPlanDate : UILabel!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var topBar : SMTabbar!
    @IBOutlet var btnPrev : UIButton!
    @IBOutlet var btnNext : UIButton!
    @IBOutlet var btnSubmit : UIButton!
    
    var dictCSA = [String:String]()
    var dictCA = [String:String]()
    var dictBLA = [String:String]()
    
    var showFlag = "1"
    
    var mainTitle = [String]()
    var mainRecGoals = [String]()
    var mainPersonalGoals = [String]()
    var mainGoalId = [String]()
    var mainToolTip = [String]()
    
    var CSATitle = [String]()
    var CSARecGoals = [String]()
    var CSAPersonalGoals = [String]()
    var CSAGoalId = [String]()
    var CSAToolTip = [String]()
    
    var CATitle = [String]()
    var CARecGoals = [String]()
    var CAPersonalGoals = [String]()
    var CAGoalId = [String]()
    var CAToolTip = [String]()
    
    var BLATitle = [String]()
    var BLARecGoals = [String]()
    var BLAPersonalGoals = [String]()
    var BLAGoalId = [String]()
    var BLAToolTip = [String]()
    var flag1 = true
    var updateStrDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        let list : [String] = ["Critical Success Area","Core Activity","Baseline Activity"]
        self.topBar.buttonWidth = 190
        self.topBar.moveDuration = 0.4
        self.topBar.fontSize = 16.0
        self.topBar.linePosition = .bottom
        self.topBar.lineWidth = 160
        //self.topBar.selectTab(index: 0)
        self.topBar.configureSMTabbar(titleList: list) { (index) -> (Void) in
            if index == 0 {
                self.selectCriticalSuccessArea()
            }else if index == 1 {
                self.selectCoreActivity()
            }else if index == 2 {
                self.selectBaselineActivity()
            }
            print(index)
        }
        
        btnNext.clipsToBounds = true
        btnPrev.clipsToBounds = true
        btnSubmit.clipsToBounds = true
        btnSelectDate.setTitle("Please select", for: .normal)
        updateStrDate = ""
        tblList.tableFooterView = UIView()
        
        if UserDefaults.standard.value(forKey: "BUSY_START_DATE") != nil {
            let last90dayPlanDate = UserDefaults.standard.value(forKey: "BUSY_START_DATE") as? String ?? ""
            self.lblLast90dayPlanDate.text = "Last 90 days plan date \(last90dayPlanDate)"
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            lblLast90dayPlanDate.text = formatter.string(from: Date())
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCriticalSuccess()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension AddEditGoalsDashboard {
    @IBAction func actionSelect90daysPlanDate(_ sender:UIButton){
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.btnSelectDate.setTitle(formatter.string(from: dt), for: .normal)
                self.updateStrDate = formatter.string(from: dt)
            }
        }
    }
    
    @IBAction func actionPrev(_ sender:UIButton){
        if self.showFlag == "2" {
            self.topBar.selectTab(index: 0)
            selectCriticalSuccessArea()
        }else if self.showFlag == "3" {
            self.topBar.selectTab(index: 1)
            selectCoreActivity()
        }
    }
    
    @IBAction func actionNext(_ sender:UIButton){
        if self.showFlag == "1" {
            
            if self.dictCSAIsEmpty(dict: dictCSA) == true {
                self.topBar.selectTab(index: 1)
                selectCoreActivity()
            }else{
                OBJCOM.setAlert(_title: "", message: "Empty space or 0 is not allow in Critical success area's personal goals. Please enter valid value in personal goals.")
            }
        }else if self.showFlag == "2" {
            self.topBar.selectTab(index: 2)
            selectBaselineActivity()
        }
    }
    
    @IBAction func actionSubmitGoals(_ sender:UIButton){
        if updateStrDate == "" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSubmitGoals(strDate: self.lblLast90dayPlanDate.text!)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            let alertVC = PMAlertController(title: "", description: "You are about to change your Business Start Date & all Program Goals details. Your all current & previous working details will be get vanished. Are you sure?", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Deny", style: .cancel, action: { () in }))
            
            alertVC.addAction(PMAlertAction(title: "Allow", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.apiCallForSubmitGoals(strDate: self.updateStrDate)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = IndexPath(row: textField.tag, section: 0)
        let cell = tblList.cellForRow(at: index) as! AddEditGoalCell
        cell.txtGoalCount.removeShadow()
        cell.txtGoalCount.textColor = .black
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let index = IndexPath(row: textField.tag, section: 0)
        let cell = tblList.cellForRow(at: index) as! AddEditGoalCell
        cell.txtGoalCount.shadow()
        cell.txtGoalCount.textColor = APPORANGECOLOR
        return true
    }
}

extension AddEditGoalsDashboard {
    func selectCriticalSuccessArea(){
        btnPrev.isHidden = true
        btnNext.isHidden = false
        btnSubmit.isHidden = true
        
        self.showFlag = "1"
        
       
        
        self.mainTitle = self.CSATitle
        self.mainRecGoals = self.CSARecGoals
        self.mainPersonalGoals = self.CSAPersonalGoals
        self.mainGoalId = self.CSAGoalId
        self.mainToolTip = self.CSAToolTip
        
        
        self.tblList.reloadData()
    }
    
    func selectCoreActivity(){
        btnPrev.isHidden = false
        btnNext.isHidden = false
        btnSubmit.isHidden = true
        
        
      //  self.topBar.selectTab(index: 1)
        self.showFlag = "2"
        
        self.mainTitle = self.CATitle
        self.mainRecGoals = self.CARecGoals
        self.mainPersonalGoals = self.CAPersonalGoals
        self.mainGoalId = self.CAGoalId
        self.mainToolTip = self.CAToolTip
        
        self.tblList.reloadData()
    }
    
    func selectBaselineActivity(){
        
        btnPrev.isHidden = false
        btnNext.isHidden = true
        btnSubmit.isHidden = false
        
        self.showFlag = "3"
     //   self.topBar.selectTab(index: 2)
        
        self.mainTitle = self.BLATitle
        self.mainRecGoals = self.BLARecGoals
        self.mainPersonalGoals = self.BLAPersonalGoals
        self.mainGoalId = self.BLAGoalId
        self.mainToolTip = self.BLAToolTip
        
        self.tblList.reloadData()
    }
    
    
}


extension AddEditGoalsDashboard : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! AddEditGoalCell
        cell.lblGoalName.text = self.mainTitle[indexPath.row]
        cell.lblGoalCount.text = self.mainRecGoals[indexPath.row]
        if self.showFlag == "1"{
            cell.txtGoalCount.text = dictCSA[self.CSAGoalId[indexPath.row]]
        }else if self.showFlag == "2"{
            cell.txtGoalCount.text = dictCA[self.CAGoalId[indexPath.row]]
        }else if self.showFlag == "3"{
            cell.txtGoalCount.text = dictBLA[self.BLAGoalId[indexPath.row]]
        }
        cell.txtGoalCount.tag = indexPath.row
        cell.txtGoalCount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if self.showFlag == "1"{
            // if textField.text = "" {
            dictCSA[self.CSAGoalId[textField.tag]] = textField.text!
            // }
            
            print(dictCSA)
        }else if self.showFlag == "2"{
            //  if textField.text != "" {
            dictCA[self.CAGoalId[textField.tag]] = textField.text!
            //  }
            
            print(dictCA)
        }else if self.showFlag == "3"{
            //  if textField.text != "" {
            dictBLA[self.BLAGoalId[textField.tag]] = textField.text!
            // }
            
            print(dictBLA)
        }
    }
}

extension AddEditGoalsDashboard {
    func apiCallForCriticalSuccess(){
        let dictParam = ["user_id": userID]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllGoalDetails", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.CSATitle = []; self.CSARecGoals = []; self.CSAPersonalGoals = []; self.CSAGoalId = []; self.CATitle = []; self.CARecGoals = []; self.CAPersonalGoals = []; self.CAGoalId = []; self.BLATitle = []; self.BLARecGoals = []; self.BLAPersonalGoals = []; self.BLAGoalId = []; self.CSAToolTip = []; self.CAToolTip = []; self.BLAToolTip = []
                
                self.dictCSA = [:]
                self.dictCA = [:]
                self.dictBLA = [:]
                
//                let last90daysPlanDate = JsonDict!["usPacificeDate"] as? String ?? ""
//                self.lblLast90dayPlanDate.text = "Last 90 days plan date \(last90daysPlanDate)"
                for obj in result {
                    if obj["goal_type_id"] as! String == "1"{
                        self.CSATitle.append(obj["goal_name"] as! String)
                        self.CSARecGoals.append(obj["goal_count_admin"] as! String)
                        self.CSAPersonalGoals.append(obj["goal_count_user"] as! String)
                        self.CSAGoalId.append(obj["zo_goal_id"] as! String)
                        self.CSAToolTip.append(obj["help_tip"] as! String)
                        
                        self.dictCSA[obj["zo_goal_id"] as! String] = obj["goal_count_user"] as? String
                        
                    }else if obj["goal_type_id"] as! String == "2"{
                        self.CATitle.append(obj["goal_name"] as! String)
                        self.CARecGoals.append(obj["goal_count_admin"] as! String)
                        self.CAPersonalGoals.append(obj["goal_count_user"] as! String)
                        self.CAGoalId.append(obj["zo_goal_id"] as! String)
                        self.CAToolTip.append(obj["help_tip"] as! String)
                        self.dictCA[obj["zo_goal_id"] as! String] = obj["goal_count_user"] as? String
                    }else if obj["goal_type_id"] as! String == "3"{
                        self.BLATitle.append(obj["goal_name"] as! String)
                        self.BLARecGoals.append(obj["goal_count_admin"] as! String)
                        self.BLAPersonalGoals.append(obj["goal_count_user"] as! String)
                        self.BLAGoalId.append(obj["zo_goal_id"] as! String)
                        self.BLAToolTip.append(obj["help_tip"] as! String)
                        self.dictBLA[obj["zo_goal_id"] as! String] = obj["goal_count_user"] as? String
                    }
                }
                strCSA = self.dictToJSONString(self.dictCSA)
                strCA = self.dictToJSONString(self.dictCA)
                strBLA = self.dictToJSONString(self.dictBLA)
                OBJCOM.hideLoader()
                self.selectCriticalSuccessArea()
                self.topBar.selectTab(index: 0)
            }else{
                
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForSubmitGoals(strDate:String){
        
        strCSA = dictToJSONString(dictCSA)
        strCA = dictToJSONString(dictCA)
        strBLA = dictToJSONString(dictBLA)
        
        
        
//        if isOnboarding == false {
//            let dictParam = ["user_id": userID,
//                             "start_date": strDate,
//                             "firstGoalDetails": strCSA,
//                             "secondGoalDetails": strCA,
//                             "thirdGoalDetails": strBLA]
//
//            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
//            let jsonString = String(data: jsonData!, encoding: .utf8)
//            let dictParamTemp = ["param":jsonString];
//            self.setBuinessDateAndGoals(dictParamTemp: dictParamTemp as! [String:String])
//        }else{
            let dictParam = ["user_id": userID,
                             "start_date": updateStrDate,
                             "firstGoalDetails": strCSA,
                             "secondGoalDetails": strCA,
                             "thirdGoalDetails": strBLA]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            self.updateBuinessDateAndGoals(dictParamTemp: dictParamTemp as! [String:String])
//        }
        
    }
    
    func setBuinessDateAndGoals(dictParamTemp : [String:Any]){
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "setBuinessDateAndGoalsIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                
//                if self.flag1 == true {
//                    self.flag1 = false
//                    isOnboarding = true
//                    let appDelegate = AppDelegate.shared
//                    appDelegate.setRootVC()
//                }
                OBJCOM.hideLoader()
            }else{
                
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateBuinessDateAndGoals(dictParamTemp : [String:Any]){
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateBuinessDateAndGoalsIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                if self.updateStrDate != "" {
                    UserDefaults.standard.set(self.updateStrDate, forKey: "BUSY_START_DATE")
                }
                
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.apiCallForCriticalSuccess()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                OBJCOM.hideLoader()
            }else{
                
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func dictToJSONString(_ dict : [String:String]) -> String{
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: dict,
            options: .prettyPrinted
            ),
            var jsonStr = String(data: theJSONData,
                                 encoding: String.Encoding.ascii) {
            print("JSON string = \n\(jsonStr)")
            jsonStr = jsonStr.replacingOccurrences(of: "{", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "}", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "\n", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: " ", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "\"", with: "")
            print("JSON string = \n\(jsonStr)")
            return jsonStr
        }
        return ""
    }
    
//    @objc func makeToast(_ sender:UIButton){
//        if self.mainToolTip[sender.tag] != "" {
//            OBJCOM.popUp(context: self, msg: self.mainToolTip[sender.tag])
//        }
//    }
    
    func dictCSAIsEmpty(dict:[String:String]) -> Bool{
        if dict.values.contains(""){
            return false
        }else if dict.values.contains("0"){
            return false
        }else{
            return true
        }
        
    }
}
