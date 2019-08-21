//
//  TCListingView.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet
import JJFloatingActionButton

class TCListingView: SliderVC {

    @IBOutlet var tblList : UITableView!
    @IBOutlet var lblAvailTextMsg : UILabel!
    
    var arrCampaignTitle = [String]()
    var arrCampaignId = [String]()
    var arrCampaignImage = [String]()
    var arrCampaignColor = [AnyObject]()
    var arrCampaignStepContent = [String]()
    var arrTemplateCount = [String]()
    var arrCampaignType = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let vw = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        self.tblList.tableFooterView = vw
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "add_contact")) { item in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateTCList),
                name: NSNotification.Name(rawValue: "UpdateTCList"),
                object: nil)
            let storyboard = UIStoryboard(name: "TC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idCreateTC") as! CreateTC
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
            self.present(vc, animated: true, completion: nil)
        }
        actionButton.display(inViewController: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateTCList(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionMoreOption(_ sender:AnyObject){
        
        let item1 = ActionSheetItem(title: "Help", value: 1)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    let storyboard = UIStoryboard(name: "TC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idTCHelpView") as! TCHelpView
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationStyle = .custom
                    vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
}

extension TCListingView : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCampaignTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! ECCell
        if indexPath.row%2 == 0 {
            cell.backgroundColor = UIColor.groupTableViewBackground
        }else{
            cell.backgroundColor = UIColor.white
        }
        cell.imgbgView.backgroundColor = .white
        let colorObj = self.arrCampaignColor[indexPath.row]
        if colorObj.count > 0 {
            let red: CGFloat = colorObj.object(at: 0) as! CGFloat
            let green: CGFloat = colorObj.object(at: 1) as! CGFloat
            let blue: CGFloat = colorObj.object(at: 2) as! CGFloat
            cell.imgbgView.backgroundColor = UIColor.rgb(red: red, green: green, blue: blue)
        }
        cell.btnMore.isHidden = false
        if self.arrCampaignType[indexPath.row] == "1"{
            cell.btnMore.isHidden = true
        }
        
        cell.title.text = self.arrCampaignTitle[indexPath.row]
        let url = self.arrCampaignImage[indexPath.row]
        OBJCOM.setImages(imageURL: url, imgView: cell.img)
        cell.btnMore.tag = indexPath.row
        cell.btnMore.addTarget(self, action: #selector(actionMore(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTextMessageView") as! TextMessageView
        vc.txtCampId = self.arrCampaignId[indexPath.row]
        vc.txtCampName = self.arrCampaignTitle[indexPath.row]
        vc.isPredefineCampaign = self.arrCampaignType[indexPath.row]
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .crossDissolve
        //vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}

extension TCListingView {
    func getTextCampaignData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                self.arrCampaignImage = []
                self.arrTemplateCount = []
                self.arrCampaignType = []
                
                let txtMsgCount = "\(JsonDict!["txtMsgCount"] as AnyObject)"
                self.lblAvailTextMsg.text = "Available Text Message : \(txtMsgCount)"
                
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "txtCampName") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "txtCampId") as! String)
                    self.arrCampaignImage.append(obj.value(forKey: "campaignImage") as! String)
                    self.arrTemplateCount.append("\(obj.value(forKey: "txtTemplateCount") ?? "")")
                    self.arrCampaignColor.append(obj.value(forKey: "campaignColor") as AnyObject)
                    self.arrCampaignType.append("\(obj.value(forKey: "txtCampfeature") ?? "")")
                }
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @objc func actionMore(_ sender:UIButton){
        let item1 = ActionSheetItem(title: "Rename Campaign", value: 1)
        let item2 = ActionSheetItem(title: "Delete Campaign", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateTCList),
                        name: NSNotification.Name(rawValue: "UpdateTCList"),
                        object: nil)
                    
                    let storyboard = UIStoryboard(name: "TC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idRenameTC") as! RenameTC
                    vc.txtCampName = self.arrCampaignTitle[sender.tag]
                    vc.txtCampId = self.arrCampaignId[sender.tag]
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }else if item == item2 {
                    let campName = self.arrCampaignTitle[sender.tag]
                    let campId = self.arrCampaignId[sender.tag]
                    
                    let alertVC = PMAlertController(title: "", description: "Are you sure, you want to delete '\(campName)' campaign?", image: nil, style: .alert)
                    alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
                    }))
                    alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                        self.deleteCampaignAPICall(campId:campId)
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func deleteCampaignAPICall(campId:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campIdToDelete":campId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getTextCampaignData()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
