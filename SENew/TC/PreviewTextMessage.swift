//
//  PreviewTextMessage.swift
//  SENew
//
//  Created by Milind Kudale on 14/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class PreviewTextMessage: UIViewController {

    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var lblTemplateTitle : UILabel!
    @IBOutlet var lblTemplateContents : UITextView!
    @IBOutlet var lblAttachFile : UILabel!
    @IBOutlet var lblAddedLink : UILabel!
    @IBOutlet var lblTimeInterval : UILabel!
    @IBOutlet var attachmentView : UIView!
    @IBOutlet var timeIntervalView : UIView!
   // @IBOutlet var attachmentViewHeight : NSLayoutConstraint!
    @IBOutlet var footerView : UIView!
    @IBOutlet var tempFooterLbl : UILabel!
    @IBOutlet var btnSave : UIButton!
    
    var templateId = ""
    var campaignId = ""
    var campaignName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblCampaignTitle.text = campaignName
        self.btnSave.isHidden = true
        self.attachmentView.isHidden = true
        self.timeIntervalView.isHidden = true

        let str = "Success Entellus respects your privacy. For more information, please review our privacy policy"
        let attributedString = NSMutableAttributedString(string: str)
        var foundRange = attributedString.mutableString.range(of: "Terms of use")
        foundRange = attributedString.mutableString.range(of: "privacy policy")
        attributedString.addAttribute(.link, value: "https://successentellus.com/home/privacyPolicy", range: foundRange)
        
        tempFooterLbl.attributedText = attributedString
        let tapAction = UITapGestureRecognizer(target: self, action:#selector(tapLabel(_:)))
        tempFooterLbl?.isUserInteractionEnabled = true
        tempFooterLbl?.addGestureRecognizer(tapAction)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTemplateDetails()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
    }
    
    @IBAction func tapLabel(_ gesture: UITapGestureRecognizer) {
        let text = (tempFooterLbl.text)!
        
        let privacyRange = (text as NSString).range(of: "privacy policy")
        
        if gesture.didTapAttributedTextInLabel(label: tempFooterLbl, inRange: privacyRange) {
            print("Tapped privacy")
            if let url = URL(string: "https://successentellus.com/home/privacyPolicy") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            print("Tapped none")
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss (animated: true, completion: nil)
    }
    
    @IBAction func actionEditTemplate(_ sender:UIButton) {
     
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idUpdateTextMessage") as! UpdateTextMessage
        vc.campaignId = self.campaignId
        vc.campaignName = self.campaignName
        vc.templateId = templateId
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
    }
    
}

extension PreviewTextMessage {
    func getTemplateDetails(){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTextMessageById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]       
                print(result)
            
                self.lblTemplateTitle.text = result["txtTemplateTitle"] as? String ?? ""
                
                let templateType = result["txtTemplateType"] as? String ?? "1"
                let isPredefine = result["txtTemplateFeature"] as? String ?? ""
                var html = result["txtTemplateMsg"] as? String ?? ""
                
                if isPredefine == "1" {
                    let dataHtml = Data(html.utf8)
                    if let attributedString = try? NSAttributedString(data: dataHtml, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                        self.lblTemplateContents.attributedText = attributedString
                    }
                    self.btnSave.isHidden = true
                   // self.attachmentView.isHidden = false
                }else{
                    self.btnSave.isHidden = false
                   // self.attachmentView.isHidden = true
                    if templateType == "2" {
                        html = html.replacingOccurrences(of: "\n", with: "<br>")
                        let data = html.data(using: String.Encoding.utf16)!
                        let attrStr = try? NSMutableAttributedString(
                            data: data,
                            options: [.documentType: NSAttributedString.DocumentType.html],
                            documentAttributes: nil)
                        attrStr!.beginEditing()
                        attrStr!.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, attrStr!.length), options: .init(rawValue: 0)) {
                            (value, range, stop) in
                            if let font = value as? UIFont {
                                let resizedFont = font.withSize(17.0)
                                attrStr!.addAttribute(NSAttributedString.Key.font, value: resizedFont, range: range)
                            }
                        }
                        attrStr!.endEditing()
                        self.lblTemplateContents.attributedText = attrStr
                    }else{
                        self.lblTemplateContents.text = html
                    }
                }
                
                var attachedFiles = [String]()
                let attachements = result["attachements"] as! [AnyObject]
                if attachements.count > 0 {
                    for file in attachements {
                        let filename = file["filePath"] as? String ?? ""
                        let arrFile = filename.components(separatedBy: "/")
                        attachedFiles.append(arrFile.last!)
                    }
                    self.lblAttachFile.text = attachedFiles.joined(separator: ", ")
                }else{
                    self.lblAttachFile.text = "No files attached yet!"
                }
                self.lblAddedLink.text = "No links added yet!"
                
                if templateType == "1" {
                    self.attachmentView.isHidden = true
                  //  self.attachmentViewHeight.constant = 60.0
                }else{
                    self.attachmentView.isHidden = false
                   // self.attachmentViewHeight.constant = 0.0
                }

                let isFooter = result["txtTemplateFooterFlag"] as? String ?? ""
                if isFooter == "1" {
                    self.footerView.isHidden = false
                }else{
                    self.footerView.isHidden = true
                }
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
}
