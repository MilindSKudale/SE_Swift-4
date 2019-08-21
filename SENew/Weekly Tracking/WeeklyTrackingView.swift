//
//  WeeklyTrackingView.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class WeeklyTrackingView: SliderVC {

    @IBOutlet var tblList : UITableView!
    @IBOutlet var lblTotalScore : UILabel!
    @IBOutlet var btnSelectWeek : UIButton!
    @IBOutlet  var lblSelectedWeeks: UILabel!
    @IBOutlet  var noDataView: UIView!
    var selectedRowIndex = -1
    
    var arrGoalName = [AnyObject]()
    var arrRemainingGoals = [AnyObject]()
    var arrGoalCount = [AnyObject]()
    var arrGoalDoneCount = [AnyObject]()
    var arrRemainGoalsfor90Days = [AnyObject]()
    var arrCompleGoalsfor90Days = [AnyObject]()
    var arrDropDownData = [AnyObject]()
    var arrWeeklyTrackingData = [AnyObject]()
    
    var arrDdTitle = [String]()
    var arrWeekId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblSelectedWeeks.text = "Current week's tracking details";
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getWTDataOnLaunch()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    //get data at the time of view launching
    func getWTDataOnLaunch(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        getWeeklyTrackingData(action: "trackingIos", param: dictParam as [String : AnyObject])
    }
    //get data after week selection
    func getWTDataOnWeekSelection(weekID:String){
        let dictParam = ["user_id": userID,
                         "week_id" : weekID,
                         "platform":"3"]
        getWeeklyTrackingData(action: "indWeekDetails", param: dictParam as [String : AnyObject])
    }
    
    func getWeeklyTrackingData(action:String, param: [String:AnyObject]){
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:param, vcObject: self){
            JsonDict, staus in
            let success = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.noDataView.isHidden = true
                self.arrWeeklyTrackingData = JsonDict!["goal_details"] as! [AnyObject]
                if action == "trackingIos"{
                    self.arrDropDownData = JsonDict!["week"] as! [AnyObject]
                    if self.arrDropDownData.count > 0{
                        self.arrDdTitle = []
                        self.arrWeekId = []
                        self.arrDdTitle.append("Current week")
                        self.arrWeekId.append("0")
                        for i in 0..<self.arrDropDownData.count{
                            let a = self.arrDropDownData[i]["week_name"] ?? ""
                            let b = self.arrDropDownData[i]["week_start_date"] ?? ""
                            let c = self.arrDropDownData[i]["week_end_date"] ?? ""
                            let str = " \(a!) (\(b!) To \(c!))"
                            self.arrDdTitle.append(str)
                            self.arrWeekId.append( self.arrDropDownData[i]["week_id"] as! String)
                        }
                        print(self.arrWeekId.count)
                        print(self.arrDdTitle.count)
                        print(self.arrWeekId)
                   }
                }
                
                let tScore = JsonDict!["total_score"] as AnyObject
                self.lblTotalScore.text = "Total score \(tScore)"
                
                if self.arrWeeklyTrackingData.count > 0 {
                    self.arrGoalName = self.arrWeeklyTrackingData.compactMap { $0["goal_name"] as AnyObject }
                    self.arrRemainingGoals = self.arrWeeklyTrackingData.compactMap { $0["remaining_goals"] as AnyObject }
                    self.arrGoalCount = self.arrWeeklyTrackingData.compactMap { $0["goal_count"] as AnyObject }
                    self.arrGoalDoneCount = self.arrWeeklyTrackingData.compactMap { $0["user_done_goal_count"] as AnyObject }
                    self.arrRemainGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["remainingGoalsfor90Days"] as AnyObject }
                    self.arrCompleGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["completedGoalsfor90Days"] as AnyObject }
                    self.tblList.reloadData()
                    self.noDataView.isHidden = true
                }else{
                    self.noDataView.isHidden = false
                }
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                self.noDataView.isHidden = false
                self.lblTotalScore.text = "Total score 0.00"
                OBJCOM.hideLoader()
                
            }
        };
    }
    
    @IBAction func actionSelectWeek(_ sender:UIButton){
     //   let title = ActionSheetTitle(title: "Select a week")
        var items = [ActionSheetItem]()
    //    items.append(title)
        for i in 0 ..< self.arrDdTitle.count {
            
            let item = ActionSheetItem(title: self.arrDdTitle[i], value: i)
            items.append(item)
            
        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if self.arrWeekId[item.value as! Int] == "0" {
                    self.lblSelectedWeeks.text = "Current week's tracking details";
                    self.btnSelectWeek.setTitle("Current Week", for: .normal)
                    self.getWTDataOnLaunch()
                }else{
                    self.btnSelectWeek.setTitle(item.title, for: .normal)
                    self.lblSelectedWeeks.text = "\(self.arrDdTitle[item.value as! Int])";
                    let week_id = self.arrWeekId[item.value as! Int]
                    self.getWTDataOnWeekSelection(weekID:week_id)
                }
                self.dismiss(animated: true, completion: nil)
            }

                // self.btnSelectDay.setTitle(item.title, for: .normal)
            }
        sheet.present(in: self, from: self.view)
    }
}

extension WeeklyTrackingView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrGoalName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! WeeklyScoreCardCell
        
        cell.imgOpenCard.image = #imageLiteral(resourceName: "open")
        cell.header.backgroundColor = .white
        cell.footer.isHidden = true
        cell.lblGoalName.textColor = APPBLUECOLOR
        if selectedRowIndex == indexPath.row {
            cell.imgOpenCard.image = #imageLiteral(resourceName: "minimize")
            cell.header.backgroundColor = APPBLUECOLOR
            cell.footer.isHidden = false
            cell.lblGoalName.textColor = .white
        }
        cell.lblGoalName.text = self.arrGoalName[indexPath.row] as? String
        cell.lblWeeklyGoals.text = "\(self.arrRemainingGoals[indexPath.row])";
        cell.lblCompletedGoals.text = "\(self.arrCompleGoalsfor90Days[indexPath.row])";
        cell.lblScore.text = "\(self.arrGoalDoneCount[indexPath.row])";
        cell.lblRemainingGoals.text = "\(self.arrRemainGoalsfor90Days[indexPath.row])";
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tblList.cellForRow(at: indexPath) as! WeeklyScoreCardCell
        if selectedRowIndex == indexPath.row {
            selectedRowIndex = -1
            
        } else {
            selectedRowIndex = indexPath.row
        }
        //cell.footer.isHidden = true
        self.tblList.beginUpdates()
        self.tblList.reloadData()
        self.tblList.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex{
            return 170
        }
        return 60
    }
}
