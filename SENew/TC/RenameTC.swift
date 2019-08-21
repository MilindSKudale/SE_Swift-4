//
//  RenameTC.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class RenameTC: UIViewController {

    @IBOutlet var txtCampaignName : UITextField!
    @IBOutlet var btnAdd : UIButton!
    
    var txtCampId = ""
    var txtCampName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAdd.clipsToBounds = true
        self.txtCampaignName.text = txtCampName
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender:UIButton) {
        if txtCampaignName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter text campaign name.")
            return
        }
        OBJCOM.setLoader()
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtCampId":txtCampId,
                         "campaignTitle":txtCampaignName.text!,
                         "txtCampDescription":""] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateTCList"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
}
