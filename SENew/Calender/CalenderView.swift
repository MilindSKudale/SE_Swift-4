//
//  CalenderView.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import VACalendar
import JJFloatingActionButton
import GoogleAPIClientForREST
import GoogleSignIn
import EventKit
import AMGCalendarManager
import Sheeeeeeeeet

var googleSyncFlag = ""
var googleSync = ""

class CalenderView: SliderVC, CalendarViewDataSource, CalendarViewDelegate {

    @IBOutlet weak var calendarView: CalendarView!
    
    var arrEventTitle = [String]()
    var arrEventStart = [String]()
    var arrEventEnd = [String]()
    var arrEventId = [String]()
    var eventData = [Data]()
    var eventDataForAdd = [String:Any]()
    var iCalEvents = [[String:Any]]()
    
    
    var createdDate : GTLRDateTime!
    var updatedDate : GTLRDateTime!
    var startDate : GTLRDateTime!
    var endDate : GTLRDateTime!
    let scopes = [kGTLRAuthScopeCalendar]
    let service = GTLRCalendarService()
    var addEvent = ""
    var activeEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalenderView()
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "add_contact")) { item in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateCalender),
                name: NSNotification.Name(rawValue: "UpdateCalender"),
                object: nil)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.CreateGoogleEvent),
                name: NSNotification.Name(rawValue: "CreateGoogleEvent"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "Calender", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddEvent") as! AddEvent
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
        }
        
        actionButton.display(inViewController: self)
        DispatchQueue.main.async {
            self.apiCallForCheckCalenderEmailActive()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let today = Date()
        self.calendarView.setDisplayDate(today)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCalenderDataFromServer()
            
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if calendarView.frame == .zero {
//            calendarView.frame = CGRect(
//                x: 0,
//                y: weekDaysView.frame.maxY,
//                width: self.view.frame.width,
//                height: self.view.frame.height * 0.6
//            )
//            calendarView.setup()
//        }
//    }
    
    @objc func UpdateCalender(notification: NSNotification){
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCalenderDataFromServer()
            
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}


extension CalenderView {
    
    func setUpCalenderView(){
       
//        let calendar = VACalendar(calendar: defaultCalendar)
//        calendarView = VACalendarView(frame: .zero, calendar: calendar)
//        calendarView.showDaysOut = false
//        calendarView.selectionStyle = .single
//        calendarView.monthDelegate = monthHeaderView
//        calendarView.dayViewAppearanceDelegate = self
//        calendarView.monthViewAppearanceDelegate = self
//        calendarView.calendarDelegate = self
//        calendarView.scrollDirection = .horizontal
//
//        self.view.addSubview(calendarView)
        
        CalendarView.Style.cellShape                = .round
        CalendarView.Style.cellColorDefault         = UIColor.clear
        CalendarView.Style.cellColorToday           = UIColor.orange
        CalendarView.Style.cellSelectedBorderColor  = UIColor.clear
        CalendarView.Style.cellEventColor           = UIColor.orange
        CalendarView.Style.headerTextColor          = UIColor.white
        CalendarView.Style.cellTextColorDefault     = UIColor.black
        CalendarView.Style.cellTextColorToday       = UIColor.red
        CalendarView.Style.firstWeekday             = .sunday
        CalendarView.Style.locale                   = Locale(identifier: "en_US")
        
        CalendarView.Style.timeZone                 = TimeZone(abbreviation: "UTC")!
        
        CalendarView.Style.hideCellsOutsideDateRange = false
        CalendarView.Style.changeCellColorOutsideRange = false
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = false
        calendarView.marksWeekends = true
        
        calendarView.backgroundColor = APPBLUECOLOR
    }
    
//    func didTapNextMonth() {
//        calendarView.nextMonth()
//    }
//    
//    func didTapPreviousMonth() {
//        calendarView.previousMonth()
//    }
    
}


extension CalenderView {
    
    func getCalenderDataFromServer(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        
        
        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            self.arrEventStart = []
            self.arrEventEnd = []
            
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                for obj in result {
                    let sdt = self.stringToDate(strDate: obj["start"] as! String)
                    let strSD = self.dateToString(dt: sdt)
                    self.arrEventStart.append(strSD)
                    let edt = self.stringToDate(strDate: obj["end"] as! String)
                    let strED = self.dateToString(dt: edt)
                    self.arrEventEnd.append(strED)
                    self.calendarView.addEvent("", date: sdt)
                    self.calendarView.addEvent("", date: edt)
                }
//                self.calendarView.delegate = self
//                self.calendarView.dataSource = self
                self.calendarView.reloadData()
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
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dt)
    }
}

extension CalenderView : BottomPopupDelegate {
    
    func bottomPopupViewLoaded() {
        print("bottomPopupViewLoaded")
    }
    
    func bottomPopupWillAppear() {
        print("bottomPopupWillAppear")
    }
    
    func bottomPopupDidAppear() {
        print("bottomPopupDidAppear")
    }
    
    func bottomPopupWillDismiss() {
        print("bottomPopupWillDismiss")
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupDidDismiss")
    }
    
    func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat) {
        print("bottomPopupDismissInteractionPercentChanged fromValue: \(oldValue) to: \(newValue)")
    }
}


// add event in google calender

extension CalenderView : GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            OBJCOM.setAlert(_title: "Authentication Error", message: error.localizedDescription)
            service.authorizer = nil
        } else {
            
            service.authorizer = user.authentication.fetcherAuthorizer()
            self.fetchEvents()
            
            if addEvent != "addEvent" {
                if googleSyncFlag == "login" {
                    // DispatchQueue.main.async {
                    googleSync = "login"
                    let dictParam = ["user_id" : userID,
                                     "platform": "3",
                                     "access_token" : user.authentication.accessToken!,
                                     "refresh_token" : user.authentication.refreshToken,
                                     "email_id" : user.profile.email!]
                    
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.apiCallForAddUserInfoInDB(dictParam: dictParam as [String : AnyObject])
                        
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    //}
                }
            }else{
                self.addEvent = ""
                self.addEventoToGoogleCalendar(dict: self.eventDataForAdd)
            }
        }
    }
    
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId:"primary")
        query.maxResults = 100
        query.timeMin = GTLRDateTime(date: Date()) // startDate
        //        query.timeMax = endDate
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        //query.orderBy = kGTLRCalendarOrderByUpdated
        
        if googleSyncFlag == "sync"{
            service.executeQuery(
                query,
                delegate: self,
                didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        }else if googleSyncFlag == "desync"{
            let queryClear = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
            service.executeQuery(
                queryClear,
                delegate: self,
                didFinish: #selector(desyncGoogleEvents(ticket:finishedWithObject:error:)))
        }else if googleSyncFlag == "login" {
            self.apiCallForDesyncEventWithServer()
        }
    }
    
    func deleteEvents(eventId : String) {
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: eventId)
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(deleteGoogleEvents(ticket:finishedWithObject:error:)))
    }
    
    @objc func deleteGoogleEvents(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Event,
        error : NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message:"\(error?.localizedDescription ?? "")" )
        }
        print(response)
        OBJCOM.popUp(context: self, msg: "Event deleted successfully from google calender.")
    }
    
    
    @objc func desyncGoogleEvents(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message:"\(error?.localizedDescription ?? "")" )
        }
        GIDSignIn.sharedInstance().signOut()
        OBJCOM.setLoader()
        self.apiCallForDesyncEventWithServer()
    }
    
    // Display the start dates and event summaries in the UITextView
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        var googleEvents = [AnyObject]()
        
        if error != nil {
            OBJCOM.popUp(context: self, msg: "No new event(s) found to sync with Success Entellus app calender.")
            return
        }
        
        if let events = response.items, !events.isEmpty {
            for event in events {
                self.createdDate = event.created
                self.updatedDate = event.updated
                if event.start?.dateTime == nil {
                    self.startDate = event.start?.date
                }else{
                    self.startDate = event.start?.dateTime
                }
                
                if event.end?.dateTime == nil {
                    self.endDate = event.end?.date
                }else{
                    self.endDate = event.end?.dateTime
                }
                
                let strStartDate = self.dateToStringG(dt: startDate.date)
                let strEndDate = self.dateToStringG(dt: endDate.date)
                let strCreated = self.dateToStringG(dt: createdDate.date)
                let strUpdated = self.dateToStringG(dt: updatedDate.date)
                
                var dictGoogleData = [String : Any]()
                dictGoogleData["id"] = event.identifier ?? ""
                dictGoogleData["organizer"] = event.organizer?.email ?? ""
                dictGoogleData["location"] = event.location  ?? ""
                dictGoogleData["iCalUID"] = event.iCalUID  ?? ""
                dictGoogleData["description"] = event.summary ?? ""
                dictGoogleData["htmlLink"] = event.htmlLink ?? ""
                dictGoogleData["hangoutLink"] = event.hangoutLink  ?? ""
                dictGoogleData["sequence"] = "0"
                dictGoogleData["end"] = ["dateTime":strEndDate,"timeZone":"Asia/Kolkata"]
                dictGoogleData["start"] = ["dateTime":strStartDate,"timeZone":"Asia/Kolkata"]
                dictGoogleData["summary"] = event.summary ?? ""
                dictGoogleData["creator"] = event.organizer?.email ?? ""
                dictGoogleData["kind"] = event.kind ?? ""
                dictGoogleData["reminders"] = "useDefault" as String
                dictGoogleData["created"] = strCreated
                dictGoogleData["updated"] = strUpdated
                dictGoogleData["status"] = "confirmed"
                dictGoogleData["calenderGoogle"] = "1"
                dictGoogleData["recurringEventId"] = event.recurringEventId
                googleEvents.append(dictGoogleData as AnyObject)
            }
        }
        if googleEvents.count > 0 {
            self.apiCallForAddGoogleEventsInDb(obj:googleEvents)
        }
    }
    
    func apiCallForAddGoogleEventsInDb(obj:[AnyObject]){
        
        let dictParam = ["user_id" : userID,
                         "platform": "3",
                         "result"  : obj] as [String : AnyObject]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        
        OBJCOM.modalAPICall(Action: "addAllGoogleEventsDBIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForCheckCalenderEmailActive(){
        let dictParam = ["user_id" : userID,
                         "platform": "3"]
        
        OBJCOM.modalAPICall(Action: "checkCalenderEmailActive", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                
                let status = JsonDict!["status"] as? String ?? ""
                // let emailId = JsonDict!["emailId"] as? String ?? ""
                
                if status == "login" {
                    let result = JsonDict!["result"] as! String
                    googleSyncFlag = status
                    self.activeEmail = ""
                    OBJCOM.popUp(context: self, msg: result)
                }else if status == "active" {
                    googleSyncFlag = status
                    self.activeEmail = JsonDict!["emailId"] as! String
                    GIDSignIn.sharedInstance().signInSilently()
                }else if status == "desync" {
                    self.activeEmail = JsonDict!["emailId"] as! String
                    googleSyncFlag = status
                }
               // OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForAddUserInfoInDB(dictParam:[String : AnyObject]){
        OBJCOM.modalAPICall(Action: "addCalenderInfoDatabase", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.popUp(context: self, msg: result)
                googleSyncFlag = "sync"
                self.fetchEvents()
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForDesyncEventWithServer(){
        let dictParam = ["user_id":userID]
        OBJCOM.modalAPICall(Action: "deleteSyncCalendarEvent", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.popUp(context: self, msg: result)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func dateToStringG(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: dt)
    }
    
    //============== add google calender events ======================
    @objc func CreateGoogleEvent(notification: NSNotification) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            GIDSignIn.sharedInstance().signInSilently()
            
            self.eventDataForAdd = notification.userInfo as! [String : Any]
            
        }else{
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func addEventoToGoogleCalendar(dict:[String:Any]) {
        let calendarEvent = GTLRCalendar_Event()
        
        calendarEvent.summary = dict["goal_id"] as? String ?? ""
        calendarEvent.descriptionProperty = dict["task_details"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startTime = "\(dict["task_from_date"] ?? "") \(dict["task_from_time"] ?? "")"
        let endTime = "\(dict["task_to_date"] ?? "") \(dict["task_to_time"] ?? "")"
        
        let startDate = dateFormatter.date(from: startTime)
        let endDate = dateFormatter.date(from: endTime)
        
        if startDate == nil || endDate == nil {
            return
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.EEEE"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        calendarEvent.start = GTLRCalendar_EventDateTime()
        calendarEvent.start?.dateTime = GTLRDateTime(date: startDate!)
        calendarEvent.start?.timeZone = TimeZone.autoupdatingCurrent.identifier
        
        calendarEvent.end = GTLRCalendar_EventDateTime()
        calendarEvent.end?.dateTime = GTLRDateTime(date: endDate!)
        calendarEvent.end?.timeZone = TimeZone.autoupdatingCurrent.identifier
        
        calendarEvent.status = "confirmed"
        calendarEvent.location = ""
        
        let remaindar = GTLRCalendar_EventReminder()
        remaindar.minutes = 300
        remaindar.method = "email"
        
        calendarEvent.reminders = GTLRCalendar_Event_Reminders()
        calendarEvent.reminders?.overrides = [remaindar]
        calendarEvent.reminders?.useDefault = false
      
        print(calendarEvent)
        
        let insertQuery = GTLRCalendarQuery_EventsInsert.query(withObject: calendarEvent, calendarId: "primary")
        insertQuery.maxAttendees = 2
        insertQuery.supportsAttachments = false
        insertQuery.sendNotifications = true
        
        
        service.executeQuery(
            insertQuery,
            delegate: self,
            didFinish: #selector(insertGoogleEvents(ticket:finishedWithObject:error:)))
    }
    
    
    @objc func insertGoogleEvents(
        ticket:GTLRServiceTicket,
        finishedWithObject event:GTLRCalendar_Event,
        error:NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message: "\(error!.localizedDescription)")
            return
        }else{
            
            self.createdDate = event.created
            self.updatedDate = event.updated
            self.startDate = event.start?.dateTime
            self.endDate = event.end?.dateTime
            
            let strStartDate = self.dateToStringG(dt: startDate.date)
            let strEndDate = self.dateToStringG(dt: endDate.date)
            let strCreated = self.dateToStringG(dt: createdDate.date)
            let strUpdated = self.dateToStringG(dt: updatedDate.date)
            
            var dictGoogleData = [String : Any]()
            dictGoogleData["id"] = event.identifier ?? ""
            dictGoogleData["organizer"] = event.organizer?.email ?? ""
            dictGoogleData["location"] = event.location  ?? ""
            dictGoogleData["iCalUID"] = event.iCalUID  ?? ""
            dictGoogleData["description"] = event.summary ?? ""
            dictGoogleData["htmlLink"] = event.htmlLink ?? ""
            dictGoogleData["hangoutLink"] = event.hangoutLink  ?? ""
            dictGoogleData["sequence"] = "0"
            dictGoogleData["end"] = ["dateTime":strEndDate,"timeZone":"UTC"]
            dictGoogleData["start"] = ["dateTime":strStartDate,"timeZone":"UTC"]
            dictGoogleData["summary"] = event.summary  ?? ""
            dictGoogleData["creator"] = event.organizer?.email ?? ""
            dictGoogleData["kind"] = event.kind ?? ""
            dictGoogleData["reminders"] = "useDefault" as String
            dictGoogleData["created"] = strCreated
            dictGoogleData["updated"] = strUpdated
            dictGoogleData["status"] = "confirmed"
            dictGoogleData["calenderGoogle"] = "1"
            dictGoogleData["recurringEventId"] = event.recurringEventId ?? ""
            print("\n--------\n\(dictGoogleData)\n-----------")
            // DispatchQueue.main.async(execute: {
            self.apiCallAddGoogleEvent(result:dictGoogleData)
            //  })
        }
    }
    
    func apiCallAddGoogleEvent(result:[String:Any]){
        
        let jsonData = try? JSONSerialization.data(withJSONObject: result, options: [])
        let resultString = String(data: jsonData!, encoding: .utf8)
        let dictParam = ["result":resultString,
                         "user_id":userID,
                         "selection":self.eventDataForAdd["selection"],
                         "occurence":self.eventDataForAdd["occurence"],
                         "repeatBy":self.eventDataForAdd["repeatBy"],
                         "tag":self.eventDataForAdd["tag"],
                    "complete_goals":self.eventDataForAdd["complete_goals"],
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "createEventGoogleCalender", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: "\(result)")
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: "\(result)")
                OBJCOM.hideLoader()
            }
            googleSyncFlag = "sync"
            googleSync = "login"
            self.fetchEvents()
        };
    }
    
    // Helper to build date
    func buildDate(date: Date) -> GTLRCalendar_EventDateTime {
        let datetime = GTLRDateTime(date: date)
        let dateObject = GTLRCalendar_EventDateTime()
        dateObject.dateTime = datetime
        return dateObject
    }
}

extension CalenderView {
    @IBAction func actionMoreOptions(_ sender:AnyObject) {
        let item1 = ActionSheetItem(title: "Sign In With Google Calender", value: 1)
        let item2 = ActionSheetItem(title: "Sync iPhone Calender", value: 2)
        let item3 = ActionSheetItem(title: "Sign Out From Google Calender", value: 3)
        let item4 = ActionSheetItem(title: "Sync Google Calender", value: 4)
        let item5 = ActionSheetItem(title: "Desync Google Calender", value: 5)
        
        
        let button = ActionSheetOkButton(title: "Dismiss")
        var items = [ActionSheetItem]()
        if googleSyncFlag == "login" {
            googleSync = ""
            items = [item1, item2, button]
        }else{
            items = [item3, item4, item5, item2, button]
        }
        
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    GIDSignIn.sharedInstance().signOut()
                    GIDSignIn.sharedInstance().delegate = self
                    GIDSignIn.sharedInstance().uiDelegate = self
                    GIDSignIn.sharedInstance().scopes = self.scopes
                    GIDSignIn.sharedInstance().signIn()
                }else if item == item3 {
                    googleSyncFlag = "login"
                    googleSync = "login"
                    GIDSignIn.sharedInstance().signOut()
                    self.fetchEvents()
                }else if item == item4 {
                    googleSyncFlag = "sync"
                    googleSync = "login"
                    
                    GIDSignIn.sharedInstance().delegate=self
                    GIDSignIn.sharedInstance().uiDelegate=self
                    GIDSignIn.sharedInstance().scopes = self.scopes
                    if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
                        GIDSignIn.sharedInstance().signInSilently()
                    }else{
                        GIDSignIn.sharedInstance().signIn()
                    }
                }else if item == item5 {
                    googleSyncFlag = "desync"
                    googleSync = "login"
                    GIDSignIn.sharedInstance().signOut()
                    self.fetchEvents()
                }else if item == item2 {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.fetchEventsFromDeviceCalendarSync()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
}

//IPhone Calender
extension CalenderView {
    
    func fetchEventsFromDeviceCalendarSync(){
        AMGCalendarManager.shared.getAllEvents(completion: { (error, result) in
            self.iCalEvents = []
            
            if result != nil {
                
                for event in result! {
                    
                    if event.eventIdentifier != nil {
                        let eventStartDate = event.startDate
                        let eventEndDate = event.endDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        let strStardDate = dateFormatter.string(from: eventStartDate!)
                        let strEndDate = dateFormatter.string(from: eventEndDate!)
                        dateFormatter.dateFormat = "HH:mm:ss"
                        dateFormatter.locale = .autoupdatingCurrent
                        let strStardTime = dateFormatter.string(from: eventStartDate!)
                        let strEndTime = dateFormatter.string(from: eventEndDate!)
                        
                        var recStr = ""
                        if event.hasRecurrenceRules {
                            // print(event.recurrenceRules?.first!.description)
                            var strFreq = ""
                            if event.recurrenceRules?.first?.frequency == .daily {
                                strFreq = "DAILY"
                            }else if event.recurrenceRules?.first?.frequency == .weekly {
                                strFreq = "WEEKLY"
                            }else if event.recurrenceRules?.first?.frequency == .monthly {
                                strFreq = "MONTHLY"
                            }else {
                                strFreq = ""
                            }
                            
                            var arrDays = [String]()
                            if let daysOfWeeks = event.recurrenceRules?.first?.daysOfTheWeek {
                                for obj in daysOfWeeks {
                                    let dayStr = self.getWeekDaysFromRecEvent(obj)
                                    arrDays.append(dayStr!)
                                }
                            }
                            
                            var day = ""
                            if arrDays.count > 0 {
                                day = arrDays.joined(separator: ",")
                            }
                            
                            recStr = "RRULE FREQ=\(strFreq);BYDAY=\(day);INTERVAL=\(event.recurrenceRules?.first?.interval ?? 1)"
                        }
                        
                        let dict = ["startDate":strStardDate,
                                    "endDate":strEndDate,
                                    "startTime":strStardTime,
                                    "endTime":strEndTime,
                                    "eventTitle":event.title!,
                                    "iosCalEventId":event.eventIdentifier!,
                                    "iosEventFlag":1,
                                    "iosCalenderRecurData" : recStr,
                                    "task_details":event.notes ?? ""] as [String : Any]
                        
                        self.iCalEvents.append(dict as [String:Any])
                    }
                }
                OBJCOM.hideLoader()
                print(self.iCalEvents.count)
                if self.iCalEvents.count > 0 {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.addAppleCalEventsInDBSync(self.iCalEvents)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            } else{
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServerSync()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            
        })
    }
    
    func addAppleCalEventsInDBSync(_ eventDetails : [[String:Any]]){
        let dictParam = ["platform": "3",
                         "userId": userID,
                         "event_details":eventDetails] as [String:AnyObject]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam as [String:AnyObject], options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:AnyObject]
        
        OBJCOM.modalAPICall(Action: "addIosEvent", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServerSync()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                //
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCalenderDataFromServerSync(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            self.arrEventTitle = []
            self.arrEventStart = []
            self.arrEventEnd = []
            self.arrEventId = []
            
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                OBJCOM.hideLoader()
                for obj in result {
                    self.arrEventTitle.append(obj["title"] as! String)
                    self.arrEventId.append(obj["zo_user_daily_task_id"] as! String)
                    
                    let sdt = self.stringToDate(strDate: obj["start"] as! String)
                    let strSD = self.dateToString(dt: sdt)
                    self.arrEventStart.append(strSD)
                    let edt = self.stringToDate(strDate: obj["end"] as! String)
                    let strED = self.dateToString(dt: edt)
                    self.arrEventEnd.append(strED)
                    self.calendarView.addEvent("", date: sdt)
                    self.calendarView.addEvent("", date: edt)
                    
                }
                self.calendarView.dataSource = self
                self.calendarView.delegate = self
                OBJCOM.setAlert(_title: "", message: "iPhone calendar event(s) sync successfully.")
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func fetchEventsFromDeviceCalendar(){
        
        AMGCalendarManager.shared.getAllEvents(completion: { (error, result) in
            self.iCalEvents = []
            
            if result != nil {
                for event in result! {
                    
                    if event.eventIdentifier != nil {
                        let eventStartDate = event.startDate
                        let eventEndDate = event.endDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        let strStardDate = dateFormatter.string(from: eventStartDate!)
                        let strEndDate = dateFormatter.string(from: eventEndDate!)
                        dateFormatter.dateFormat = "HH:mm:ss"
                        dateFormatter.locale = .autoupdatingCurrent
                        let strStardTime = dateFormatter.string(from: eventStartDate!)
                        let strEndTime = dateFormatter.string(from: eventEndDate!)
                        
                        var recStr = ""
                        if event.hasRecurrenceRules {
                            // print(event.recurrenceRules?.first!.description)
                            var strFreq = ""
                            if event.recurrenceRules?.first?.frequency == .daily {
                                strFreq = "DAILY"
                            }else if event.recurrenceRules?.first?.frequency == .weekly {
                                strFreq = "WEEKLY"
                            }else if event.recurrenceRules?.first?.frequency == .monthly {
                                strFreq = "MONTHLY"
                            }else {
                                strFreq = ""
                            }
                            
                            var arrDays = [String]()
                            if let daysOfWeeks = event.recurrenceRules?.first?.daysOfTheWeek {
                                for obj in daysOfWeeks {
                                    let dayStr = self.getWeekDaysFromRecEvent(obj)
                                    arrDays.append(dayStr!)
                                }
                            }
                            
                            var day = ""
                            if arrDays.count > 0 {
                                day = arrDays.joined(separator: ",")
                            }
                            
                            recStr = "RRULE FREQ=\(strFreq);BYDAY=\(day);INTERVAL=\(event.recurrenceRules?.first?.interval ?? 1)"
                        }
                        
                        let dict = ["startDate":strStardDate,
                                    "endDate":strEndDate,
                                    "startTime":strStardTime,
                                    "endTime":strEndTime,
                                    "eventTitle":event.title,
                                    "iosCalEventId":event.eventIdentifier,
                                    "iosEventFlag":1,
                                    "iosCalenderRecurData" : recStr,
                                    "task_details":event.notes ?? ""] as [String : Any]
                        
                        self.iCalEvents.append(dict as [String:Any])
                    }
                }
                print(self.iCalEvents)
                OBJCOM.hideLoader()
            }
            
            
            if self.iCalEvents.count > 0 {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.addAppleCalEventsInDB(self.iCalEvents)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            
        })
    }
    
    func addAppleCalEventsInDB(_ eventDetails : [[String:Any]]){
        let dictParam = ["platform": "3",
                         "userId": userID,
                         "event_details":eventDetails] as [String:AnyObject]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam as [String:AnyObject], options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:AnyObject]
        
        OBJCOM.modalAPICall(Action: "addIosEvent", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    // DispatchQueue.main.async {
                    self.getCalenderDataFromServer()
                    // }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getWeekDaysFromRecEvent(_ day:EKRecurrenceDayOfWeek) -> String?{
        switch day {
        case EKRecurrenceDayOfWeek(.sunday):
            return "SU"
        case EKRecurrenceDayOfWeek(.monday):
            return "MO"
        case EKRecurrenceDayOfWeek(.tuesday):
            return "TU"
        case EKRecurrenceDayOfWeek(.wednesday):
            return "WE"
        case EKRecurrenceDayOfWeek(.thursday):
            return "TH"
        case EKRecurrenceDayOfWeek(.friday):
            return "FR"
        case EKRecurrenceDayOfWeek(.saturday):
            return "SA"
        default:
            return ""
        }
    }
}

extension CalenderView {
    // MARK : KDCalendarDataSource
    
    func getStartDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = -3
        let today = Date()
        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        return threeMonthsAgo
    }
    
    func getEndDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 3
        let today = Date()
        let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        return twoYearsFromNow
    }
    
    
    // MARK : KDCalendarDelegate
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
        
        print("Did Select: \(date) with \(events.count) events")
        for event in events {
            print("Starting at:\(event.startDate)")
            
            let selectedDate = dateToString(dt: event.startDate)
            print(selectedDate)
            if self.arrEventStart.contains(selectedDate) || self.arrEventEnd.contains(selectedDate) {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.UpdateCalender),
                    name: NSNotification.Name(rawValue: "UpdateCalender"),
                    object: nil)
                guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "idEventListView") as? EventListView else { return }
                popupVC.selectedDate = selectedDate
                popupVC.height = 500
                popupVC.topCornerRadius = 20
                popupVC.presentDuration = 0.5
                popupVC.dismissDuration = 0.5
                popupVC.popupDelegate = self
                
                present(popupVC, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
    }
    
    
    func calendar(_ calendar: CalendarView, didLongPressDate date : Date, withEvents events: [CalendarEvent]?) {
        
        if let events = events {
            for event in events {
                print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
            }
        }
    }
    
    // MARK : Events
    
    @IBAction func onValueChange(_ picker : UIDatePicker) {
        self.calendarView.setDisplayDate(picker.date, animated: true)
    }
    
    @IBAction func goToPreviousMonth(_ sender: Any) {
        self.calendarView.goToPreviousMonth()
    }
    @IBAction func goToNextMonth(_ sender: Any) {
        self.calendarView.goToNextMonth()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
