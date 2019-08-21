//
//  SMLineChartView.swift
//  LineChartSample
//
//  Created by JaN on 2017/7/3.
//  Copyright © 2017年 givingjan. All rights reserved.
//

import UIKit

class SMLineChartView: UIView {

    // MARK: Static Variables
    private let kYaxisLabelWidth : CGFloat = 60.0
    private let kYaxisLabelHeight : CGFloat = 20.0
    private let kYaxisLabelFont = UIFont.systemFont(ofSize: 12)
    private let kYaxisLabelTextAliment : NSTextAlignment = NSTextAlignment.center
    private let kYaxisLabelTextColor : UIColor = UIColor.lightGray

    private let kXaxisLabelHeight : CGFloat = 30.0
    private let kXaxisLabelFont = UIFont.systemFont(ofSize: 12)
    private let kXaxisLabelTextAliment : NSTextAlignment = NSTextAlignment.center
    private let kXaxisLabelTextColor : UIColor = UIColor.gray
    
    private let kBackgroundGrayColor : UIColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
    
    // MARK: Member Variables
    private var m_arySources : [(UIColor,[Int])] = []
    private var m_iMaximum : Int!
    private var m_iMinimum : Int!
    private var m_yAxisUnit : String = ""
    private var m_aryYaxisString : [String] = []
    private var m_aryXaxisString : [String] = []
    private var m_iMaxDisplay : Int = 7
    private var m_iCurrentLastIndex : Int = 0
    private var m_iStartFromIndex : Int = -1
    private var m_aryXaxisLabels : [UILabel] = []
    private var m_aryYaxisLabels : [UILabel] = []
    private var m_lineWidth : CGFloat = 3.0
    private var m_dotRadius : CGFloat = 5.0
    private var m_scrollingSensitive : CGFloat = 50.0

    
    // Touch
    var m_fTouchOfX : CGFloat = 0

    // MARK: Life Cycle
    override func draw(_ rect: CGRect) {
        // draw line on background
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)

        UIColor.white.setFill()
        UIRectFill(rect)

        drawXaxisBackgroundLine()
        for line in self.m_arySources {
            drawLine(line: line.1, color: line.0)
            drawDots(line: line.1, color: line.0)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    // MARK: Touch Evnet
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            self.m_fTouchOfX = currentPoint.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let diff = fabsf(Float(self.m_fTouchOfX) - Float(currentPoint.x))
            
            if diff > Float(self.m_scrollingSensitive) {
                // right to left
                if self.m_fTouchOfX > currentPoint.x && self.m_iCurrentLastIndex < self.m_aryXaxisString.count - 1{
                    self.m_iCurrentLastIndex += 1
                }
                // left to right
                else if self.m_fTouchOfX < currentPoint.x && self.m_iCurrentLastIndex > self.m_iMaxDisplay - 1{
                    self.m_iCurrentLastIndex -= 1
                }
                
                self.updateDraw()
                self.m_fTouchOfX = currentPoint.x
                
            }
            // right
            else if self.m_fTouchOfX - currentPoint.x > 50 {
                self.m_fTouchOfX = currentPoint.x
            }
            
            
        }
    }
    
    // MARK: Draw 
    
    // Draw background line
    private func drawXaxisBackgroundLine() {
        let path = UIBezierPath()
        let height = self.frame.height - kXaxisLabelHeight - kYaxisLabelHeight/2
        let gap : Int = Int(height) / (self.m_aryYaxisString.count-1)
//        let xAxisLabelWidth : CGFloat = (self.frame.size.width - kYaxisLabelWidth) / CGFloat(self.m_iMaxDisplay)
        
        kBackgroundGrayColor.setStroke()
        
        for index in 0..<self.m_aryYaxisString.count {
            let y : CGFloat = height - (CGFloat(index) * CGFloat(gap)) + kYaxisLabelHeight/2
            let from = CGPoint(x: kYaxisLabelWidth, y: y)
            let to = CGPoint(x: self.frame.size.width, y: y)
            
            path.move(to: from)
            path.addLine(to: to)
            path.stroke()
        }
    }

    // Draw Line
    private func drawLine(line : [Int], color : UIColor) {
        let path = UIBezierPath()
        let fromIndex = self.m_iCurrentLastIndex - self.m_iMaxDisplay + 1
        let xAxisLabelWidth : CGFloat = (self.frame.size.width - kYaxisLabelWidth) / CGFloat(self.m_iMaxDisplay)
        let yAxisList : [CGFloat] = self.getYaxisList(line)
        
        path.lineWidth = self.m_lineWidth
        color.setStroke()
        
        if fromIndex == 0 {
            path.move(to: CGPoint(x: kYaxisLabelWidth + (xAxisLabelWidth/2), y: yAxisList[0]))
        } else {
            if fromIndex-1 < line.count-1 {
                path.move(to: CGPoint(x: kYaxisLabelWidth, y: yAxisList[fromIndex-1]))
            }
        }
            
        for (index,y) in yAxisList.enumerated() {
            if index >= fromIndex {
                let point = CGPoint(x: (xAxisLabelWidth * CGFloat(index - fromIndex)) + kYaxisLabelWidth + (xAxisLabelWidth/2), y: y)
                path.addLine(to: point)
            }
        }
        
        path.stroke()
    }

    // Draw Dots
    private func drawDots(line : [Int], color : UIColor) {
        let path = UIBezierPath()
       
        let fromIndex = self.m_iCurrentLastIndex - self.m_iMaxDisplay + 1
        let xAxisLabelWidth : CGFloat = (self.frame.size.width - kYaxisLabelWidth) / CGFloat(self.m_iMaxDisplay)
        
        color.setFill()
        
        let yAxisList : [CGFloat] = self.getYaxisList(line)
            
        for (index,y) in yAxisList.enumerated() {
            if index >= fromIndex {
                let point = CGPoint(x: (xAxisLabelWidth * CGFloat(index - fromIndex)) + kYaxisLabelWidth + (xAxisLabelWidth/2), y: y)
                path.addArc(withCenter: point, radius: self.m_dotRadius, startAngle: 0.0, endAngle: CGFloat(Double.pi*2), clockwise: true)
                path.move(to: CGPoint(x: kYaxisLabelWidth + (xAxisLabelWidth * CGFloat(index-fromIndex) + (kYaxisLabelWidth/2)), y: y))
            }
        }
        
        path.fill()
    }
    
    private func updateDraw() {
        let fromIndex = self.m_iCurrentLastIndex - self.m_iMaxDisplay + 1
        
        for (index,xLabel) in self.m_aryXaxisLabels.enumerated() {
            xLabel.text = self.m_aryXaxisString[fromIndex + index]
        }
        
        self.setNeedsDisplay()
    }

    // MARK: Logic Methods
    
    // Get the y Position from value
    private func getYaxisList(_ sources : [Int]) -> [CGFloat] {
        var yAxisList : [CGFloat] = []
        let height = self.frame.height - kXaxisLabelHeight - kYaxisLabelHeight/2
        let value = height / CGFloat(self.m_iMaximum - self.m_iMinimum)
        
        for number in sources {
            if number - self.m_iMinimum < 0 {
                print("\(number) is less than the minimum Number ")
            }
            
            let y : CGFloat = height - CGFloat(number - self.m_iMinimum) * CGFloat(value) + kYaxisLabelHeight/2

            yAxisList.append(y)
        }
        
        return yAxisList
    }
    // MARK: Public Methods
    
    // should setupChart after finish all setting.
    func setupChart() {
        self.backgroundColor = UIColor.white
        
        self.m_aryXaxisLabels.removeAll()
        self.m_aryYaxisLabels.removeAll()
        
        // yAxis.
        let height = self.frame.height - kXaxisLabelHeight - kYaxisLabelHeight/2
        let gap : Int = Int(height) / (self.m_aryYaxisString.count-1)

        for (index,text) in self.m_aryYaxisString.enumerated() {
            let yLabel : UILabel = UILabel(frame: CGRect(x: 0, y: height - (CGFloat(index) * CGFloat(gap)) , width: kYaxisLabelWidth, height: kYaxisLabelHeight))
            yLabel.textAlignment = kYaxisLabelTextAliment
            yLabel.textColor = kYaxisLabelTextColor
            yLabel.font = kYaxisLabelFont

            yLabel.text = "\(text)\(self.m_yAxisUnit)"

            self.addSubview(yLabel)
            self.m_aryYaxisLabels.append(yLabel)
        }
        
        //xAxis.
        let xAxisLabelWidth : CGFloat = (self.frame.size.width - kYaxisLabelWidth) / CGFloat(self.m_iMaxDisplay)
        
        for (index,text) in self.m_aryXaxisString.enumerated() {
            if index < self.m_iMaxDisplay {
                print("index :\(index),\(text)")
                let xLabel : UILabel = UILabel(frame: CGRect(x: (CGFloat(index) * xAxisLabelWidth) + kYaxisLabelWidth, y: self.frame.size.height - kXaxisLabelHeight, width: xAxisLabelWidth, height: kXaxisLabelHeight))
                xLabel.textAlignment = kXaxisLabelTextAliment
                xLabel.textColor = kXaxisLabelTextColor
                xLabel.font = kXaxisLabelFont
                
                xLabel.text = text
                
                self.addSubview(xLabel)
                self.m_aryXaxisLabels.append(xLabel)
            }
        }
        
        if self.m_iMaxDisplay >= self.m_aryXaxisString.count {
            self.m_iCurrentLastIndex = self.m_iMaxDisplay-1
        }
        else if self.m_iStartFromIndex != -1 {
            self.m_iCurrentLastIndex = self.m_iStartFromIndex + self.m_iMaxDisplay - 1 > self.m_aryXaxisString.count-1 ? self.m_aryXaxisString.count-1 : self.m_iStartFromIndex + self.m_iMaxDisplay - 1
        }
        else {
            self.m_iCurrentLastIndex = self.m_aryXaxisString.count-1
        }
        
        self.updateDraw()
    }
    
    func setLineWidth(_ width : CGFloat) {
        self.m_lineWidth = width
    }
    
    func setDotRadius(_ radius : CGFloat) {
        self.m_dotRadius = radius
    }
    
    func setXaxisStringList(list : [String], maxDisplay : Int) {
        self.m_aryXaxisString = list
        self.m_iMaxDisplay = maxDisplay
    }
    
    func setYaxisStringList(maximum : Int, minimum : Int, count : Int) {
        self.m_aryYaxisString.append("\(minimum)")
        self.m_iMaximum = maximum
        self.m_iMinimum = minimum
        
        let gap : Int = (maximum - minimum)/(count-1)
        
        if count > 2 {
            for i in 1..<count-1 {
                self.m_aryYaxisString.append("\((gap * i) + self.m_iMinimum)")
                print("\(gap * i)")
            }
        }
        
        self.m_aryYaxisString.append("\(maximum)")
    }
    
    func setScrollingSensitive(_ value : CGFloat) {
        let sensitive = ((value > 100) || (value < 30)) ? 60 : value
        
        self.m_scrollingSensitive = 120 - sensitive
    }

    func setStartFromIndex(_ index : Int) {
        self.m_iStartFromIndex = index
    }
    
    func setYaxisUnit(titleUnit : String) {
        self.m_yAxisUnit = titleUnit
    }
    
    func addLine(_ sources : [Int], color : UIColor) {
        self.m_arySources.append((color,sources))
        self.updateDraw()
    }
}
