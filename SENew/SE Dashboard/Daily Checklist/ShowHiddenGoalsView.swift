//
//  ShowHiddenGoalsView.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ShowHiddenGoalsView: UIViewController {

    @IBOutlet var tblHiddenGoals : UITableView!
    @IBOutlet var tblHeight : NSLayoutConstraint!
    @IBOutlet var btnHiddenGoals : UIButton!
    @IBOutlet var bgView : UIView!
    
    var arrHiddenGoalsTitle = [String]()
    var arrHiddenGoalsID = [String]()
    var arrSelectedGoalID = [String]()
    var goalID = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblHeight.constant = 35
        self.tblHiddenGoals.tableFooterView = UIView()
        self.tblHiddenGoals.rowHeight = UITableView.automaticDimension
        self.tblHiddenGoals.estimatedRowHeight = 35
        self.btnHiddenGoals.isHidden = true
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getHiddenGoalsData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        bgView.clipsToBounds = true
    }
    

    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getHiddenGoalsData(){
        let dictParam = ["user_id": userID]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "hideGoalsDetails", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                
                let dict = JsonDict!["result"] as! [AnyObject];
                self.arrHiddenGoalsTitle = dict.compactMap { $0["goal_name"] as? String }
                self.arrHiddenGoalsID = dict.compactMap { $0["zo_goal_id"] as? String }
                
                if dict.count > 0 && dict.count < 10 {
                    self.tblHeight.constant = CGFloat(self.arrHiddenGoalsTitle.count*40)
                } else if dict.count == 0 {
                    self.tblHeight.constant = 40
                } else {
                    self.tblHeight.constant = 280
                }
                self.btnHiddenGoals.isHidden = false
                self.tblHiddenGoals.reloadData()
            }else{
                OBJCOM.hideLoader()
                self.btnHiddenGoals.isHidden = true
                self.tblHeight.constant = 40
            }
        };
    }
    
    func showHiddenGoalsAPI(arrSelected : [String]){
        if arrSelected.count > 0 {
            let strSelected = arrSelected.joined(separator: ",")
            let dictParam = ["user_id": userID,
                             "zo_goal_id":strSelected]
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "showGoals", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    OBJCOM.hideLoader()
                    let dict = JsonDict!["result"] as! String;
                    OBJCOM.setAlert(_title: "", message: dict)
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getHiddenGoalsData()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    OBJCOM.hideLoader()
                    let dict = JsonDict!["result"] as! String;
                    OBJCOM.setAlert(_title: "", message: dict)
                }
            };
        }else{
            OBJCOM.hideLoader()
            OBJCOM.setAlert(_title: "", message: "Select atleast one goal to show on cheklist.")
        }
    }
    
    @IBAction func actionShowHiddenGoals(sender:UIButton){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.showHiddenGoalsAPI(arrSelected: self.arrSelectedGoalID)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension ShowHiddenGoalsView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrHiddenGoalsTitle.count == 0 {
            return 1
        }else {return arrHiddenGoalsTitle.count}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tblHiddenGoals.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        if arrHiddenGoalsTitle.count == 0 {
            cell?.textLabel?.text = "No Hidden Goals"
            cell?.imageView?.image = nil
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        }else{
            
            cell?.textLabel?.text = self.arrHiddenGoalsTitle[indexPath.row]
            if self.arrSelectedGoalID.contains (self.arrHiddenGoalsID[indexPath.row]){
                cell?.imageView?.image = #imageLiteral(resourceName: "check")
            }else{
                cell?.imageView?.image = #imageLiteral(resourceName: "uncheck")
            }
            cell?.textLabel?.textAlignment = .left
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        }
        
        cell?.selectionStyle = .none
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tblHiddenGoals.cellForRow(at: indexPath)
        
        if cell?.textLabel?.text != "No Hidden Goals" {
            let selected = self.arrHiddenGoalsID[indexPath.row]
            if self.arrSelectedGoalID.contains(selected){
                
                self.arrSelectedGoalID.remove(at: indexPath.row)
            }else{
                
                self.arrSelectedGoalID.append(selected)
            }
            self.tblHiddenGoals.reloadData()
            
            print(self.arrSelectedGoalID)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40;
    }
}

