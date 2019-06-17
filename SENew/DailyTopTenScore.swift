//
//  DailyTopTenScore.swift
//  SENew
//
//  Created by Milind Kudale on 19/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class DailyTopTenScore: SliderVC {

    @IBOutlet var tblList : UITableView!
    @IBOutlet var lblTitle : UILabel!
    
    var arrScoreData = [AnyObject]()
    var arrFirstName = [String]()
    var arrScore = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblList.tableFooterView = UIView()
        
        let yesterday = Date().yesterday
        let format = DateFormatter()
        format.dateFormat = "MMM-dd-yyyy"
        let strYesterday = format.string(from: yesterday)
        self.lblTitle.text = "Daily Top 10 Score - \(strYesterday)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDailyScoreData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionHelpTip(_ sender:AnyObject) {
        OBJCOM.popUp(context: self, msg: "Note : Score is calculated on the basis of mandatory critical activities. Exclusion for target, points and personal notes.")
    }

    @IBAction func actionMoreOptions(_ sender:AnyObject) {
        let item1 = ActionSheetItem(title: "Weekly Archive", value: 1)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    let storyboard = UIStoryboard(name: "TopTenScore", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idWeeklyArchieveView") as! WeeklyArchieveView
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
}

extension DailyTopTenScore : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrFirstName.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopScoreCell
        
        cell.lblName.text = self.arrFirstName[indexPath.row]
        cell.lblScore.text = "Score : \(self.arrScore[indexPath.row])"
        cell.configure(name: cell.lblName.text!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension DailyTopTenScore {
    func getDailyScoreData(){
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "type":"today",
                         "scoreDate":""]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "dailyTopTenScore", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                self.arrFirstName = []
                self.arrScore = []
                
                self.arrScoreData = JsonDict!["result"] as! [AnyObject]
                
                if self.arrScoreData.count > 0 {
                    self.arrFirstName = self.arrScoreData.compactMap { $0["recruitUserName"] as? String }
                    self.arrScore = self.arrScoreData.compactMap { $0["recruitUserScoreValue"] as? String }
                }
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        }
    }
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}




class TopTenScoreCell: UITableViewCell {
    
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblScore : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.layer.cornerRadius = imgView.frame.size.height/2
        imgView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(name: String) {
        lblName?.text = name
        imgView?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView?.image = nil
        lblName?.text = nil
    }
}
