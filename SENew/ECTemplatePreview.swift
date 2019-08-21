//
//  ECTemplatePreview.swift
//  SENew
//
//  Created by Milind Kudale on 12/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ECTemplatePreview: UIViewController {
    
    @IBOutlet var lblEmailSubject : UILabel!
    @IBOutlet var lblEmailHeading : UILabel!
    @IBOutlet var lblEmailContents : UITextView!
    @IBOutlet var lblAttacheFiles : UILabel!
    @IBOutlet var footerView : UIView!
    @IBOutlet var tempFooterLbl : UILabel!

    var templateId = ""
    var campaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditECTemplate") as! EditECTemplate
        vc.campaignId = self.campaignId
        vc.templateId = self.templateId
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
    }
}

extension ECTemplatePreview {
    func getTemplateDetails(){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "stepId":templateId] as [String : Any]
        
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
                
                print(result)
                self.lblEmailSubject.text = result["campaignStepSubject"] as? String ?? ""
                self.lblEmailHeading.text = result["campaignStepTitle"] as? String ?? ""
                
                let htmlstr = result["campaignStepContent"] as? String ?? ""
               
                let html = "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(15.0)\">\(htmlstr)</span>"
                let dt = html.data(using: .utf8)!
                let att = try! NSAttributedString.init(
                    data: dt, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html],
                    documentAttributes: nil)
                let matt = NSMutableAttributedString(attributedString:att)
                
                self.lblEmailContents.attributedText = matt
                var attachedFiles = [String]()
                let attachements = result["attachements"] as! [AnyObject]
                if attachements.count > 0 {
                    for file in attachements {
                        let filename = file["fileName"] as? String ?? ""
                        attachedFiles.append(filename)
                    }
                    self.lblAttacheFiles.text = attachedFiles.joined(separator: ", ")
                }else{
                    self.lblAttacheFiles.text = "No files attached yet!"
                }
                
                let isFooter = result["campaignStepFooterFlag"] as? String ?? ""
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

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        //
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
