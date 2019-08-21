//
//  DailyScoreGraphView.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Charts

class DailyScoreGraphView: UIViewController, ChartViewDelegate {

    @IBOutlet var chartView: LineChartView!
    var xList = [String]()
    var yLabels = [CGFloat]()
    var arrScore = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        xList = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.rightAxis.enabled = false
        chartView.maxVisibleCount = 7
        
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
        leftAxis.axisMaximum = 1000
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        chartView.xAxis.gridLineDashLengths = [3, 3]
        chartView.xAxis.gridLineDashPhase = 3
        chartView.legend.form = .line
        chartView.animate(xAxisDuration: 1.0)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getGraphData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
//    // MARK: Init Methods
//    private func initView() {
//        xList = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//
//        // 1.setting
//        self.lineChartView.setXaxisStringList(list: xList, maxDisplay: xList.count) // required
//        self.lineChartView.setYaxisStringList(maximum: 9, minimum: -1, count: 9) // required
//        self.lineChartView.setDotRadius(4.0) // optional
//        self.lineChartView.setScrollingSensitive(100) // optional
//        self.lineChartView.setYaxisUnit(titleUnit: "")
//        self.lineChartView.setXaxisStringList(list: xList, maxDisplay: 7)
//        self.lineChartView.setupChart()
//        self.lineChartView.addLine(self.arrScore as! [Int] , color: APPBLUECOLOR)
//    }
    
    func getGraphData(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getWeeklyGraph", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                let arrData = dictJsonData as! [CGFloat]
                self.yLabels = []
                for obj in arrData {
                    //let i = Double(obj)
                    self.yLabels.append(obj)
                }
                
               // self.arrScore = dictJsonData as! [Any]
                //                let arrDays = (dictJsonData.object(at: 0) as AnyObject).allKeys
                if self.yLabels.count > 0 {
                    
                    self.chartView.data = nil
                    
                    let yVals1 = (0 ..< self.yLabels.count).map { (i) -> ChartDataEntry in
                        return ChartDataEntry(x: Double(i+1), y: Double(self.yLabels[i]))
                    }

                    let set3 = LineChartDataSet(entries: yVals1, label: "Daily Goals Count")
                    set3.drawIconsEnabled = false
                    set3.lineDashLengths = [3, 0]
                    set3.highlightLineDashLengths = [5, 2.5]
                    set3.setColor(APPBLUECOLOR)
                    set3.setCircleColor(APPBLUECOLOR)
                    set3.lineWidth = 2
                    set3.circleRadius = 5
                    set3.drawCircleHoleEnabled = true
                    set3.valueFont = .systemFont(ofSize: 9)
                    set3.formLineDashLengths = [3, 0]
                    set3.formLineWidth = 3
                    set3.formSize = 15
                    set3.drawFilledEnabled = false

                    let data = LineChartData(dataSets: [set3])
                    self.chartView.data = data
                    
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
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
}
