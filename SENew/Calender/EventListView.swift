//
//  EventListView.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EventKit

class EventListView: BottomPopupViewController {

    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var lblSelectedDate : UILabel!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var tblListHeight : NSLayoutConstraint!
    
    var selectedDate = ""
    var arrEvent = [AnyObject]()
    var arrEventId = [String]()
    var arrEventName = [String]()
    var arrEventDetails = [String]()
    var arrStartTime = [String]()
    var arrEndTime = [String]()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblList.tableFooterView = UIView()
        tblList.rowHeight = UITableView.automaticDimension
        tblList.estimatedRowHeight = 70.0
        tblListHeight.constant = 200.0
        
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        self.lblSelectedDate.text = self.selectedDate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTaskListFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
       // NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func getPopupHeight() -> CGFloat {
        return self.view.frame.height//height ?? CGFloat(300)
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
    
    
    
    func getTaskListFromServer(){
        let dictParam = ["user_id": userID,
                         "from_date":self.selectedDate]
        
        OBJCOM.modalAPICall(Action: "getEventListByDate", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            self.arrEvent = []
            self.arrEventName = []
            self.arrEventDetails = []
            self.arrStartTime = []
            self.arrEndTime = []
            self.arrEventId = []
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                
                for obj in result {
                    self.arrEvent.append(obj)
                    self.arrEventName.append(obj["goal_name"] as! String)
                    self.arrEventDetails.append(obj["task_details"] as! String)
                    self.arrStartTime.append(obj["task_fromdt"] as! String)
                    self.arrEndTime.append(obj["task_todt"] as! String)
                    self.arrEventId.append(obj["edit_id"] as! String)
                }
                
                if self.arrEvent.count <= 4 {
                    self.tblListHeight.constant = CGFloat(self.arrEvent.count*70)
                }else if self.arrEvent.count > 4 {
                    self.tblListHeight.constant = 400.0
                }else{
                    self.tblListHeight.constant = 200.0
                }
                OBJCOM.hideLoader()
                if self.arrEvent.count == 0 {
                    NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                
            }else{
                OBJCOM.hideLoader()
                NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil)
                self.dismiss(animated: true, completion: nil)
                
            }
            self.tblList.reloadData()
        };
    }

}

extension EventListView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEventName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventListCell
        cell.lblEventName.text = self.arrEventName[indexPath.row]
        cell.lblEventDesc.text = self.arrEventDetails[indexPath.row]
        let arrTime = self.arrStartTime[indexPath.row].components(separatedBy: " ")
        cell.lblEventTime.text = "\(arrTime.last ?? "")"
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        
        cell.btnDelete.addTarget(self, action: #selector(deleteEvent(_ :)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(editEvent(_ :)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension EventListView {
    
    @objc func editEvent(_ sender:UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.EditTaskList),
            name: NSNotification.Name(rawValue: "EditTaskList"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "Calender", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditEvent") as! EditEvent
        vc.eventData = self.arrEvent[sender.tag] as? [String:AnyObject]
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteEvent(_ sender:UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.EditTaskList),
            name: NSNotification.Name(rawValue: "EditTaskList"),
            object: nil)
        
        let eventData = self.arrEvent[sender.tag]
        let googleCalEventFlag = "\(eventData["googleCalEventFlag"] as AnyObject)"
        let googleCalRecurEventId = "\(eventData["googleCalRecurEventId"] as AnyObject)"
        let googleCalEventId = "\(eventData["googleCalEventId"] as AnyObject)"
        let randomNumber = "\(eventData["randomNumber"] as AnyObject)"
        let editId = "\(eventData["edit_id"] as AnyObject)"
        let isAppleEvent = "\(eventData["iosEventFlag"] as AnyObject)"
        
        print(googleCalEventFlag, googleCalRecurEventId, randomNumber)
        
        if googleCalEventFlag != "0" {
            
            if googleCalRecurEventId != ""{
                let dict = ["eventEditId":editId,
                            "googleEventFlag":googleCalEventFlag,
                            "recurringEventId":googleCalRecurEventId,
                            "RandomNumberValue":randomNumber,
                            "googleCalEventId":googleCalEventId]
                
                let storyboard = UIStoryboard(name: "Calender", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idDeleteRecurringEvent") as! DeleteRecurringEvent
                //vc.eventData = self.arrEvent[sender.tag] as! [String:AnyObject]
                vc.eventData = dict
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                self.present(vc, animated: false, completion: nil)
            }
        }else{
            
            if randomNumber != "" && randomNumber != "0"{
                //DeleteMultiEventsActionSheet(index : sender.tag)
                let dict = ["eventEditId":editId,
                            "googleEventFlag":googleCalEventFlag,
                            "recurringEventId":googleCalRecurEventId,
                            "RandomNumberValue":randomNumber,
                            "googleCalEventId":googleCalEventId]
                
                let storyboard = UIStoryboard(name: "Calender", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idDeleteRecurringEvent") as! DeleteRecurringEvent
                //vc.eventData = self.arrEvent[sender.tag] as! [String:AnyObject]
                vc.eventData = dict
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
            }else if isAppleEvent == "1" {
                let recString = eventData["iosCalenderRecurData"] as? String ?? ""
                if recString == "" {
                    self.deleteSingleEvent(index : sender.tag)
                }else{
                    self.DeleteMultiEventsActionSheet(index : sender.tag)
                }
                
            }else{
                deleteSingleEvent(index : sender.tag)
            }
        }
    }
    
    func deleteSingleEvent(index:Int){
        
        let eventData = self.arrEvent[index]
        let iosEventId = "\(eventData["iosCalEventId"] as AnyObject)"
        
        let alertVC = PMAlertController(title: "", description: "Do you want to delete '\(self.arrEventName[index])' event?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                let dictParam = ["user_id": userID,
                                 "edit_id":self.arrEventId[index]]
                
                OBJCOM.modalAPICall(Action: "deleteEvent", param:dictParam as [String : AnyObject],  vcObject: self){
                    JsonDict, staus in
                    let success:String = JsonDict!["IsSuccess"] as! String
                    if success == "true"{
                        let result = JsonDict!["result"] as AnyObject
                        OBJCOM.hideLoader()
                        
                        let alertVC = PMAlertController(title: "", description: result as! String, image: nil, style: .alert)
                        
                        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                            do {
                                if let event = self.eventStore.event(withIdentifier: iosEventId){
                                    try self.eventStore.remove(event, span: .thisEvent, commit: true)
                                }
                            } catch {
                                
                            }
                            
                            if OBJCOM.isConnectedToNetwork(){
                                OBJCOM.setLoader()
                                self.getTaskListFromServer()
                            }else{
                                OBJCOM.NoInternetConnectionCall()
                            }
                        }))
                        self.present(alertVC, animated: true, completion: nil)
        
                    }else{
                        print("result:",JsonDict ?? "")
                        OBJCOM.hideLoader()
                    }
                };
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
        
        
        let alertController = UIAlertController(title: "", message: "Do you want to delete '\(self.arrEventName[index])' event", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func DeleteMultiEventsActionSheet(index : Int){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let actionSupport = UIAlertAction(title: "Delete this event only", style: .default)
        {
            UIAlertAction in
            
            self.deleteSingleEvent(index : index)
        }
        actionSupport.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionFeedback = UIAlertAction(title: "Delete all future events", style: .default)
        {
            UIAlertAction in
            self.deleteAllMultiEvents(index:index)
        }
        actionFeedback.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(actionSupport)
        alert.addAction(actionFeedback)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAllMultiEvents(index:Int){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            
            let eventData = self.arrEvent[index]
            let googleCalEventFlag = "\(eventData["googleCalEventFlag"] as AnyObject)"
            let randomNumber = "\(eventData["randomNumber"] as AnyObject)"
            let editId = "\(eventData["edit_id"] as AnyObject)"
            let iosEventId = "\(eventData["iosCalEventId"] as AnyObject)"
            
            //            dictParam["iosEventFlag"] = isAppleEvent
            //            dictParam["iosCalEventId"] = eventData["iosCalEventId"] as? String ?? ""
            //            dictParam["iosCalenderRecurData"] = eventData["iosCalenderRecurData"] as? String ?? ""
            
            let dictParam = ["user_id": userID,
                             "edit_id":editId,
                             "repeatValue": randomNumber,
                             "googleflag":googleCalEventFlag]
            
            OBJCOM.modalAPICall(Action: "deleteRecurringEventDBRandom", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as AnyObject
                    OBJCOM.hideLoader()
                    OBJCOM.setAlert(_title: "", message: result as! String)
                    
                    do {
                        if let event = self.eventStore.event(withIdentifier: iosEventId) {
                            try self.eventStore.remove(event, span: .futureEvents, commit: true)
                        }
                    } catch {
                        
                    }
                    
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getTaskListFromServer()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                }
            };
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func EditTaskList(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTaskListFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

class EventListCell: UITableViewCell {
    
    @IBOutlet var lblEventName : UILabel!
    @IBOutlet var lblEventDesc : UILabel!
    @IBOutlet var lblEventTime : UILabel!
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnDelete : UIButton!
}
