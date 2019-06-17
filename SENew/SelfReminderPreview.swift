//
//  SelfReminderPreview.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class SelfReminderPreview: UIViewController {

    @IBOutlet var lblEmailSubject : UILabel!
    @IBOutlet var lblEmailHeading : UILabel!
    @IBOutlet var lblEmailContent : GrowingTextView!
    
    var templateId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.designUI()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func designUI(){
        
        // let templateId = templateData["txtTemplateId"] as? String ?? ""
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "stepId":self.templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getEmailTemplateById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]
                self.lblEmailSubject.text = result["campaignStepSubject"] as? String ?? ""
                self.lblEmailHeading.text = result["campaignStepTitle"] as? String ?? ""
                self.lblEmailContent.text = result["campaignStepContent"] as? String ?? ""
             
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }

    
}
