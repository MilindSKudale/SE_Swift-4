//
//  VisionDetails.swift
//  SENew
//
//  Created by Milind Kudale on 20/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class VisionDetails: UIViewController {

    var vbId = ""
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgVision : UIImageView!
    @IBOutlet var lblVisionTitle : UILabel!
    @IBOutlet var lblVisionDate : UILabel!
    @IBOutlet var lblVisionCategory : UILabel!
    @IBOutlet var lblVisionDescription : UILabel!
    @IBOutlet var lblVisionEmotion : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getVisionBoardById()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func assignDataToFields(_ data: AnyObject){
        lblVisionTitle.text = data["vboardTitle"] as? String ?? ""
        lblVisionDate.text = data["vboardTitle"] as? String ?? ""
        lblVisionCategory.text = data["vbCategory"] as? String ?? ""
        
        
    
        lblVisionDescription.text = "-"
        if data["vboardDescription"] as? String ?? "" != "" {
            lblVisionDescription.text = data["vboardDescription"] as? String ?? ""
        }
        
        lblVisionEmotion.text = "-"
        if data["vboardEmotion"] as? String ?? "" != "" {
            lblVisionEmotion.text = data["vboardEmotion"] as? String ?? ""
        }
        let imgUrlPath = data["filePath"] as? String ?? ""
        let arrimgUrl = data["vboardAttachment"] as! [AnyObject]
        if arrimgUrl.count > 0 {
            let imgUrl = arrimgUrl.last!
            let url = "\(imgUrlPath)\(userID)/\(imgUrl["vbAttachmentFile"] as? String ?? "")"
            OBJCOM.setImages(imageURL: url, imgView: self.imgVision)
        }
    }
    
    func getVisionBoardById(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "vboardId":vbId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getVisionBoardById", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                self.assignDataToFields(result)
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
}
