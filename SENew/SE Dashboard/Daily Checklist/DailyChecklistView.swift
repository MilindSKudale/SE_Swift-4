//
//  DailyChecklistView.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import  Sheeeeeeeeet

class DailyChecklistView: UIViewController, UITextFieldDelegate {

    @IBOutlet var tblList : UITableView!
    @IBOutlet var btnSelectDay : UIButton!
    @IBOutlet var btnSubmitGoals : UIButton!
    @IBOutlet weak var tblListHeight: NSLayoutConstraint!
    
    var arrGoalName = [String]()
    var arrDefaultValues = [String]()
    var arrDayValues = [String]()
    var arrDateValues = [String]()
    var arrchecklistData = [AnyObject]()
    var showIconFlag = 0;
    var currentDayName = ""
    var selectedDate = ""
    var submitFlag = ""
    var dictTxtValues = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblList.tableFooterView = UIView()
        self.tblListHeight.constant = 300.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getDropDownData()
                self.getChecklistDashboard()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = IndexPath(row: textField.tag, section: 0)
        let cell = tblList.cellForRow(at: index) as! ChecklistCell
        cell.txtCompletedGoalCount.removeShadow()
        cell.txtCompletedGoalCount.textColor = .black
        let goalID = arrchecklistData[index.row]["goal_id"] as? String ?? ""
        var txtVal = cell.txtCompletedGoalCount.text!
        if txtVal == ""{
            txtVal = "0"
        }
        dictTxtValues.updateValue(txtVal, forKey: goalID)
        print(dictTxtValues)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let index = IndexPath(row: textField.tag, section: 0)
        let cell = tblList.cellForRow(at: index) as! ChecklistCell
        cell.txtCompletedGoalCount.shadow()
        cell.txtCompletedGoalCount.textColor = APPORANGECOLOR
        return true
    }
}

extension DailyChecklistView {
    @IBAction func selectDay(_ sender:UIButton){
       // let title = ActionSheetTitle(title: "Select a week day")
        var items = [ActionSheetItem]()
        //items.append(title)
        for i in 0 ..< self.arrDayValues.count {
            
            let item = ActionSheetItem(title: self.arrDayValues[i], value: i)
            items.append(item)
            
        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                self.selectedDate = self.arrDateValues[item.value as! Int]
                let dt = Date();
                print(dt)
                let dateString = self.selectedDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: dateString)
                if Date().compare(date!) == ComparisonResult.orderedAscending {
                    
                    sender.setTitle("Today (\(currDay))", for: .normal)
                    self.getChecklistDashboard()
                    OBJCOM.setAlert(_title: "", message: "Future week days not allowed to select.")
                }else if Date().compare(date!) == ComparisonResult.orderedDescending || Date().compare(date!) == ComparisonResult.orderedSame {
                    if item.title == "Today" {
                        sender.setTitle("Today (\(currDay))", for: .normal)
                        self.getChecklistDashboard()
                    }else{
                        sender.setTitle(item.title, for: .normal)
                        self.updateChecklistDashboard(date: self.selectedDate)
                    }
                    
                    if(currDay == item.title){
                        self.btnSubmitGoals.setTitle("Edit & Submit", for: .normal)
                    }else if item.title == "Today" {
                        self.btnSubmitGoals.setTitle("Submit", for: .normal)
                    }else{
                        self.btnSubmitGoals.setTitle("Edit & Submit", for: .normal)
                    }
                }
               // self.btnSelectDay.setTitle(item.title, for: .normal)
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func hideGoals(sender:UIButton){
        if sender.image(for: .normal) == #imageLiteral(resourceName: "hide_goal") {
            let strSelected = arrchecklistData[sender.tag]["goal_id"] as? String ?? ""
            
            let alertVC = PMAlertController(title: "", description: "Do you want to hide \(arrchecklistData[sender.tag]["goal_name"] as? String ?? "") goal?", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
                
            }))
            alertVC.addAction(PMAlertAction(title: "Hide Goal", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.hideGoalsAPICall(goalID: strSelected)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "This goal is from ‘Critical Success Area’ category & it’s mandatory. You can’t hide this goal.")
        }
    }
    
    @IBAction func actionShowHiddenGoals(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idShowHiddenGoalsView") as! ShowHiddenGoalsView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func SubmitGoals(_ sender:UIButton){
        if sender.titleLabel?.text == "Submit"{
            submitFlag = "submit"
        }else if sender.titleLabel?.text == "Edit & Submit"{
            submitFlag = "edit"
        }
        print(dictTxtValues)
        let set = NSSet(array: Array(dictTxtValues.values))
        if(set.count == 1) {
            let myObj = set.anyObject() as! String?
            let equalTo = "0"
            if  myObj == equalTo {
                OBJCOM.setAlert(_title: "", message: "Please fill up checklist count.")
                return
            }
        }
        
        if let _ = dictTxtValues["0"] {
            dictTxtValues.removeValue(forKey: "0")
        }
        if let _ = dictTxtValues["5"] {
            dictTxtValues.removeValue(forKey: "5")
        }
        if self.arrDayValues.count > 0 {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.SubmitCheckListData(flag:self.submitFlag, dict: self.dictTxtValues)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Your business is not started yet.")
        }
    }
    
    func GetDateFromString(DateStr: String) -> Date {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let DateArray = DateStr.components(separatedBy: "-")
        let components = NSDateComponents()
        components.year = Int(DateArray[2])!
        components.month = Int(DateArray[1])!
        components.day = Int(DateArray[0])!
        components.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = calendar?.date(from: components as DateComponents)
        
        return date!
    }
}

extension DailyChecklistView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrchecklistData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChecklistCell
        
        if self.showIconFlag == 1 {
            cell.btnHideGoals.isHidden = false;
            cell.btnHideGoals.tag = indexPath.row;
            cell.txtCompletedGoalCount.tag = indexPath.row;

            if currDay == self.currentDayName{
                let cumplusoryFlag = arrchecklistData[indexPath.row]["cumplusoryFlag"] as? String ?? "0";
                if cumplusoryFlag == "1"{
                    cell.btnHideGoals.setImage(#imageLiteral(resourceName: "hide_not"), for: .normal)
                }else{
                    cell.btnHideGoals.setImage(#imageLiteral(resourceName: "hide_goal"), for: .normal)
                }
            }else{
                cell.btnHideGoals.setImage(#imageLiteral(resourceName: "hide_not"), for: .normal)
            }
        }else{
            cell.btnHideGoals.isHidden = true;
        }
        
        let goalCount = arrchecklistData[indexPath.row]["goal_count"] as? String ?? ""
        cell.lblGoalName.text = "\(arrchecklistData[indexPath.row]["goal_name"] as? String ?? "") (\(goalCount)) ";
        cell.txtCompletedGoalCount.text = arrchecklistData[indexPath.row]["goal_done_count"] as? String ?? "";
        cell.lblTotalGoalCount.text = "\(arrchecklistData[indexPath.row]["remainingGoals"] as AnyObject)"
        cell.btnHideGoals.addTarget(self, action: #selector(hideGoals), for: .touchUpInside)
        
        let goalID = arrchecklistData[indexPath.row]["goal_id"] as? String ?? ""
        var txtVal = cell.txtCompletedGoalCount.text!
        if txtVal == ""{
            txtVal = "0"
        }
        dictTxtValues[goalID] = txtVal;
        
        return cell
    }
}

extension DailyChecklistView {
    func getDropDownData(){
        let dictParam = ["user_id": userID]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getalldates", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                let arrCurrentDay = dictJsonData.value(forKey: "currentDay") as! [String]
                self.arrDayValues = dictJsonData.value(forKey: "dayName") as! [String]
                self.arrDateValues = dictJsonData.value(forKey: "date") as! [String]
                
                for i in 0..<arrCurrentDay.count{
                    if arrCurrentDay[i] == "curr" {
                        self.btnSelectDay.setTitle("Today (\(self.arrDayValues[i]))", for: .normal)
                        
                        currDay = self.arrDayValues[i]
                        currDate = self.arrDateValues[i]

                        
                        self.btnSubmitGoals.setTitle("Submit", for: .normal)
                    }
                }
                self.arrDateValues.insert(currDate, at:0)
                self.arrDayValues.insert("Today", at:0)
                self.selectedDate = self.arrDateValues[0]
                
                   // or
                
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    
    
    func getChecklistDashboard(){
        let dictParam = ["user_id": userID]
        OBJCOM.modalAPICall(Action: "showChecklistDashboard", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let business_start = JsonDict!["business_start"] as! String
                UserDefaults.standard.set(business_start, forKey: "BUSY_START_DATE")
                self.showIconFlag = JsonDict!["showIconFlag"] as! Int
                self.currentDayName = JsonDict!["currentDayName"] as! String
                self.arrchecklistData = JsonDict!["result"] as! [AnyObject];
                self.tblListHeight.constant = CGFloat(self.arrchecklistData.count*51)
                self.tblList.reloadData()
            }else{
                OBJCOM.hideLoader()
                print("result:",JsonDict ?? "")
            }
        };
    }
    
    func updateChecklistDashboard(date:String){
        
        let dictParam = ["user_id": userID, "date":date]
        OBJCOM.modalAPICall(Action: "updateChecklistDashboard", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                self.showIconFlag = JsonDict!["showIconFlag"] as! Int
                self.arrchecklistData = JsonDict!["result"] as! [AnyObject]
                self.tblList.reloadData()
            }else{
                OBJCOM.hideLoader()
                print("result:",JsonDict ?? "")
            }
        };
    }
    
    func hideGoalsAPICall(goalID:String){
        let dictParam = ["user_id": userID,
                         "zo_goal_id":goalID]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "hideGoals", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
                self.getChecklistDashboard()
            }else{
                OBJCOM.hideLoader()
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
            }
        };
    }
    
    func SubmitCheckListData(flag:String, dict:[String:String]){
        let jsonDataStr = try? JSONSerialization.data(withJSONObject: dict, options: [])
        var strGoal = String(data: jsonDataStr!, encoding: .utf8)
        strGoal = strGoal?.replacingOccurrences(of: "{", with: "")
        strGoal = strGoal?.replacingOccurrences(of: "}", with: "")
        strGoal = strGoal?.replacingOccurrences(of: "\"", with: "")
        strGoal = strGoal?.replacingOccurrences(of: "\n", with: "")
        strGoal = strGoal?.replacingOccurrences(of: " ", with: "")
        let dictParam = ["user_id": userID,
                         "submitdate": self.selectedDate,
                         "goalstr": strGoal,
                         "flag": flag]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "submitUpdateChecklistIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
                if OBJCOM.isConnectedToNetwork(){
                    DispatchQueue.main.async {
                        //self.getDropDownData()
                        if self.btnSelectDay.titleLabel?.text == "Today (\(currDay))" {
                            self.getChecklistDashboard()
                        }else{
                            self.updateChecklistDashboard(date: self.selectedDate)
                        }
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
                OBJCOM.hideLoader()
            }
        };
    }
}


