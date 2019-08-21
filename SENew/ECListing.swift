//
//  ECListing.swift
//  SENew
//
//  Created by Milind Kudale on 10/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet
import JJFloatingActionButton

class ECListing: SliderVC {

    var searchBar : DAOSearchBar!
    var txtSearch = UITextField()
    @IBOutlet var searchView : UIView!
    @IBOutlet var tblList : UITableView!
    
    var arrCampaignTitle = [String]()
    var arrCampaignId = [String]()
    var arrCampaignImage = [String]()
    var arrCampaignColor = [AnyObject]()
    var arrCampaignStepContent = [String]()
    var arrTemplateCount = [String]()
    
    var arrCampaignTitleSearch = [String]()
    var arrCampaignIdSearch = [String]()
    var arrCampaignImageSearch = [String]()
    var arrCampaignColorSearch = [AnyObject]()
    var arrCampaignStepContentSearch = [String]()
    var arrTemplateCountSearch = [String]()
    
    var isFilter = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vw = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        self.setupSearchBars()
        tblList.tableFooterView = vw
        isFilter = false;
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "add_contact")) { item in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateECList),
                name: NSNotification.Name(rawValue: "UpdateECList"),
                object: nil)
            let storyboard = UIStoryboard(name: "EC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idCreateEC") as! CreateEC
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .custom
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
            self.present(vc, animated: true, completion: nil)
        }
        actionButton.display(inViewController: self)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    @objc func UpdateECList(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func setupSearchBars() {
        self.searchBar = DAOSearchBar.init(frame:CGRect(x: self.searchView.frame.width - 50.0, y: 2.5, width: 40.0, height: 30))
        self.searchBar.delegate = self
        self.txtSearch = searchBar.searchField
        self.txtSearch.delegate = self
        self.searchView.addSubview(searchBar)
    }
    
    @IBAction func actionMoreOption(_ sender:AnyObject){
        
        let item1 = ActionSheetItem(title: "Help", value: 1)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    let storyboard = UIStoryboard(name: "EC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idECHelpView") as! ECHelpView
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationStyle = .custom
                    vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
}

extension ECListing : DAOSearchBarDelegate, UITextFieldDelegate {
    func destinationFrameForSearchBar(_ searchBar: DAOSearchBar) -> CGRect {
        return CGRect(x: 10.0, y: 2.5, width: self.searchView.frame.width - 20.0, height: 30)
    }
    
    func searchBar(_ searchBar: DAOSearchBar, willStartTransitioningToState destinationState: DAOSearchBarState) {
        
    }
    
    func searchBar(_ searchBar: DAOSearchBar, didEndTransitioningFromState previousState: DAOSearchBarState) {
        
    }
    
    func searchBarDidTapReturn(_ searchBar: DAOSearchBar) {
        
    }
    
    func searchBarTextDidChange(_ searchBar: DAOSearchBar) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        self.arrCampaignTitleSearch.removeAll()
        self.arrCampaignIdSearch.removeAll()
        self.arrCampaignImageSearch.removeAll()
        self.arrTemplateCountSearch.removeAll()
        self.arrCampaignColorSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrCampaignTitle.count {
                let fName = arrCampaignTitle[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                if fName != nil  {
                    arrCampaignTitleSearch.append(arrCampaignTitle[i])
                    arrCampaignIdSearch.append(arrCampaignId[i])
                    arrCampaignImageSearch.append(arrCampaignImage[i])
                    arrTemplateCountSearch.append(arrTemplateCount[i])
                    arrCampaignColorSearch.append(arrCampaignColor[i])
                }
            }
        } else {
            isFilter = false
        }
        tblList.reloadData()
    }
}

extension ECListing : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return arrCampaignTitleSearch.count
        }
        return arrCampaignTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! ECCell
        if indexPath.row%2 == 0 {
            cell.backgroundColor = UIColor.groupTableViewBackground
        }else{
            cell.backgroundColor = UIColor.white
        }
        cell.imgbgView.backgroundColor = .white
        if isFilter {
            let colorObj = self.arrCampaignColorSearch[indexPath.row]
            if colorObj.count > 0 {
                let red: CGFloat = colorObj.object(at: 0) as! CGFloat
                let green: CGFloat = colorObj.object(at: 1) as! CGFloat
                let blue: CGFloat = colorObj.object(at: 2) as! CGFloat
                cell.imgbgView.backgroundColor = UIColor.rgb(red: red, green: green, blue: blue)
            }
            
            cell.title.text = self.arrCampaignTitleSearch[indexPath.row]
            let url = self.arrCampaignImageSearch[indexPath.row]
            OBJCOM.setImages(imageURL: url, imgView: cell.img)
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(actionMore(_:)), for: .touchUpInside)
        }else{
            let colorObj = self.arrCampaignColor[indexPath.row]
            if colorObj.count > 0 {
                let red: CGFloat = colorObj.object(at: 0) as! CGFloat
                let green: CGFloat = colorObj.object(at: 1) as! CGFloat
                let blue: CGFloat = colorObj.object(at: 2) as! CGFloat
                cell.imgbgView.backgroundColor = UIColor.rgb(red: red, green: green, blue: blue)
            }
            
            cell.title.text = self.arrCampaignTitle[indexPath.row]
            let url = self.arrCampaignImage[indexPath.row]
            OBJCOM.setImages(imageURL: url, imgView: cell.img)
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(actionMore(_:)), for: .touchUpInside)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var camId = ""
        var camTitle = ""
        if isFilter {
            camId = self.arrCampaignIdSearch[indexPath.row]
            camTitle = self.arrCampaignTitleSearch[indexPath.row]
        }else{
            camId = self.arrCampaignId[indexPath.row]
            camTitle = self.arrCampaignTitle[indexPath.row]
        }
        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idECTemplateView") as! ECTemplateView
        vc.campaignId = camId
        vc.campaignName = camTitle
        
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .crossDissolve
        //vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}

extension ECListing {
    func getEmailCampaignData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                self.arrCampaignImage = []
                self.arrTemplateCount = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "campaignId") as! String)
                    self.arrCampaignImage.append(obj.value(forKey: "campaignImage") as! String)
                    self.arrTemplateCount.append("\(obj.value(forKey: "stepPresent") ?? "")")
                    self.arrCampaignColor.append(obj.value(forKey: "campaignColor") as AnyObject)
                }
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @objc func actionMore(_ sender:UIButton){
        var camId = ""
        var camTitle = ""
        if isFilter {
            camId = self.arrCampaignIdSearch[sender.tag]
            camTitle = self.arrCampaignTitleSearch[sender.tag]
        }else{
            camId = self.arrCampaignId[sender.tag]
            camTitle = self.arrCampaignTitle[sender.tag]
        }
        
        let item1 = ActionSheetItem(title: "Rename Campaign", value: 1)
        let item2 = ActionSheetItem(title: "Delete Campaign", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                    
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.UpdateECList),
                        name: NSNotification.Name(rawValue: "UpdateECList"),
                        object: nil)

                    let storyboard = UIStoryboard(name: "EC", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idRenameEC") as! RenameEC
                    vc.campaignName = camTitle
                    vc.campaignId = camId
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .coverVertical
                    vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.present(vc, animated: false, completion: nil)
                }else if item == item2 {
                    
                    let alertVC = PMAlertController(title: "", description: "Are you sure, you want to delete '\(camTitle)' campaign?", image: nil, style: .alert)
                    alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
                    }))
                    alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                        self.deleteCampaignAPICall(campId:camId)
                    }))
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    func deleteCampaignAPICall(campId:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campIdToDelete":campId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getEmailCampaignData()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
