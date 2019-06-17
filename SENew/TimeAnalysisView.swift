//
//  TimeAnalysisView.swift
//  SENew
//
//  Created by Milind Kudale on 18/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class TimeAnalysisView : SliderVC {

    @IBOutlet var lblSelectedWeeks: UILabel!
    @IBOutlet var tblView : UITableView!
    
    var dictDDDataWithIds = [String:String]()
    var ddOptions = ["Current Week", "Past 2 Weeks", "Past 3 Weeks", "Past 4 Weeks", "Current Month", "Past 2 months", "90 days"]
    
    var arrTimeAnalysisData = [AnyObject]()
    var arrEventName = [String]()
    var arrTotalTimeSpend  = [String]()
    var arrSummery = [String]()
    
    var strDurationId = ""
    var selectedRowIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.strDurationId = "1"
        self.lblSelectedWeeks.text = "Time analysis of current week";
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        dictDDDataWithIds = ["Current Week":"1",
                             "Past 2 Weeks":"4",
                             "Past 3 Weeks":"5",
                             "Past 4 Weeks":"7",
                             "Current Month":"2",
                             "Past 2 months":"6",
                             "90 days":"3"]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTADataOnLaunch(strDuration:"1")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    //get data at the time of view launching
    func getTADataOnLaunch(strDuration:String){
        let dictParam = ["user_id": userID,
                         "duration":strDuration,
                         "platform":"3"]
        getTimeAnalysisData(action: "timeAnalysis", param: dictParam as [String : AnyObject])
    }
    
    func getTimeAnalysisData(action:String, param: [String:AnyObject]){
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:param, vcObject: self){
            JsonDict, staus in
            let success = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.lblSelectedWeeks.text = "Time analysis \(JsonDict!["analysisTitle"] as? String ?? "")"
                self.selectedRowIndex = -1
                self.arrTimeAnalysisData = JsonDict!["result"] as! [AnyObject]
                self.arrEventName = self.arrTimeAnalysisData.compactMap { $0["event_name"] as? String }
                self.arrTotalTimeSpend = self.arrTimeAnalysisData.compactMap { $0["total_time_spend"] as? String }
                self.arrSummery = self.arrTimeAnalysisData.compactMap { $0["summary"] as? String }
                
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                OBJCOM.hideLoader()
            }
            self.tblView.reloadData()
        };
    }
    
    @IBAction func actionSelectWeek(_ sender:UIButton){
        
//        dictDDDataWithIds = ["Current Week":"1",
//                             "Past 2 Weeks":"4",
//                             "Past 3 Weeks":"5",
//                             "Past 4 Weeks":"7",
//                             "Current Month":"2",
//                             "Past 2 months":"6",
//                             "90 days":"3"]
        
        let arrOptionsTitle : [String] = ["Current Week", "Past 2 Weeks", "Past 3 Weeks", "Past 4 Weeks", "Current Month", "Past 2 months", "90 days"]
        let arrOptionsId : [String] = ["1", "4", "5", "7", "2", "6", "3"]
        var items = [ActionSheetItem]()
        
        for i in 0 ..< arrOptionsTitle.count {

            let item = ActionSheetItem(title: arrOptionsTitle[i], value: i)
            items.append(item)

        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                let selectedOpt = arrOptionsId[item.value as! Int]
                self.getTADataOnLaunch(strDuration:"\(selectedOpt)")
                self.dismiss(animated: true, completion: nil)
            }
        }
        sheet.present(in: self, from: self.view)
    }

}


extension TimeAnalysisView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrEventName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "Cell") as! TimeAnalysisCell
        
        cell.imgOpenCard.image = #imageLiteral(resourceName: "open")
        cell.header.backgroundColor = .white
        cell.footer.isHidden = true
        cell.lblEventName.textColor = APPBLUECOLOR
        if selectedRowIndex == indexPath.row {
            cell.imgOpenCard.image = #imageLiteral(resourceName: "minimize")
            cell.header.backgroundColor = APPBLUECOLOR
            cell.footer.isHidden = false
            cell.lblEventName.textColor = .white
        }
        cell.lblEventName.text = self.arrEventName[indexPath.row]
        cell.lblTotalTimeSpend.text = "\(self.arrTotalTimeSpend[indexPath.row])";
        cell.lblSummery.text = "\(self.arrSummery[indexPath.row])";
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedRowIndex == indexPath.row {
            selectedRowIndex = -1
        } else {
            selectedRowIndex = indexPath.row
        }
        self.tblView.beginUpdates()
        self.tblView.reloadData()
        self.tblView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex{
            return 170
        }
        return 60
    }
}


class TimeAnalysisCell: UITableViewCell {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var header : UIView!
    @IBOutlet var footer : UIView!
    
    @IBOutlet var imgOpenCard : UIImageView!
    @IBOutlet var lblEventName : UILabel!
    @IBOutlet var lblTotalTimeSpend : UILabel!
    @IBOutlet var lblSummery : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
