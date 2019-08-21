//
//  CFTFeedbackView.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class CFTFeedbackView: UIViewController {

    @IBOutlet var topBar : SMTabbar!
    @IBOutlet var tblMentorList : UITableView!
    @IBOutlet var noDataView : UIView!
    
    var arrMentorName = [String]()
    var arrMentorImage = [String]()
    var arrAccessDate = [String]()
    var arrMentorId = [String]()
    var arrMsgCount = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
        tblMentorList.tableFooterView = UIView()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getMentorList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func setupTabbar(){
        
        let list : [String] = ["Mentor's Feedback", "Recruit's Feedback"]
        self.topBar.buttonWidth = self.view.frame.width/2
        self.topBar.moveDuration = 0.4
        self.topBar.fontSize = 16.0
        self.topBar.linePosition = .bottom
        self.topBar.lineWidth = self.view.frame.width/2
        self.topBar.selectTab(index: 0)
        
        self.topBar.configureSMTabbar(titleList: list) { (index) -> (Void) in
            if index == 0 {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getMentorList()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else if index == 1{
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getRecruitList()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            print(index)
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name("UpdateCftDashboard"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func getMentorList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorListWithCount", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrMentorName = []
            self.arrMentorImage = []
            self.arrAccessDate = []
            self.arrMentorId = []
            self.arrMsgCount = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrMentorData = JsonDict!["result"] as! [AnyObject]
                print(arrMentorData)
                
                for i in 0..<arrMentorData.count {
                    self.arrMentorName.append(arrMentorData[i]["fullName"] as? String ?? "")
                    self.arrMentorImage.append(arrMentorData[i]["imgPath"] as? String ?? "")
                    self.arrAccessDate.append(arrMentorData[i]["addDateFeedback"] as? String ?? "")
                    self.arrMentorId.append(arrMentorData[i]["cftAccessUserId"] as? String ?? "")
                    self.arrMsgCount.append(arrMentorData[i]["feedbackCount"] as? String ?? "")
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblMentorList.reloadData()
        };
    }
  
    func getRecruitList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getRecruitListWithCount", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrMentorName = []
            self.arrMentorImage = []
            self.arrAccessDate = []
            self.arrMentorId = []
            self.arrMsgCount = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrMentorData = JsonDict!["result"] as! [AnyObject]
                
                for i in 0..<arrMentorData.count {
                    self.arrMentorName.append(arrMentorData[i]["fullName"] as? String ?? "")
                    self.arrMentorImage.append(arrMentorData[i]["imgPath"] as? String ?? "")
                    self.arrAccessDate.append(arrMentorData[i]["addDateFeedback"] as? String ?? "")
                    self.arrMentorId.append(arrMentorData[i]["cftAccessUserId"] as? String ?? "")
                    self.arrMsgCount.append(arrMentorData[i]["feedbackCount"] as? String ?? "")
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblMentorList.reloadData()
        };
    }
}

extension CFTFeedbackView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMentorName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblMentorList.dequeueReusableCell(withIdentifier: "Cell") as! MentorCell
        
        
        cell.lblName.text = self.arrMentorName[indexPath.row]
        cell.lblCount.text = self.arrMsgCount[indexPath.row]
        if self.arrMsgCount[indexPath.row] == "0" {
            cell.lblCount.isHidden = true
        }else{
            cell.lblCount.isHidden = false
        }
        let avatarImg =  self.arrMentorImage[indexPath.row]
        if avatarImg != "" {
            OBJCOM.setImages(imageURL: avatarImg, imgView: cell.imgMentor)
        }else{
            cell.imgMentor.image = #imageLiteral(resourceName: "profile")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "CFTFeedback", bundle: nil)
        let vc = storyboard.instantiateViewController (withIdentifier: "idCFTConversationView") as! CFTConversationView
        vc.userName = self.arrMentorName[indexPath.row]
        vc.userImage = self.arrMentorImage[indexPath.row]
        vc.cftUserId = self.arrMentorId[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
    }
}


class MentorCell: UITableViewCell {
    
    @IBOutlet var imgMentor : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblCount : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblCount.layer.cornerRadius = self.lblCount.frame.height/2
        self.lblCount.clipsToBounds = true
        
        self.imgMentor.layer.cornerRadius = self.imgMentor.frame.height/2
        self.imgMentor.layer.borderColor = APPGRAYCOLOR.cgColor
        self.imgMentor.layer.borderWidth = 0.5
        self.imgMentor.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
