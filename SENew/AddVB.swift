//
//  AddVB.swift
//  SENew
//
//  Created by Milind Kudale on 19/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet
import Alamofire
import SwiftyJSON

let time = OBJCOM.dateToString(dt:Date())

class AddVB: UIViewController {
    
    @IBOutlet var imgVision : UIImageView!
    @IBOutlet var txtVisionTitle : UITextField!
    @IBOutlet var txtDescription : GrowingTextView!
    @IBOutlet var txtEmotion : GrowingTextView!
    @IBOutlet var btnDeleteImage : UIButton!
    
    var vCategory = ""
    var arrVBCategoryTitle = [String]()
    var arrVBCategoryId = [String]()
    let picker = UIImagePickerController()
    var isImgPresent = false

    override func viewDidLoad() {
        super.viewDidLoad()

        vCategory = ""
        btnDeleteImage.isHidden = true
        isImgPresent = false
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getVisionBoardCategory()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.deleteUnwantedVisionAttachmentWhileCancel()
        }
    }
    
    @IBAction func actionUploadImage(_ sender: UIButton) {
        
        if self.isImgPresent == true {
            OBJCOM.setAlert(_title: "", message: "Please remove previously added vision image.")
            return
        }
        
        let item1 = ActionSheetItem(title: "Camera", value: 1)
        let item2 = ActionSheetItem(title: "Gallary", value: 2)
        
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                
                if item == item1 {
                    self.openCamera()
                }else if item == item2 {
                    self.openGallary()
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionUploadImageFromSavedDoc(_ sender: UIButton) {
        
        if self.isImgPresent == true {
            OBJCOM.setAlert(_title: "", message: "Please remove previously added vision image.")
            return
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addFilesFromDocuments),
            name: NSNotification.Name(rawValue: "ADDVBFILES"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "VB", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idSavedImageView") as! SavedImageView
        vc.className = "AddVB"
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionSelectCategory(_ sender: UIButton) {
        var items = [ActionSheetItem]()
        
        for i in 0 ..< arrVBCategoryTitle.count {
            
            let item = ActionSheetItem(title: arrVBCategoryTitle[i], value: i)
            items.append(item)
            
        }
        let button = ActionSheetOkButton(title: "Dismiss")
        items.append(button)
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                self.vCategory = self.arrVBCategoryId[item.value as! Int]
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionAddVB(_ sender: UIButton) {
        if isValidate() {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.addVisionBoard()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func isValidate() -> Bool {
        if txtVisionTitle.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter vision title.")
            return false
        }else if self.vCategory == "" {
            OBJCOM.setAlert(_title: "", message: "Please set vision category.")
            return false
        }
        return true
    }

}


extension AddVB {
    func getVisionBoardCategory(){
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getVisionBoardCategory", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                for obj in result {
                    self.arrVBCategoryTitle.append(obj.value(forKey: "vbCategory") as! String)
                    self.arrVBCategoryId.append(obj.value(forKey: "vbCategoryId") as! String)
                }
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func addVisionBoard() {
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "vboardTitle":self.txtVisionTitle.text!,
                         "vboardDescription":self.txtDescription.text!,
                         "vboardEmotion":self.txtEmotion.text!,
                         "vboardCategoryId":self.vCategory] as [String : String]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addVisionBoard", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateVB"), object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.present(alertVC, animated: true, completion: nil)
                
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func uploadVBImages(_ file: Data, filename : String, vbId:String, completionHandler: @escaping ([String:Any]?) -> ()) {
        
        let parameters = ["userId" : userID,
                          "platform":"3",
                          "vboardId":vbId ]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)/uploadVisionAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData as Data, withName: "upload", fileName: filename, mimeType: "text/plain")
            
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, with: URL2 , encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON {
                    response in
                    if let JsonDict = response.result.value as? [String : Any]{
                        print(JsonDict)
                        let success:String = JsonDict["IsSuccess"] as! String
                        if success == "true"{
                            completionHandler(JsonDict)
                            //OBJCOM.hideLoader()
                        }else{
                            let result = JsonDict["result"] as! String
                            OBJCOM.setAlert(_title: "", message: result)
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(_):
                OBJCOM.setAlert(_title: "", message: "Failed to upload image.")
                break
            }
        })
    }
    
    @objc func addFilesFromDocuments(notification: NSNotification){
        print(notification.object!)
        let fileData = notification.object as! [AnyObject]
        if fileData.count > 0 {
            for obj in fileData {
                let _ = obj["fileOri"] as? String ?? ""
                let filePath = obj["filePath"] as? String ?? ""
                
                let url = URL(string: "\(filePath)")
                if let data = try? Data(contentsOf: url!) {
                    
                    OBJCOM.setImages(imageURL: filePath, imgView: self.imgVision)
                    
                    DispatchQueue.main.async {
                        OBJCOM.setLoader()
                        self.uploadVBImages(data, filename: "vb_\(time).jpg", vbId: "0") {
                            JsonDict in
                            self.isImgPresent = true
                            self.btnDeleteImage.isHidden = false
                            OBJCOM.setAlert(_title: "", message: "Vision image uploades successfully.")
                            OBJCOM.hideLoader()
                        }
                    }
            
                }
            }
        }
        
    }
}


extension AddVB : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable (UIImagePickerController.SourceType.camera)){
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "Warning", message: "You don't have camera")
        }
    }
    func openGallary(){
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        NSLog("\(info)")
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
           // let filename = userID + "/\(NSUUID().uuidString)" + ".png"
            self.imgVision.image = pickedImage
           // self.vImage = pickedImage
            if let data = pickedImage.jpegData(compressionQuality: 0.6) {
                DispatchQueue.main.async {
                    OBJCOM.setLoader()
                    self.uploadVBImages(data, filename: "vb_\(time).jpg", vbId: "0") {
                        JsonDict in
                        self.isImgPresent = true
                        self.btnDeleteImage.isHidden = false
                        OBJCOM.setAlert(_title: "", message: "Vision image uploades successfully.")
                        OBJCOM.hideLoader()
                    }
                }
            }
            self.picker.dismiss(animated: true, completion: nil)
            
        } else {
            self.picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    func deleteUnwantedVisionAttachmentWhileCancel() {
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteUnwantedVisionAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
        
            self.dismiss(animated: true, completion: nil)
        };
    }
    
    func deleteUnwantedVisionAttachment() {
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteUnwantedVisionAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            self.isImgPresent = false
            self.btnDeleteImage.isHidden = true
            self.imgVision.image = nil
            OBJCOM.hideLoader()
        };
    }
    
    @IBAction func deleteImage(_ sender: UIButton) {
        let alertVC = PMAlertController(title: "", description: "Do you really want to remove this vision image?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
        alertVC.addAction(PMAlertAction(title: "Remove", style: .default, action: { () in
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.deleteUnwantedVisionAttachment()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
        
    }
}
