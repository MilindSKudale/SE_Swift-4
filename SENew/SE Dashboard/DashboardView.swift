//
//  DashboardView.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Parchment
import Sheeeeeeeeet
import EAIntroView

class DashboardView: SliderVC, EAIntroDelegate {

    fileprivate let vcTitles = [
        "Daily Checklist",
        "Daily Score Graph",
        "Weekly Score Card"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDashBoard()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getSubscriptionDate()
            let motiFlag = UserDefaults.standard.value(forKey: "MOTIVATIONAL") as? String ?? "true"
            if motiFlag == "false" {
                motivatinalData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func loadDashBoard(){
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let DailyChecklistView = storyboard.instantiateViewController(withIdentifier: "idDailyChecklistView")
        DailyChecklistView.title = "Daily Checklist"
        let DailyScoreGraphView = storyboard.instantiateViewController(withIdentifier: "idDailyScoreGraphView")
        DailyScoreGraphView.title = "Daily Score Graph"
        let WeeklyScoreCardView = storyboard.instantiateViewController(withIdentifier: "idWeeklyScoreCardView")
        WeeklyScoreCardView.title = "Weekly Score Card"
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
            DailyChecklistView,
            DailyScoreGraphView,
            WeeklyScoreCardView
            ])
 
        pagingViewController.menuBackgroundColor = UIColor(patternImage: UIImage(named: "btnBg1.png")!)
        pagingViewController.indicatorColor = .white
        pagingViewController.selectedTextColor = .white
        pagingViewController.textColor = UIColor.white.withAlphaComponent(0.7)
        
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParent: self)
        
        DispatchQueue.main.async {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                // self.fetchAllContacts()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                if userData.count > 0 {
                    let cft = userData["userCft"] as? String ?? "0"
                    if cft == "1" {
                        OBJLOC.StartupdateLocation()
                    }
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func getSubscriptionDate(){
        
        let dictParam = ["userId": userID,
                         "platform": "3"]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        OBJCOM.modalAPICall(Action: "getSubscriptionDate", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                print(dictJsonData)
                let subDate = "\(dictJsonData["sDate"] as? String ?? "")"
                if subDate != "" {
                    let dt = self.stringToDate(strDate: subDate)
                    subscriptionDate = dt
                }
                OBJCOM.hideLoader()
            }
        };
    }
    func stringToDate(strDate:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: strDate)!
    }
    
    func motivatinalData(){
        
        let dictParam = ["user_id": userID]
        OBJCOM.modalAPICall(Action: "getMotivationalQuotes", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                if let vc = UIStoryboard(name: "MQ", bundle: nil).instantiateViewController(withIdentifier: "idMotivationalView") as? MotivationalView {
                    vc.dict = dictJsonData
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionMoreOption(_ sender:AnyObject){
        
        let item1 = ActionSheetItem(title: "Help", value: 1)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obDailyCheck1")
                    let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obDailyCheck2")
                    let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "obDailyCheck3")
                    let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "obDailyCheck4")
                    let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "obDailyCheck5")
                    
                    let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!,ingropage4!,ingropage5!])
                    introView?.delegate = self
                    introView?.skipButton.backgroundColor = APPBLUECOLOR
                    introView?.skipButton.layer.cornerRadius = 15.0
                    introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    introView?.show(in: self.view)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        if(wasSkipped) {
            
            print("Intro skipped")
            
        } else {
            
            print("Intro skipped")
        }
    }
}
