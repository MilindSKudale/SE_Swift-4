//
//  VBDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 19/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import  JJFloatingActionButton

class VBDashboard: SliderVC {

    @IBOutlet var tblVB : UITableView!
    @IBOutlet var noDataView : UIView!
    let actionButton = JJFloatingActionButton()
    
    var arrTitle = [String]()
    var arrDescription = [String]()
    var arrCreatedDate = [String]()
    var arrVisionBoardId = [String]()
    var arrCategory = [String]()
    var arrVBImages = [String]()
    var arrVBData = [AnyObject]()
    var imagePath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vw = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        self.tblVB.tableFooterView = vw
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "Add", image: #imageLiteral(resourceName: "add_contact")) { item in
            
            let storyboard = UIStoryboard(name: "VB", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddVB")
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
        }
        actionButton.display(inViewController: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func actionEdit(_ sender : UIButton) {
        print("Edit VB")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateVB),
            name: NSNotification.Name(rawValue: "UpdateVB"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "VB", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditVB") as! EditVB
        vc.vbId = self.arrVisionBoardId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func actionDelete(_ sender : UIButton) {
        
        let alertVC = PMAlertController(title: "", description: "Do you want to delete this vision?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            let vbId = self.arrVisionBoardId[sender.tag]
            self.deleteVisionBoardApi(vbId)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func UpdateVB(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension VBDashboard : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVB.dequeueReusableCell(withIdentifier: "VBCell", for: indexPath) as! VBCell
        
        cell.imgView.image = nil
        let imgUrl = self.arrVBImages[indexPath.row]
        print(self.imagePath+imgUrl)
        if imgUrl != "" {
            OBJCOM.setImages(imageURL: self.imagePath+"\(userID)/"+imgUrl, imgView: cell.imgView)
        }else{
            cell.imgView.image = #imageLiteral(resourceName: "no_image")
        }
        cell.lblCategory.text = "\(self.arrCategory[indexPath.row])"
        cell.lblTitle.text = self.arrTitle[indexPath.row]
        cell.lblDescription.text = self.arrDescription[indexPath.row]
        cell.lblCreatedDate.text = self.arrCreatedDate[indexPath.row]
        
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        
        cell.btnEdit.addTarget(self, action: #selector(actionEdit(_ :)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(actionDelete(_ :)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "VB", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idVisionDetails") as! VisionDetails
        vc.vbId = self.arrVisionBoardId[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.present(vc, animated: true, completion: nil)
    }
}


extension VBDashboard {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllVisionBoard", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrTitle = []
            self.arrVisionBoardId = []
            self.arrCreatedDate = []
            self.arrCategory = []
            self.arrVBImages = []
            self.arrDescription = []
            self.arrVBData = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrVBData = JsonDict!["result"] as! [AnyObject]
                
                
                if self.arrVBData.count > 0 {
                    self.imagePath = self.arrVBData[0]["filePath"] as? String ?? ""
                    self.arrTitle = self.arrVBData.compactMap { $0["vboardTitle"] as? String }
                    self.arrDescription = self.arrVBData.compactMap { $0["vboardDescription"] as? String }
                    self.arrCreatedDate = self.arrVBData.compactMap { $0["vboardCreated"] as? String }
                    self.arrVisionBoardId = self.arrVBData.compactMap { $0["vboardId"] as? String }
                    self.arrCategory = self.arrVBData.compactMap { $0["vbCategory"] as? String ?? "" }
                    self.arrVBImages = self.arrVBData.compactMap { $0["vbAttachmentFile"] as? String ?? "" }
                }
//                if self.arrVBData.count > 0 {
//                    self.noDataView.isHidden = true
//                }else{
//                    self.noDataView.isHidden = false
//                }
                self.tblVB.reloadData()
                OBJCOM.hideLoader()
            }else{
               // self.noDataView.isHidden = false
                self.tblVB.reloadData()
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func deleteVisionBoardApi(_ visionBoardId : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "vboardId":visionBoardId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteVisionBoard", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: result as! String)
                OBJCOM.hideLoader()
            }
        };
    }
}


