//
//  TopScoreRecruitList.swift
//  SENew
//
//  Created by Milind Kudale on 16/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class TopScoreRecruitList: UIViewController {

    @IBOutlet var topBar : SMTabbar!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var noDataView : UIView!
    @IBOutlet var bgview : UIView!
    
    var arrAccessId = [String]()
    var arrImg = [String]()
    var arrName = [String]()
    var arrCount = [String]()
    
    var allFlag = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
        tblList.tableFooterView = UIView()
        bgview.layer.cornerRadius = 10.0
        bgview.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer(limit: "")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    func setupTabbar(){
        
        let list : [String] = ["All Recruits", "Top 10 Recruits"]
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
                    self.getDataFromServer(limit: "")
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else if index == 0 {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getDataFromServer(limit: "10")
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            print(index)
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDataFromServer(limit : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "limit":limit]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "showUserTopScore", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrAccessId = []
            self.arrName = []
            self.arrCount = []
            self.arrImg = []
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.noDataView.isHidden = false
                let data = JsonDict!["result"] as! [AnyObject]
                if data.count > 0 {
                    for i in 0..<data.count {
                        self.arrAccessId.append(data[i]["recruitUserId"] as? String ?? "")
                        self.arrName.append(data[i]["recruitUserName"] as? String ?? "")
                        self.arrCount.append(data[i]["recruitUserScoreValue"] as? String ?? "")
                        self.arrImg.append(data[i]["recruitUserImgPath"] as? String ?? "")
                    }
                    self.noDataView.isHidden = true
                }
                OBJCOM.hideLoader()
            }else{
                self.noDataView.isHidden = false
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        };
    }
}

extension TopScoreRecruitList : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            return arrName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! TopScoreCell
    
        cell.lblName.text = self.arrName[indexPath.row]
        cell.lblScore.text = self.arrCount[indexPath.row]
        cell.configure(name: cell.lblName.text!)
       
        return cell
    }
    
}



class TopScoreCell: UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblScore : UILabel!
    @IBOutlet var imgView : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(name: String) {
        lblName?.text = name
        imgView?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView?.image = nil
        lblName?.text = nil
    }
    
}

