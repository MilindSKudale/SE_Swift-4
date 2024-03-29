//
//  ImportEmailTemplates.swift
//  SENew
//
//  Created by Milind Kudale on 11/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ImportEmailTemplates: UIViewController {

    @IBOutlet var bgView : UIView!
    @IBOutlet var btnImport : UIButton!
    @IBOutlet var dropDown : UIDropDown!
    @IBOutlet var stackView : UIStackView!
    @IBOutlet var viewTemplateList : UIView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet weak var btnSelectAll: UIButton!
    
    var arrCampaignTitle = [String]()
    var arrCampaignId = [AnyObject]()
    var arrUnAssignedCampaignId = [AnyObject]()
    var arrTemplateTitle = [String]()
    var arrTemplateId = [AnyObject]()
    
    var arrSelectedTemplates = [String]()
    var campaignId = ""
    var selectedCampaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        btnImport.layer.cornerRadius = 5
        
        bgView.clipsToBounds = true
        btnImport.clipsToBounds = true
        tblList.tableFooterView = UIView()
        self.viewTemplateList.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getUnImportedCampaignsData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionImport(_ sender:UIButton) {
        if arrSelectedTemplates.count > 0 {
            let selTemplates = self.arrSelectedTemplates.joined(separator: ",")
            self.importTemplateAPI(selTemplates:selTemplates)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one template to import into campaign.")
        }
    }
    
    @IBAction func actionSelectAll(sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            for template in self.arrTemplateId {
                self.arrSelectedTemplates.append(template as! String)
            }
        }else{
            self.arrSelectedTemplates.removeAll()
            sender.isSelected = false
        }
        self.tblList.reloadData()
    }
}

extension ImportEmailTemplates {
    
    
    func loadDropDown() {
        self.dropDown.textColor = .black
        self.dropDown.tint = APPBLUECOLOR
        self.dropDown.optionsSize = 15.0
        self.dropDown.placeholder = " Select Campaign"
        self.dropDown.optionsTextAlignment = NSTextAlignment.left
        self.dropDown.textAlignment = NSTextAlignment.left
        self.dropDown.options = self.arrCampaignTitle
        self.dropDown.hideOptionsWhenSelect = true
        self.dropDown.tableHeight = 90
        self.dropDown.rowHeight = 30
        self.dropDown.didSelect { (item, index) in
            self.viewTemplateList.isHidden = false
            self.btnSelectAll.isSelected = false
            self.arrSelectedTemplates = []
            var strCampId = ""
            let campId = self.arrUnAssignedCampaignId[index]
            if campId.count > 0 {
                strCampId = campId.componentsJoined(by: ",")
            }
            self.selectedCampaignId = "\(self.arrCampaignId[index])"
            self.getTemplateListData(campId : strCampId)
        }
    }
    
    func getUnImportedCampaignsData(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "parentCampainId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getUnImportCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                self.arrCampaignId = []
                self.arrCampaignTitle = []
                self.arrUnAssignedCampaignId = []
                self.viewTemplateList.isHidden = true
                if dictJsonData.count > 0 {
                    for obj in dictJsonData {
                        self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                        self.arrCampaignId.append(obj.value(forKey: "campaignId") as AnyObject)
                        self.arrUnAssignedCampaignId.append(obj.value(forKey: "unassingStepID") as AnyObject)
                    }
                }
                self.loadDropDown()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getTemplateListData(campId : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "unassingStepID":campId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getSelectedTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                self.arrTemplateId = []
                self.arrTemplateTitle = []
                if dictJsonData.count > 0 {
                    for obj in dictJsonData {
                        self.arrTemplateTitle.append(obj.value(forKey: "campaignStepTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "campaignStepId") as AnyObject)
                    }
                    self.viewTemplateList.isHidden = false
                }
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.viewTemplateList.isHidden = true
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func importTemplateAPI(selTemplates:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "parentCampaignId":campaignId,
                         "listCampaignId":self.selectedCampaignId,
                         "listTemplateIds":selTemplates]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "importCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateECTemplateDetails"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension ImportEmailTemplates : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell")
        
        cell?.textLabel?.text = self.arrTemplateTitle[indexPath.row]
        if arrSelectedTemplates.contains(self.arrTemplateId[indexPath.row] as! String){
            cell?.imageView?.image = #imageLiteral(resourceName: "check")
        }else{
            cell?.imageView?.image = #imageLiteral(resourceName: "uncheck")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrSelectedTemplates.contains(self.arrTemplateId[indexPath.row] as! String){
            if let index = self.arrSelectedTemplates.index(of: self.arrTemplateId[indexPath.row] as! String) {
                self.arrSelectedTemplates.remove(at: index)
            }
        }else{
            self.arrSelectedTemplates.append(self.arrTemplateId[indexPath.row] as! String)
        }
        self.tblList.reloadData()
    }
}
