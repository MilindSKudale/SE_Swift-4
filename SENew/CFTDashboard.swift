//
//  CFTDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 16/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet
import VACalendar
import Charts


class CFTDashboard: SliderVC {

    //Dashboard
    @IBOutlet var topBar : SMTabbar!
    @IBOutlet var viewWeeklyScore : UIView!
    @IBOutlet var viewCalendar : UIView!
    @IBOutlet var viewWeeklyGraph : UIView!
    @IBOutlet var viewNoCftUser : UIView!
    @IBOutlet var viewNoDetails : UIView!
    
    //calender
    @IBOutlet weak var monthHeaderView: VAMonthHeaderView! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            
            let appereance = VAMonthHeaderViewAppearance(
                previousButtonImage: #imageLiteral(resourceName: "ic_left"),
                nextButtonImage: #imageLiteral(resourceName: "ic_right"),
                dateFormatter: dateFormatter
            )
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
            monthHeaderView.backgroundColor = APPBLUECOLOR
        }
    }
    
    @IBOutlet weak var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .veryShort, calendar: defaultCalendar)
            
            weekDaysView.appearance = appereance
            weekDaysView.backgroundColor = APPBLUECOLOR
            
        }
    }
    
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    
    var calendarView: VACalendarView!
    
    //weekly score
    @IBOutlet var chartView: LineChartView!
    @IBOutlet var chartView1: LineChartView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var lblTotalScore : UILabel!
    @IBOutlet var btnSelectWeek : UIButton!
    @IBOutlet  var lblSelectedWeeks: UILabel!
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
    
    var userG = "0000"
    var adminG = "0000"
    var xLabels = [String]()
    var yLabels = [CGFloat]()
    var xLabelsScore = [String]()
    var yLabelsScore = [CGFloat]()
    
    var arrGoals = [AnyObject]()
    var arrScore = [AnyObject]()
    var userGoal  : [CGFloat] = []
    var adminGoal : [CGFloat] = []
    
    // weekly graph
    @IBOutlet var graphBar : SMTabbar!
    
    var CFTUserId = ""
    var arrCftUser : [String] = []
    var arrCftUserId : [String] = []
    
    var lblReqCount : UILabel!
    var lblMsgCount : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWeeklyScore.isHidden = true
        self.viewCalendar.isHidden = true
        self.viewWeeklyGraph.isHidden = true
        self.viewNoDetails.isHidden = true
        self.chartView.isHidden = true
        self.chartView1.isHidden = true
        self.lblSelectedWeeks.text = "Current week's tracking details";
        self.setUpCalenderView()
        self.viewNoCftUser.isHidden = false
        
        self.lblReqCount = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 15))
        self.lblReqCount.text = ""
        self.lblReqCount.layer.cornerRadius = self.lblReqCount.frame.height/2
        self.lblReqCount.clipsToBounds = true
        self.lblReqCount.backgroundColor = .red
        self.lblReqCount.font = UIFont.systemFont(ofSize: 13)
        self.lblReqCount.textColor = .white
        self.lblReqCount.textAlignment = .center
        self.lblReqCount.isHidden = true
        let rightButton1 = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        rightButton1.setImage(#imageLiteral(resourceName: "Approve_access_3x"), for: [])
        rightButton1.addTarget(self, action: #selector(clickOnApproveRequest(_:)), for: .touchUpInside)
        rightButton1.addSubview(self.lblReqCount)
        
        self.lblMsgCount = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 15))
        self.lblMsgCount.text = ""
        self.lblMsgCount.layer.cornerRadius = self.lblReqCount.frame.height/2
        self.lblMsgCount.clipsToBounds = true
        self.lblMsgCount.backgroundColor = .red
        self.lblMsgCount.font = UIFont.systemFont(ofSize: 13)
        self.lblMsgCount.textColor = .white
        self.lblMsgCount.textAlignment = .center
        self.lblMsgCount.isHidden = true
        let rightButton2 = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        rightButton2.setImage(#imageLiteral(resourceName: "CFT_feedback_3x"), for: [])
        rightButton2.addTarget(self, action: #selector(clickOnFeedback(_:)), for: .touchUpInside)
        rightButton2.addSubview(self.lblMsgCount)
        
        let rightButton3 = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        rightButton3.setImage(#imageLiteral(resourceName: "more"), for: [])
        rightButton3.addTarget(self, action: #selector(clickOnMoreOption(_:)), for: .touchUpInside)
        
        // Bar button item
        let rightBarButtomItem1 = UIBarButtonItem(customView: rightButton1)
        let rightBarButtomItem2 = UIBarButtonItem(customView: rightButton2)
        let rightBarButtomItem3 = UIBarButtonItem(customView: rightButton3)
        
        navigationItem.setRightBarButtonItems([rightBarButtomItem3, rightBarButtomItem1, rightBarButtomItem2], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getUserData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        setupTabbar()
        setupWeeklyGraphTabbar()
        setUpWeeklyGoalsGraph()
        setUpWeeklyScoreGraph()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if calendarView.frame == .zero {
            calendarView.frame = CGRect(
                x: 0,
                y: weekDaysView.frame.maxY,
                width: self.viewCalendar.frame.width,
                height: 500 * 0.6
            )
            calendarView.setup()
        }
    }
    
    @objc func UpdateCftDashboard(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getUserData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        setupTabbar()
        setupWeeklyGraphTabbar()
        setUpWeeklyGoalsGraph()
        setUpWeeklyScoreGraph()
    }
    
    @IBAction func actionSelectCftUser(_ sender:AnyObject){
        if arrCftUser.count == 0 {
            return
        }
        var items = [ActionSheetItem]()
        for i in 0 ..< self.arrCftUser.count {
            let item = ActionSheetItem(title: self.arrCftUser[i], value: self.arrCftUserId[i])
            items.append(item)
        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                self.viewNoCftUser.isHidden = true
                self.CFTUserId = "\(item.value!)"
                sender.setTitle(item.title, for: .normal)
                if self.CFTUserId != "" {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getWTDataOnLaunch()
                            self.getCalenderDataFromServer()
                            self.getGraphData()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        sheet.present(in: self, from: self.view)
    }

    func setupTabbar(){
        self.viewWeeklyScore.isHidden = false
        self.viewCalendar.isHidden = true
        self.viewWeeklyGraph.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        let list : [String] = ["Weekly Score", "Calender", "Weekly Graph"]
        self.topBar.buttonWidth = self.view.frame.width/3
        self.topBar.moveDuration = 0.4
        self.topBar.fontSize = 16.0
        self.topBar.linePosition = .bottom
        self.topBar.lineWidth = self.view.frame.width/3
        self.topBar.selectTab(index: 0)
        
        self.topBar.configureSMTabbar(titleList: list) { (index) -> (Void) in
            if index == 0 {
                self.viewWeeklyScore.isHidden = false
                self.viewCalendar.isHidden = true
                self.viewWeeklyGraph.isHidden = true
            }else if index == 1 {
                self.viewWeeklyScore.isHidden = true
                self.viewCalendar.isHidden = false
                self.viewWeeklyGraph.isHidden = true
            }else if index == 2 {
                self.viewWeeklyScore.isHidden = true
                self.viewCalendar.isHidden = true
                self.viewWeeklyGraph.isHidden = false
                self.chartView.isHidden = false
                self.chartView1.isHidden = true
                self.graphBar.selectTab(index: 0)
            }
            print(index)
        }
    }
}

extension CFTDashboard {
    func getUserData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftAccessUsers", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrCftUser = []
            self.arrCftUserId = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrUserData = JsonDict!["accessUser"] as! [AnyObject]
                let srtAccessCount = "\(JsonDict!["accessCount"]!)"
                let srtMsgCount = "\(JsonDict!["messageCount"]!)"
                for i in 0..<arrUserData.count {
                    self.arrCftUser.append(arrUserData[i]["userName"] as? String ?? "")
                    self.arrCftUserId.append(arrUserData[i]["cftAccessFromUserId"] as? String ?? "")
                }
                
                if srtAccessCount != "" && srtAccessCount != "0" {
                    self.lblReqCount.isHidden = false
                    self.lblReqCount.text = srtAccessCount
                }else{
                    self.lblReqCount.isHidden = true
                    self.lblReqCount.text = srtAccessCount
                }

                if srtMsgCount != "" && srtMsgCount != "0" {
                    self.lblMsgCount.isHidden = false
                    self.lblMsgCount.text = srtMsgCount
                }else{
                    self.lblMsgCount.isHidden = true
                    self.lblMsgCount.text = srtMsgCount
                }
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
}


// Weekly score of CFT
extension CFTDashboard : UITableViewDelegate, UITableViewDataSource {
    
    //get data at the time of view launching
    func getWTDataOnLaunch(){
        let dictParam = ["user_id": CFTUserId,
                         "platform":"3"]
        getWeeklyTrackingData(action: "trackingIos", param: dictParam as [String : AnyObject])
    }
    //get data after week selection
    func getWTDataOnWeekSelection(weekID:String){
        let dictParam = ["user_id": CFTUserId,
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
                //   self.noDataView.isHidden = true
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
                    
                    self.viewNoDetails.isHidden = true
                }
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                self.tblList.reloadData()
                self.viewNoDetails.isHidden = false
                self.lblTotalScore.text = "Total score 0.00"
                OBJCOM.hideLoader()
                
            }
        };
    }
    
    @IBAction func actionSelectWeek(_ sender:UIButton){
//        let title = ActionSheetTitle(title: "Select a week")
        var items = [ActionSheetItem]()
//        items.append(title)
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
        
        if selectedRowIndex == indexPath.row {
            selectedRowIndex = -1
        } else {
            selectedRowIndex = indexPath.row
        }
        tblList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex{
            return 170
        }
        return 60
    }
    
}

// weekly graph
extension CFTDashboard : ChartViewDelegate {
    func setupWeeklyGraphTabbar(){
        self.automaticallyAdjustsScrollViewInsets = false
        let list : [String] = ["Weekly Goals", "Weekly Score"]
        self.graphBar.buttonWidth = self.view.frame.width/2
        self.graphBar.moveDuration = 0.4
        self.graphBar.fontSize = 16.0
        self.graphBar.linePosition = .bottom
        self.graphBar.lineWidth = self.view.frame.width/2
        self.graphBar.selectTab(index: 0)
        self.graphBar.configureSMTabbar(titleList: list) { (index) -> (Void) in
            if index == 0 {
                self.chartView.isHidden = false
                self.chartView1.isHidden = true
            }else if index == 1 {
                self.chartView.isHidden = true
                self.chartView1.isHidden = false
            }
            print(index)
        }
    }
    
    func setUpWeeklyGoalsGraph(){
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.rightAxis.enabled = false
        chartView.maxVisibleCount = 12
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 30)
        marker.color = APPBLUECOLOR
        chartView.marker = marker
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = .black
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .black
        leftAxis.axisMaximum = 10000
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        chartView.xAxis.gridLineDashLengths = [3, 3]
        chartView.xAxis.gridLineDashPhase = 3
        chartView.legend.form = .line
        chartView.animate(xAxisDuration: 1.0)
    }
    
    func setUpWeeklyScoreGraph(){
        chartView1.delegate = self
        chartView1.chartDescription?.enabled = false
        chartView1.dragEnabled = true
        chartView1.setScaleEnabled(true)
        chartView1.pinchZoomEnabled = true
        chartView1.rightAxis.enabled = false
        chartView1.maxVisibleCount = 12
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView1
        marker.minimumSize = CGSize(width: 80, height: 30)
        marker.color = APPBLUECOLOR
        chartView1.marker = marker
        
        let xAxis = chartView1.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = .black
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = chartView1.leftAxis
        leftAxis.labelTextColor = .black
        leftAxis.axisMaximum = 10000
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        chartView1.xAxis.gridLineDashLengths = [3, 3]
        chartView1.xAxis.gridLineDashPhase = 3
        chartView1.legend.form = .line
        chartView1.animate(xAxisDuration: 1.0)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
    
    func getGraphData(){
        let dictParam = ["user_id": self.CFTUserId,
                         "platform" : "3"]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getGraphInfo", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                
                self.arrGoals = JsonDict!["weekly_goals"] as! [AnyObject]
                self.arrScore = JsonDict!["weekly_score"] as! [AnyObject]
                
                let a = JsonDict!["user_goal_sum"] as AnyObject
                let b = JsonDict!["admin_goal_sum"] as AnyObject
                
                let val = self.arrGoals[0].allValues as! [CGFloat]
                let key = self.arrGoals[0].allKeys as! [String]
                self.userG = "\(JsonDict!["user_goal_sum"] as AnyObject)"
                self.adminG = "\(JsonDict!["admin_goal_sum"] as AnyObject)"
                
                
                self.yLabels = []
                self.userGoal = []
                self.adminGoal = []
                self.yLabelsScore = []
                
                for i in 0 ..< 12 {
                    if key.contains("\(i+1)") {
                        if let index = key.index(of: "\(i+1)") {
                            self.yLabels.append(val[index])
                        }
                    }
                    self.userGoal.append(CGFloat(a.doubleValue))
                    self.adminGoal.append(CGFloat(b.doubleValue))
                }
                
                let vals = self.arrScore[0].allValues as! [CGFloat]
                let keys = self.arrScore[0].allKeys as! [String]
                
                for i in 0 ..< 12 {
                    if keys.contains("\(i+1)") {
                        if let index = keys.index(of: "\(i+1)") {
                            self.yLabelsScore.append(vals[index])
                        }
                    }
                }
                
                self.chartView.data = nil
                self.chartView1.data = nil
                
                let yVals1 = (0 ..< self.yLabels.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(self.yLabels[i]))
                }
                
                let yVals2 = (0 ..< self.userGoal.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(self.userGoal[i]))
                }
                
                let yVals3 = (0 ..< self.adminGoal.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(self.adminGoal[i]))
                }
                let yVals4 = (0 ..< self.yLabelsScore.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(self.yLabelsScore[i]))
                }
                
                
                let set1 = LineChartDataSet(entries: yVals1, label: "My Goals")
                set1.drawIconsEnabled = false
                set1.lineDashLengths = [3, 0]
                set1.highlightLineDashLengths = [5, 2.5]
                set1.setColor(APPBLUECOLOR)
                set1.setCircleColor(APPBLUECOLOR)
                set1.lineWidth = 2
                set1.circleRadius = 5
                set1.drawCircleHoleEnabled = true
                set1.valueFont = .systemFont(ofSize: 9)
                set1.formLineDashLengths = [3, 0]
                set1.formLineWidth = 3
                set1.formSize = 15
                set1.drawFilledEnabled = false
                
                let set2 = LineChartDataSet(entries: yVals2, label: "My Actual Goals")
                set2.drawIconsEnabled = false
                set2.lineDashLengths = [3, 0]
                set2.highlightLineDashLengths = [5, 2.5]
                set2.setColor(.green)
                set2.setCircleColor(.green)
                set2.lineWidth = 2
                set2.circleRadius = 5
                set2.drawCircleHoleEnabled = true
                set2.valueFont = .systemFont(ofSize: 9)
                set2.formLineDashLengths = [3, 0]
                set2.formLineWidth = 3
                set2.formSize = 15
                set2.drawFilledEnabled = false
                
                let set3 = LineChartDataSet(entries: yVals3, label: "My Program Goals")
                set3.drawIconsEnabled = false
                set3.lineDashLengths = [3, 0]
                set3.highlightLineDashLengths = [5, 2.5]
                set3.setColor(.red)
                set3.setCircleColor(.red)
                set3.lineWidth = 2
                set3.circleRadius = 5
                set3.drawCircleHoleEnabled = true
                set3.valueFont = .systemFont(ofSize: 9)
                set3.formLineDashLengths = [3, 0]
                set3.formLineWidth = 3
                set3.formSize = 15
                set3.drawFilledEnabled = false
                
                let set4 = LineChartDataSet(entries: yVals4, label: "My Score")
                set4.drawIconsEnabled = false
                set4.lineDashLengths = [3, 0]
                set4.highlightLineDashLengths = [5, 2.5]
                set4.setColor(APPBLUECOLOR)
                set4.setCircleColor(APPBLUECOLOR)
                set4.lineWidth = 2
                set4.circleRadius = 5
                set4.drawCircleHoleEnabled = true
                set4.valueFont = .systemFont(ofSize: 9)
                set4.formLineDashLengths = [3, 0]
                set4.formLineWidth = 3
                set4.formSize = 15
                set4.drawFilledEnabled = false
                
                let data = LineChartData(dataSets: [set1, set2, set3])
                let data1 = LineChartData(dataSets: [set4, set2, set3])
                self.chartView.data = data
                self.chartView1.data = data1
                
            }
        };
    }
}


// calender
extension CFTDashboard: VAMonthHeaderViewDelegate {
    
    func setUpCalenderView(){
//        let frame = CGRect(
//            x: 0,
//            y: weekDaysView.frame.maxY,
//            width: self.viewCalendar.frame.width,
//            height: self.viewCalendar.frame.height * 0.6
//        )
        
        
        let calendar = VACalendar(calendar: defaultCalendar)
        calendarView = VACalendarView(frame: .zero, calendar: calendar)
        calendarView.showDaysOut = true
        calendarView.selectionStyle = .single
        calendarView.monthDelegate = monthHeaderView
        calendarView.dayViewAppearanceDelegate = self
        calendarView.monthViewAppearanceDelegate = self
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        
        self.viewCalendar.addSubview(calendarView)
    }
    
    func didTapNextMonth() {
        calendarView.nextMonth()
    }
    
    func didTapPreviousMonth() {
        calendarView.previousMonth()
    }
    
}

extension CFTDashboard: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
        return 10.0
    }
    
    func rightInset() -> CGFloat {
        return 10.0
    }
    
    func verticalMonthTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func verticalMonthTitleColor() -> UIColor {
        return .black
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
    
}

extension CFTDashboard: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
            return .white
        case .unavailable:
            return .lightGray
        default:
            return .black
        }
    }
    
    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return APPBLUECOLOR
        default:
            return .clear
        }
    }
    
    func shape() -> VADayShape {
        return .circle
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
    
}

extension CFTDashboard: VACalendarViewDelegate {
    
    func selectedDates(_ dates: [Date]) {
        calendarView.startDate = dates.last ?? Date()
        print(dates)
    }
    
    func getCalenderDataFromServer(){
        let dictParam = ["user_id": self.CFTUserId,
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                
                for obj in result {
                    let sdt = self.stringToDate(strDate: obj["start"] as! String)
                    let edt = self.stringToDate(strDate: obj["end"] as! String)
                    self.calendarView.setSupplementaries([
                        (sdt, [VADaySupplementary.bottomDots([APPORANGECOLOR])]),
                        (edt, [VADaySupplementary.bottomDots([APPORANGECOLOR])])
                        ])
                }
               // self.calendarView.setup()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Current time zone
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dt)
    }
    
}


extension CFTDashboard {
    @IBAction func clickOnMoreOption(_ sender: AnyObject){
        let item1 = ActionSheetItem(title: "Give Access", value: 1)
        let item2 = ActionSheetItem(title: "Top Score Recruits", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateCftDashboard),
                        name: NSNotification.Name(rawValue: "UpdateCftDashboard"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "CFT", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idGiveAccessView") as! GiveAccessView
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }else if item == item2 {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateCftDashboard),
                        name: NSNotification.Name(rawValue: "UpdateCftDashboard"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "CFT", bundle: nil)
                    let vc = storyboard.instantiateViewController (withIdentifier: "idTopScoreRecruitList") as! TopScoreRecruitList
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func clickOnApproveRequest(_ sender: AnyObject){
        
        let storyboard = UIStoryboard(name: "CFT", bundle: nil)
        let vc = storyboard.instantiateViewController (withIdentifier: "idApproveRequestView") as! ApproveRequestView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func clickOnFeedback(_ sender: AnyObject){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateCftDashboard),
            name: NSNotification.Name(rawValue: "UpdateCftDashboard"),
            object: nil)
        let storyboard = UIStoryboard(name: "CFTFeedback", bundle: nil)
        let vc = storyboard.instantiateViewController (withIdentifier: "idCFTFeedbackView") as! CFTFeedbackView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
    }
    
    
    
}
