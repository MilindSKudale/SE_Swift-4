//
//  RenameEC.swift
//  SENew
//
//  Created by Milind Kudale on 10/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class RenameEC: UIViewController, UITextFieldDelegate {

    @IBOutlet var bgView : UIView!
    @IBOutlet var txtCampaign : UITextField!
    @IBOutlet var btnSave : UIButton!
    
    var campaignName = ""
    var campaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnSave.layer.cornerRadius = 5
        btnSave.clipsToBounds = true
        txtCampaign.clipsToBounds = true
        txtCampaign.text = campaignName
        txtCampaign.delegate = self
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender:UIButton) {
        if txtCampaign.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter campaign name to update campaign")
        }else{
            //updateCampaign
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.updateCampaign()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func updateCampaign(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId,
                         "campaignTitle":txtCampaign.text,
                         "campaignContent":""] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
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
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtCampaign {
            if txtCampaign.text == "" {
                self.txtCampaign.text = self.campaignName
            }else{
                self.campaignName = txtCampaign.text ?? ""
            }
        }
    }

}
