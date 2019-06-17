//
//  DeleteRecurringEvent.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 12/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class DeleteRecurringEvent: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let scopes = [kGTLRAuthScopeCalendar]
    let service = GTLRCalendarService()
    var deleteFlag = ""
    
    @IBOutlet var btnOnlyThisEvent : UIButton!
    @IBOutlet var btnFollowingEvents : UIButton!
    @IBOutlet var btnAllEvents : UIButton!
    @IBOutlet var btnDelete : UIButton!
    
    var eventData : [String:String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().scopes = self.scopes
        GIDSignIn.sharedInstance().signInSilently()
        print(eventData)
    }
    
    func designUI(){
        btnDelete.layer.cornerRadius = 5
        btnDelete.clipsToBounds = true
        btnOnlyThisEvent.isSelected = true
        btnFollowingEvents.isSelected = false
        btnAllEvents.isSelected = false
        deleteFlag = "1"

    }
    
    @IBAction func actionBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDeleteThisEvent(_ sender: UIButton) {
        btnOnlyThisEvent.isSelected = true
        btnFollowingEvents.isSelected = false
        btnAllEvents.isSelected = false
        deleteFlag = "1"
    }
    
    @IBAction func actionDeleteFollowingEvent(_ sender: UIButton) {
        btnOnlyThisEvent.isSelected = false
        btnFollowingEvents.isSelected = true
        btnAllEvents.isSelected = false
        deleteFlag = "2"
    }
    
    @IBAction func actionDeleteAllEvent(_ sender: UIButton) {
        btnOnlyThisEvent.isSelected = false
        btnFollowingEvents.isSelected = false
        btnAllEvents.isSelected = true
        deleteFlag = "3"
    }
    
    @IBAction func actionDelete(_ sender: UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.deleteRecurringEvents(deleteFlag: self.deleteFlag)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }

    }
    
    func deleteRecurringEvents(deleteFlag : String){
      
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "eventEditId":eventData["eventEditId"],
                         "googleEventFlag":eventData["googleEventFlag"],
                         "recurringEventId":eventData["recurringEventId"],
                         "randomNumberValue":eventData["RandomNumberValue"],
                         "deleteFlag":deleteFlag]
        
        OBJCOM.modalAPICall(Action: "deleteAllEventOption", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result , image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("EditTaskList"), object: nil)
                    
                    self.deleteEvents(eventId: self.eventData["googleCalEventId"]!)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    
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
        if error != nil {
            //OBJCOM.setAlert(_title: "Authentication Error", message: error.localizedDescription)
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()

        }
    }
    
    
    func deleteEvents(eventId : String) {
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: eventId)
        
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(deleteGoogleEvents(ticket:finishedWithObject:error:))
        )
    }
    
    @objc func deleteGoogleEvents(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if error != nil {
          //  OBJCOM.setAlert(_title: "Error", message:"\(error?.localizedDescription ?? "")" )
        }
       
    }
    

}
