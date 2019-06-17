//
//  CalenderDasboard.swift
//  SENew
//
//  Created by Milind Kudale on 31/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EventKit

class CalenderDasboard: SliderVC {
//
//    var arrEventTitle = [String]()
//    var arrEventStart = [String]()
//    var arrEventEnd = [String]()
//    var arrEventId = [String]()
//    var eventData = [Data]()
//    var eventDataForAdd = [String:Any]()
//    var iCalEvents = [[String:Any]]()
//
////    var createdDate : GTLRDateTime!
////    var updatedDate : GTLRDateTime!
////    var startDate : GTLRDateTime!
////    var endDate : GTLRDateTime!
////    let scopes = [kGTLRAuthScopeCalendar]
////    let service = GTLRCalendarService()
////    var addEvent = ""
////    var activeEmail = ""
//
//    @IBOutlet weak var calendarView: CalendarView!
//
    override func viewDidLoad() {

        super.viewDidLoad()
//
//        CalendarView.Style.cellShape                = .round
//        CalendarView.Style.cellColorDefault         = UIColor.clear
//        CalendarView.Style.cellColorToday           = UIColor.orange
//        CalendarView.Style.cellSelectedBorderColor  = UIColor.clear
//        CalendarView.Style.cellEventColor           = UIColor.orange
//        CalendarView.Style.headerTextColor          = UIColor.white
//        CalendarView.Style.cellTextColorDefault     = UIColor.black
//        CalendarView.Style.cellTextColorToday       = UIColor.red
//
//        CalendarView.Style.firstWeekday             = .sunday
//
//        CalendarView.Style.locale                   = Locale(identifier: "en_US")
//
//        CalendarView.Style.timeZone                 = TimeZone(abbreviation: "UTC")!
//
//        CalendarView.Style.hideCellsOutsideDateRange = false
//        CalendarView.Style.changeCellColorOutsideRange = false
//
//        calendarView.dataSource = self
//        calendarView.delegate = self
//
//        calendarView.direction = .horizontal
//        calendarView.multipleSelectionEnable = false
//        calendarView.marksWeekends = true
//
//        calendarView.backgroundColor = UIColor(red:0.31, green:0.44, blue:0.47, alpha:1.00)
    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        let today = Date()
//
//        var tomorrowComponents = DateComponents()
//        tomorrowComponents.day = 1
//
//
//        let tomorrow = self.calendarView.calendar.date(byAdding: tomorrowComponents, to: today)!
//        self.calendarView.selectDate(tomorrow)
//
//       // #if KDCALENDAR_EVENT_MANAGER_ENABLED
//        self.calendarView.loadEvents() { error in
//            if error != nil {
//                let message = "The karmadust calender could not load system events. It is possibly a problem with permissions"
//                let alert = UIAlertController(title: "Events Loading Error", message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//      //  #endif
//
//
//        self.calendarView.setDisplayDate(today)
//
//        if OBJCOM.isConnectedToNetwork(){
//            OBJCOM.setLoader()
//            self.getCalenderDataFromServer()
//        }else{
//            OBJCOM.NoInternetConnectionCall()
//        }
//    }
//
//    // MARK : KDCalendarDataSource
//
//    func startDate() -> Date {
//
//        var dateComponents = DateComponents()
//        dateComponents.month = -3
//
//        let today = Date()
//
//        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
//
//        return threeMonthsAgo
//    }
//
//    func endDate() -> Date {
//
//        var dateComponents = DateComponents()
//
//        dateComponents.year = 3
//        let today = Date()
//
//        let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
//
//        return twoYearsFromNow
//
//    }
//
//
//    // MARK : KDCalendarDelegate
//
//    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
//
//        print("Did Select: \(date) with \(events.count) events")
//        for event in events {
//            print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
//        }
//
//    }
//
//    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
//
//        //        self.datePicker.setDate(date, animated: true)
//    }
//
//
//    func calendar(_ calendar: CalendarView, didLongPressDate date : Date, withEvents events: [CalendarEvent]?) {
//
//        if let events = events {
//            for event in events {
//                print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
//            }
//        }
//    }
//
//    // MARK : Events
//
//    @IBAction func onValueChange(_ picker : UIDatePicker) {
//        self.calendarView.setDisplayDate(picker.date, animated: true)
//    }
//
//    @IBAction func goToPreviousMonth(_ sender: Any) {
//        self.calendarView.goToPreviousMonth()
//    }
//    @IBAction func goToNextMonth(_ sender: Any) {
//        self.calendarView.goToNextMonth()
//
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return false
//    }
//
//    func getCalenderDataFromServer(){
//        let dictParam = ["user_id": userID,
//                         "platform":"3"]
//
//
//        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
//            JsonDict, staus in
//            let success:String = JsonDict!["IsSuccess"] as! String
//
//            self.arrEventStart = []
//            self.arrEventEnd = []
//            self.calendarView.reloadData()
//
//            if success == "true"{
//                let result = JsonDict!["result"] as! [AnyObject]
//
//                for obj in result {
//
//                    let sdt = self.stringToDate(strDate: obj["start"] as! String)
//                    let strSD = self.dateToString(dt: sdt)
//                    self.arrEventStart.append(strSD)
//                    let edt = self.stringToDate(strDate: obj["end"] as! String)
//                    let strED = self.dateToString(dt: edt)
//                    self.arrEventEnd.append(strED)
//                    self.calendarView.addEvent("", date: sdt)
//                    self.calendarView.addEvent("", date: edt)
//
//                }
//
//
//                OBJCOM.hideLoader()
//            }else{
//                print("result:",JsonDict ?? "")
//                OBJCOM.hideLoader()
//            }
////            if OBJCOM.isConnectedToNetwork(){
////                OBJCOM.setLoader()
////                self.apiCallForCheckCalenderEmailActive()
////            }else{
////                OBJCOM.NoInternetConnectionCall()
////            }
//        };
//    }
//
//    func stringToDate(strDate:String)-> Date {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Current time zone
//        return dateFormatter.date(from: strDate)!
//    }
//
//    func dateToString(dt:Date)-> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: dt)
//    }

}
