//
//  CreateEC.swift
//  SENew
//
//  Created by Milind Kudale on 12/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class CreateEC: UIViewController {

    @IBOutlet var bgView : UIView!
    @IBOutlet var btnAdd : UIButton!
    @IBOutlet var txtCampaignName : UITextField!
    @IBOutlet var btnPredefine : UIButton!
    @IBOutlet var btnCustom : UIButton!
    @IBOutlet var btnBoth : UIButton!
    @IBOutlet var btnNoneOfThem : UIButton!
    @IBOutlet var stackView : UIStackView!
    @IBOutlet var DDSelectCampaign : UIDropDown!
    @IBOutlet var viewTemp : UIView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet var noTemplateView : UIView!
    
    var arrCampaignTitle = [String]()
    var arrCampaignID = [String]()
    var arrTemplateTitle = [String]()
    var arrTemplateID = [String]()
    var arrSelectedTemplate = [String]()
    var campaignTitle = " "
    var campaignId = ""
    var isCompanyCampaign = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.layer.cornerRadius = 10
        btnAdd.layer.cornerRadius = 5
        
        bgView.clipsToBounds = true
        btnAdd.clipsToBounds = true
        self.updateRadioButton(btnNoneOfThem)
        self.DDSelectCampaign.isHidden = true
        self.viewTemp.isHidden = true
        self.isCompanyCampaign = false
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddEC(_ sender:UIButton) {
        if isValidation() == true {
            if self.btnNoneOfThem.isSelected == false && self.arrSelectedTemplate.count > 0 {
                let campStepId = self.arrSelectedTemplate.joined(separator: ",")
                print(campStepId)
                addCampaignAPI(campStepId: campStepId)
            }else if self.btnNoneOfThem.isSelected == true {
                addCampaignAPI(campStepId: "")
            }else{
                OBJCOM.setAlert(_title: "", message: "Please select atleast one template from list.")
                return
            }
        }
    }
    
    @IBAction func actionSetPredefine(_ sender:UIButton) {
        self.updateRadioButton(sender)
        self.DDSelectCampaign.isHidden = false
        self.viewTemp.isHidden = true
        self.DDSelectCampaign.resignFirstResponder()
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "companyCampaign":"1"]
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getCampaignData(dictParam : dictParam, action:"getCampaign")
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    @IBAction func actionSetCustom(_ sender:UIButton) {
        self.updateRadioButton(sender)
        self.DDSelectCampaign.isHidden = false
        self.viewTemp.isHidden = true
        self.DDSelectCampaign.resignFirstResponder()
        let dictParam = ["userId": userID,
                         "platform":"3"]
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getCampaignData(dictParam : dictParam, action:"getCampaign")
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    @IBAction func actionSetBoth(_ sender:UIButton) {
        self.updateRadioButton(sender)
        self.DDSelectCampaign.isHidden = false
        self.viewTemp.isHidden = true
        self.DDSelectCampaign.resignFirstResponder()
        let dictParam = ["userId": userID,
                         "platform":"3"]
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getCampaignData(dictParam : dictParam, action:"getAllCampaign")
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionSetNone(_ sender:UIButton) {
        self.updateRadioButton(sender)
        self.viewTemp.isHidden = true
        self.arrSelectedTemplate = []
        self.DDSelectCampaign.resignFirstResponder()
        
        if self.DDSelectCampaign.isSelected {
            self.DDSelectCampaign.hideTable()
        }
        self.DDSelectCampaign.isHidden = true
    }
    
    func updateRadioButton(_ sender:UIButton) {
        self.btnPredefine.isSelected = false
        self.btnCustom.isSelected = false
        self.btnBoth.isSelected = false
        self.btnNoneOfThem.isSelected = false
        sender.isSelected = true
    }
}

extension CreateEC {
    func getCampaignData(dictParam : [String:String], action:String) {
       
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignID.append(obj.value(forKey: "campaignId") as! String)
                }
                if self.DDSelectCampaign.isSelected {
                    self.DDSelectCampaign.hideTable()
                }
                self.loadDropDown()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func loadDropDown() {
        self.DDSelectCampaign.textColor = .black
        self.DDSelectCampaign.tint = APPBLUECOLOR
        self.DDSelectCampaign.optionsSize = 15.0
        self.DDSelectCampaign.tableHeight = 170.0
        self.DDSelectCampaign.rowHeight = 30.0
        self.DDSelectCampaign.placeholder = " Select Email Campaign"
        self.DDSelectCampaign.optionsTextAlignment = NSTextAlignment.left
        self.DDSelectCampaign.textAlignment = NSTextAlignment.left
        self.DDSelectCampaign.options = self.arrCampaignTitle
        self.DDSelectCampaign.hideOptionsWhenSelect = true
        campaignTitle = ""
        self.DDSelectCampaign.didSelect { (item, index) in
            self.campaignTitle = self.arrCampaignTitle[index]
            self.campaignId = self.arrCampaignID[index]
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.viewTemp.isHidden = true
                    if self.isCompanyCampaign == true {
                        self.getTemplateData(campaignId:self.campaignId, action: "getCampaignEmailTemplate")
                    }else{
                        self.getTemplateData(campaignId:self.campaignId, action: "getCampaignEmailWithoutSelfTemplate")
                    }
                }
            }else{
                self.viewTemp.isHidden = true
                OBJCOM.NoInternetConnectionCall()
            }
        }
        
        self.arrTemplateTitle = []
        self.arrTemplateID = []
        self.tblList.reloadData()
    }
    
    func getTemplateData(campaignId : String, action:String) {
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]//
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrTemplateTitle = []
                self.arrTemplateID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                self.viewTemp.isHidden = false
                for obj in dictJsonData {
                    self.arrTemplateTitle.append(obj.value(forKey: "campaignStepTitle") as! String)
                    self.arrTemplateID.append(obj.value(forKey: "campaignStepId") as! String)
                }
                OBJCOM.hideLoader()
            }else{
                self.viewTemp.isHidden = false
                self.arrTemplateTitle = []
                self.arrTemplateID = []
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
            
        };
    }
    
    func addCampaignAPI(campStepId:String) {
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignTitle":self.txtCampaignName.text!,
                         "campaignSteps":campStepId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateECList"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func isValidation() -> Bool{
        var isValid = true
        if txtCampaignName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter campaign name.")
            isValid = false
        }else if btnNoneOfThem.isSelected == false && self.campaignTitle == " Select Email Campaign" {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one campaign from drop down.")
            isValid = false
        }else{
            isValid = true
        }
        
        return isValid
    }
}

extension CreateEC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = self.arrTemplateTitle[indexPath.row]
        if arrSelectedTemplate.contains(arrTemplateID[indexPath.row]){
            cell?.imageView?.image = #imageLiteral(resourceName: "check")
        }else{
            cell?.imageView?.image = #imageLiteral(resourceName: "uncheck")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrSelectedTemplate.contains(arrTemplateID[indexPath.row]){
            if let index = arrSelectedTemplate.index(of: arrTemplateID[indexPath.row]) {
                arrSelectedTemplate.remove(at: index)
            }
        }else{
            arrSelectedTemplate.append(arrTemplateID[indexPath.row])
        }
        self.tblList.reloadData()
    }
    
    @IBAction func actionSelectAll(_ sender:UIButton){
        if !sender.isSelected {
            sender.isSelected = true
            for template in self.arrTemplateID {
                self.arrSelectedTemplate.append(template)
            }
        }else{
            self.arrSelectedTemplate.removeAll()
            sender.isSelected = false
        }
        self.tblList.reloadData()
    }
}
