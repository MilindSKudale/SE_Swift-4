//
//  ECTemplateView.swift
//  SENew
//
//  Created by Milind Kudale on 10/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class ECTemplateView: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    var centerFlowLayout: SJCenterFlowLayout {
        return collectionView.collectionViewLayout as! SJCenterFlowLayout
    }
    var scrollToEdgeEnabled: Bool = true
    @IBOutlet var lblCampName:UILabel!
    @IBOutlet var btnCreateTemplate: UIButton!
    @IBOutlet var btnImportTemplate: UIButton!
    @IBOutlet var btnSetSelfReminder: UIButton!
    @IBOutlet var noDataView: UIView!
    
    var arrTemplateTitle = [String]()
    var arrTemplateId = [String]()
    var arrTemplateImages = [String]()
    var arrTemplateEmailReminder = [String]()
    var arrInterval = [String]()
    var arrIntervalType = [String]()
//    var arrCampiagnDate = [String]()
    
    var arrAttachments = [AnyObject]()
    var arrTemplates = [AnyObject]()
    var arrCampaignStepSendTo = [AnyObject]()
    var arrBgColor = [AnyObject]()

    var campaignName = ""
    var campaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblCampName.text = campaignName
        centerFlowLayout.itemSize = CGSize(
            width: collectionView.frame.width-40,
            height:  collectionView.frame.height
        )

        centerFlowLayout.animationMode = SJCenterFlowLayoutAnimation.scale(sideItemScale: 0.6, sideItemAlpha: 0.6, sideItemShift: 0.0)
        centerFlowLayout.scrollDirection = .horizontal
        centerFlowLayout.spacingMode = SJCenterFlowLayoutSpacingMode.overlap(visibleOffset: 30.0)
        
        btnCreateTemplate.centerVertically()
        btnImportTemplate.centerVertically()
        btnSetSelfReminder.centerVertically()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailCampaignTemplate (campaignID:self.campaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateECTemplateDetails(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailCampaignTemplate (campaignID:self.campaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ECTemplateView:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrTemplateTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryColCell
        
        cell.lblTitle.text = self.arrTemplateTitle[indexPath.row]
        let imageURL = self.arrTemplateImages[indexPath.row]
        OBJCOM.setImages(imageURL: imageURL, imgView: cell.imgTemplate)
        
        //cell.viewTemplate.shadow()
        cell.btnScheduleDetails.isHidden = false
        let isSetReminder = self.arrTemplateEmailReminder[indexPath.row]
        if isSetReminder == "1" {
            cell.btnScheduleDetails.isHidden = true
            //cell.viewTemplate.removeShadow()
        }
        
        let timeInterval = self.arrInterval[indexPath.row]
        let timeIntervalType = self.arrIntervalType[indexPath.row]
        cell.btnTimeInterval.setTitle("Time Interval (\(timeInterval) \(timeIntervalType))", for: .normal)
        
        cell.btnScheduleDetails.tag = indexPath.row
        cell.btnTimeInterval.tag = indexPath.row
        cell.previewTemplate.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        
        cell.btnScheduleDetails.addTarget(self, action: #selector(actionScheduleDetails(_:)), for: .touchUpInside)
        cell.btnTimeInterval.addTarget(self, action: #selector(actionTimeInterval(_:)), for: .touchUpInside)
        cell.previewTemplate.addTarget(self, action: #selector(actionTemplatePreview(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(actionEditTemplate(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(actionDeleteTemplate(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.scrollToEdgeEnabled, let cIndexPath = centerFlowLayout.currentCenteredIndexPath,
            cIndexPath != indexPath {
            centerFlowLayout.scrollToPage(atIndex: indexPath.row)
        }
    }
}

extension ECTemplateView {
    func getEmailCampaignTemplate(campaignID:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignID]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaignEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                if dictJsonData.count > 0 {
                    self.arrTemplateTitle = []
                    self.arrTemplateId = []
//                    self.arrCampaignId = []
                    self.arrInterval = []
                    self.arrIntervalType = []
//                    self.arrCampaignStepSubject = []
//                    self.arrCampaignHTMLContent = []
                    self.arrTemplateEmailReminder = []
                    self.arrTemplateImages = []
                    self.arrAttachments = []
                    self.arrTemplates = []
                    self.arrBgColor = []
                   // self.arrCampiagnDate = []
                    self.arrCampaignStepSendTo = []
                    
                    for obj in dictJsonData {
                        self.arrTemplateTitle.append(obj.value(forKey: "campaignStepTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "campaignStepId") as! String)
//                        self.arrCampaignId.append(obj.value(forKey: "campaignStepCamId") as! String)
                        self.arrInterval.append(obj.value(forKey: "campaignStepSendInterval") as! String)
                        self.arrIntervalType.append(obj.value(forKey: "campaignStepSendIntervalType") as! String)
//                        self.arrCampaignStepSubject.append(obj.value(forKey: "campaignStepSubject") as! String)
//                        self.arrCampaignHTMLContent.append(obj.value(forKey: "campaignStepContent") as! String)
                        self.arrTemplateEmailReminder.append(obj.value(forKey: "campiagnEndStepEmailReminder") as! String)
                        self.arrTemplateImages.append(obj.value(forKey: "stepImage") as! String)
                        self.arrAttachments.append(obj.value(forKey: "attachements") as AnyObject)
                        self.arrBgColor.append(obj.value(forKey: "attachements") as AnyObject)
                       // self.arrCampiagnDate.append("\(obj.value(forKey: "datecamp") ?? "")")
                        self.arrCampaignStepSendTo.append(obj.value(forKey: "campaignStepSendTo") as AnyObject)
                        
                        self.arrTemplates.append(obj)
                    }
                    self.noDataView.isHidden = true
                }
                self.collectionView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noDataView.isHidden = false
                OBJCOM.hideLoader()
            }
        };
    }
}

extension ECTemplateView {
    
    @IBAction func actionCreateTemplate(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateECTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTemplateSelectionView") as! TemplateSelectionView
        vc.campaignId = self.campaignId
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionImportTemplate(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateECTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idImportEmailTemplates") as! ImportEmailTemplates
        vc.campaignId = self.campaignId
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionSetASelfReminder(_ sender : UIButton){
        if arrTemplateTitle.count > 0 {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateECTemplateDetails),
                name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
                object: nil)
            let storyboard = UIStoryboard(name: "EC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idSetSelfReminder") as! SetSelfReminder
            vc.campaignId = self.campaignId
            vc.isUpdate = false
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please add template before self reminder.")
        }
        
    }
    
    @IBAction func actionAddEmails(_ sender : UIButton){
        if arrTemplateTitle.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please add template before adding emails.")
            return
        }
        let item1 = ActionSheetItem(title: "Add Manually", value: 1)
        let item2 = ActionSheetItem(title: "Add From System Contacts", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateECTemplateDetails),
                        name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "EC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idAddEmailsManually") as! AddEmailsManually
                    vc.campaignName = self.campaignName
                    vc.campaignId = self.campaignId
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }else if item == item2 {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateECTemplateDetails),
                        name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "EC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idAddEmailsFromSystemContacts") as! AddEmailsFromSystemContacts
                    vc.campaignName = self.campaignName
                    vc.campaignId = self.campaignId
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionUnassignEmails(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateECTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAssignedMemberDetails") as! AssignedMemberDetails
        vc.campaignName = self.campaignName
        vc.campaignId = self.campaignId
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func actionTemplatePreview(_ sender : UIButton){
        let isSelfReminder = self.arrTemplateEmailReminder[sender.tag]
        if isSelfReminder == "1" {
            let storyboard = UIStoryboard(name: "EC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idSelfReminderPreview") as! SelfReminderPreview
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "EC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idECTemplatePreview") as! ECTemplatePreview
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.campaignId = self.campaignId
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @objc func actionScheduleDetails(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateECTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idScheduleEmailDetails") as! ScheduleEmailDetails
        vc.campaignId = self.campaignId
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.templateName = self.arrTemplateTitle[sender.tag]
        vc.isRepeateTemplate = self.arrInterval[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func actionTimeInterval(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateECTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idSetTimeInterval") as! SetTimeInterval
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.templateTitle = self.arrTemplateTitle[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func actionEditTemplate(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateECTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateECTemplateDetails"),
            object: nil)
        let isSelfReminder = self.arrTemplateEmailReminder[sender.tag]
        if isSelfReminder == "1" {
            let storyboard = UIStoryboard(name: "EC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idSetSelfReminder") as! SetSelfReminder
            vc.campaignId = self.campaignId
            vc.isUpdate = true
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.present(vc, animated: false, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "EC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditECTemplate") as! EditECTemplate
            vc.campaignId = self.campaignId
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .coverVertical
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @objc func actionDeleteTemplate(_ sender : UIButton){
        let isSelfReminder = self.arrTemplateEmailReminder[sender.tag]
        var message = ""
        if isSelfReminder == "1" {
            message = "https://www.successentellus.com says\n Are you sure want to delete this self reminder?"
        }else{
            message = "https://www.successentellus.com says\n Are you sure want to delete this email template?"
        }
        
        let alertVC = PMAlertController(title: "", description: message, image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.deleteSelectedTemplate(strCampaignId: self.campaignId, strTemplateId: self.arrTemplateId[sender.tag])
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func deleteSelectedTemplate(strCampaignId : String, strTemplateId : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepCamId":strCampaignId,
                         "campaignStepId":strTemplateId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getEmailCampaignTemplate (campaignID:self.campaignId)
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
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

extension ECTemplateView {
}


class CategoryColCell: UICollectionViewCell {
    @IBOutlet var btnTimeInterval: UIButton!
    @IBOutlet var btnScheduleDetails: UIButton!
    @IBOutlet var viewTemplate: UIView!
    @IBOutlet var imgTemplate: UIImageView!
    @IBOutlet var previewTemplate: UIButton!
    @IBOutlet var viewFooter: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var btnDelete: UIButton!
}


