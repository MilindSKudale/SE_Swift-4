//
//  WeeklyScoreCardView.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class WeeklyScoreCardView: UIViewController {

//    
    @IBOutlet var tblList : UITableView!
    @IBOutlet var lblTotalScore : UILabel!
    var selectedRowIndex = -1
    
    var arrScoreCardData = [AnyObject]()
    var arrGoalName = [String]()
    var arrGoalScore = [AnyObject]()
    var arrRemainingGoals = [AnyObject]()
    var arrGoalCount = [String]()
    var arrGoalDoneCount = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getChecklistDashboard()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getChecklistDashboard(){
        let dictParam = ["user_id": userID]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getWeeklyScoreDashboard", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                
                self.arrScoreCardData = JsonDict!["result"] as! [AnyObject];
                let totalScore = "\(JsonDict!["total_score"] as! NSNumber)"
                //let formatted = String(format: "%.3f", totalScore)
                self.lblTotalScore.text = "Total score is \(totalScore)"
                
                
                
                self.arrGoalName = self.arrScoreCardData.compactMap { $0["goal_name"] as? String }
                self.arrGoalScore = self.arrScoreCardData.compactMap { $0["goal_score"] } as [AnyObject]
                self.arrRemainingGoals = self.arrScoreCardData.compactMap { $0["remaining_goals"]} as [AnyObject]
                self.arrGoalCount = self.arrScoreCardData.compactMap { $0["goal_count"] as? String }//
                self.arrGoalDoneCount = self.arrScoreCardData.compactMap { $0["goal_done_count"]} as [AnyObject]
                self.tblList.reloadData()
            }else{
                self.lblTotalScore.text = "Total score is 0.00"
                
                OBJCOM.hideLoader()
                print("result:",JsonDict ?? "")
            }
        };
    }
}

extension WeeklyScoreCardView : UITableViewDelegate, UITableViewDataSource {
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
        cell.lblGoalName.text = self.arrGoalName[indexPath.row]
        cell.lblWeeklyGoals.text = "\(self.arrGoalCount[indexPath.row])";
        cell.lblCompletedGoals.text = "\(self.arrGoalDoneCount[indexPath.row])";
        cell.lblScore.text = "\(self.arrGoalScore[indexPath.row])";
        cell.lblRemainingGoals.text = "\(self.arrRemainingGoals[indexPath.row])";
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if selectedRowIndex == indexPath.row {
            selectedRowIndex = -1
        } else {
            selectedRowIndex = indexPath.row
        }
        
        self.tblList.beginUpdates()
        self.tblList.reloadData()
        self.tblList.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex{
            return 185
        }
        return 60
    }
}
