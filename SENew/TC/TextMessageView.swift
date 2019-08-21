//
//  TextMessageDetailsView.swift
//  SENew
//
//  Created by Milind Kudale on 13/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class TextMessageView: UIViewController {

    var txtCampName = ""
    var txtCampId = ""
    var isPredefineCampaign = "0"
    
    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var btnCreateTemplate: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noDataView: UIView!
    
    var centerFlowLayout: SJCenterFlowLayout {
        return collectionView.collectionViewLayout as! SJCenterFlowLayout
    }
    var scrollToEdgeEnabled: Bool = true
    
    var arrTemplateTitle = [String]()
    var arrTemplateId = [String]()
    var arrTemplateImages = [String]()
    var arrTemplateEmailReminder = [String]()
    var arrInterval = [String]()
    var arrIntervalType = [String]()
    var arrTemplates = [AnyObject]()
    var arrIsPredefine = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCampaignTitle.text = txtCampName
        centerFlowLayout.itemSize = CGSize(
            width: collectionView.frame.width-40,
            height:  collectionView.frame.height
        )
        
        centerFlowLayout.animationMode = SJCenterFlowLayoutAnimation.scale(sideItemScale: 0.6, sideItemAlpha: 0.6, sideItemShift: 0.0)
        centerFlowLayout.scrollDirection = .horizontal
        centerFlowLayout.spacingMode = SJCenterFlowLayoutSpacingMode.overlap(visibleOffset: 30.0)
        
        btnCreateTemplate.centerVertically()
        btnCreateTemplate.isHidden = false
        if isPredefineCampaign == "1" {
            btnCreateTemplate.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignTemplate(campaignID:self.txtCampId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateTCTemplateDetails(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignTemplate(campaignID:self.txtCampId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TextMessageView:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrTemplateTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryColCell
        
        cell.lblTitle.text = self.arrTemplateTitle[indexPath.row]
        let imageURL = self.arrTemplateImages[indexPath.row]
        if imageURL != "" {
            OBJCOM.setImages(imageURL: imageURL, imgView: cell.imgTemplate)
        }else{
            cell.imgTemplate.image = #imageLiteral(resourceName: "txtMessageBg")
        }
        
        let timeInterval = self.arrInterval[indexPath.row]
        let timeIntervalType = self.arrIntervalType[indexPath.row]
        cell.btnTimeInterval.setTitle("Time Interval (\(timeInterval) \(timeIntervalType))", for: .normal)
        
        cell.btnScheduleDetails.tag = indexPath.row
        cell.btnTimeInterval.tag = indexPath.row
        cell.previewTemplate.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        
        cell.btnEdit.isHidden = false
        cell.btnDelete.isHidden = false
        if isPredefineCampaign == "1" {
            cell.btnEdit.isHidden = true
            cell.btnDelete.isHidden = true
        }
        
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

extension TextMessageView {
    func getTextCampaignTemplate(campaignID:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":txtCampId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaignTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrTemplateTitle = []
            self.arrTemplateId = []
            self.arrInterval = []
            self.arrIntervalType = []
            self.arrTemplates = []
            self.arrIsPredefine = []
            self.arrTemplateImages = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                if dictJsonData.count > 0 {
                    for obj in dictJsonData {
                        self.arrTemplateTitle.append(obj.value(forKey: "txtTemplateTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "txtTemplateId") as! String)
                        self.arrInterval.append(obj.value(forKey: "txtTemplateInterval") as! String)
                        self.arrIntervalType.append(obj.value(forKey: "txtTemplateIntervalType") as! String)
                        self.arrIsPredefine.append(obj.value(forKey: "txtTemplateFeature") as! String)
                        self.arrTemplateImages.append (obj.value(forKey:"txtTemplateImage") as! String)
                        self.arrTemplates.append(obj)
                    }
                    self.noDataView.isHidden = true
                }
                self.collectionView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noDataView.isHidden = false
                self.collectionView.reloadData()
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension TextMessageView {
    @IBAction func actionAddMembers(_ sender : UIButton){
    
        if arrTemplateTitle.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please add template before adding members.")
            return
        }
        
        let item1 = ActionSheetItem(title: "Add Member Manually", value: 1)
        let item2 = ActionSheetItem(title: "Add Members From System Contacts", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateTCTemplateDetails),
                        name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "TC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idAddMemberManually") as! AddMemberManually
                    vc.txtCampName = self.txtCampName
                    vc.txtCampId = self.txtCampId
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }else if item == item2 {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateTCTemplateDetails),
                        name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
                        object: nil)
                    let storyboard = UIStoryboard(name: "TC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idAddMembersFromSysContacts") as! AddMembersFromSysContacts
                    vc.txtCampName = self.txtCampName
                    vc.txtCampId = self.txtCampId
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionAssignedMembersDetails(_ sender : UIButton){
        
        if arrTemplateTitle.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please add template before to unassigned members.")
            return
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAssignedTCMembersDetails") as! AssignedTCMembersDetails
        vc.txtCampName = self.txtCampName
        vc.txtCampId = self.txtCampId
        vc.txtMessgageId = self.arrTemplateId[sender.tag]
        
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionStartCampaign(_ sender : UIButton){
        if arrTemplateTitle.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please add template before to start campaigns.")
            return
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTCStartCampaign") as! TCStartCampaign
        vc.txtCampName = self.txtCampName
        vc.txtCampId = self.txtCampId
        vc.txtMessgageId = self.arrTemplateId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    //
    @objc func actionTimeInterval(_ sender : UIButton){
        if isPredefineCampaign == "1" {
            return
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTCSetTimeInterval") as! TCSetTimeInterval
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.templateTitle = self.arrTemplateTitle[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func actionScheduleDetails(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTCScheduleDetails") as! TCScheduleDetails
        vc.campaignId = self.txtCampId
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.templateName = self.arrTemplateTitle[sender.tag]
        vc.isRepeateTemplate = self.arrInterval[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func actionEditTemplate(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)

        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idUpdateTextMessage") as! UpdateTextMessage
        vc.campaignId = self.txtCampId
        vc.campaignName = self.txtCampName
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
        
    }
    
    @objc func actionDeleteTemplate(_ sender : UIButton){
        
        let alertVC = PMAlertController(title: "", description: "https://www.successentellus.com says\n Are you sure want to delete this email template?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.deleteCampaign(sender.tag)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func actionTemplatePreview(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPreviewTextMessage") as! PreviewTextMessage
        vc.campaignId = self.txtCampId
        vc.campaignName = self.txtCampName
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionCreateMessage(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTCTemplateDetails),
            name: NSNotification.Name(rawValue: "UpdateTCTemplateDetails"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idCreateTextMessage") as! CreateTextMessage
        vc.campaignId = self.txtCampId
        vc.campaignName = self.txtCampName
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
//        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    func deleteCampaign (_ index:Int) {
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":self.arrTemplateId[index]] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    DispatchQueue.main.async {
                        self.getTextCampaignTemplate(campaignID:self.txtCampId)
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
}
