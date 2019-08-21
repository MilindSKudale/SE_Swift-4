//
//  WeeklyGoalsView.swift
//  SENew
//
//  Created by Milind Kudale on 16/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Charts


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

class WeeklyGoalsView: UIViewController, ChartViewDelegate {

    @IBOutlet var chartView: LineChartView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGraphData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
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
        let dictParam = ["user_id": userID,
                         "platform" : "3"]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getGraphInfo", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                
                arrGoals = JsonDict!["weekly_goals"] as! [AnyObject]
                arrScore = JsonDict!["weekly_score"] as! [AnyObject]
                
                let a = JsonDict!["user_goal_sum"] as AnyObject
                let b = JsonDict!["admin_goal_sum"] as AnyObject
                
                let val = arrGoals[0].allValues as! [CGFloat]
                let key = arrGoals[0].allKeys as! [String]
                userG = "\(JsonDict!["user_goal_sum"] as AnyObject)"
                adminG = "\(JsonDict!["admin_goal_sum"] as AnyObject)"
                
                
                yLabels = []
                userGoal = []
                adminGoal = []
                
                for i in 0 ..< 12 {
                    if key.contains("\(i+1)") {
                        if let index = key.index(of: "\(i+1)") {
                            yLabels.append(val[index])
                        }
                    }
                    userGoal.append(CGFloat(a.doubleValue))
                    adminGoal.append(CGFloat(b.doubleValue))
                }
                
                let vals = arrScore[0].allValues as! [CGFloat]
                let keys = arrScore[0].allKeys as! [String]
                
                for i in 0 ..< 12 {
                    if keys.contains("\(i+1)") {
                        if let index = keys.index(of: "\(i+1)") {
                            yLabelsScore.append(vals[index])
                        }
                    }
                }
                
                self.chartView.data = nil
                
                let yVals1 = (0 ..< yLabels.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(yLabels[i]))
                }
                
                let yVals2 = (0 ..< userGoal.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(userGoal[i]))
                }
                
                let yVals3 = (0 ..< adminGoal.count).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(i), y: Double(adminGoal[i]))
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
                
                let data = LineChartData(dataSets: [set1, set2, set3])
                self.chartView.data = data
                
            }
        };
    }

}
