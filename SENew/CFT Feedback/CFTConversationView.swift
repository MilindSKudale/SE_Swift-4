//
//  CFTConversationView.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Sheeeeeeeeet


class CFTConversationView: UIViewController {

    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var imageUser : UIImageView!
    @IBOutlet var tblConversation : UITableView!
    @IBOutlet var txtMessage : GrowingTextView!
    
    var userName = ""
    var userImage = ""
    var cftUserId = ""
    var cftFeedbackParentId = ""
    
//    var arrId = [String]()
    var arrName = [String]()
    var arrImage = [String]()
    var arrDate = [String]()
    var arrCftUserId = [String]()
    var arrMsgContent = [String]()
    var arrAttachImage = [String]()
    let picker = UIImagePickerController()
    var selectedImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageUser.layer.cornerRadius = self.imageUser.frame.height/2
        self.imageUser.clipsToBounds = true
        self.lblUserName.text = userName
        OBJCOM.setImages(imageURL: userImage, imgView: self.imageUser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getConversationData()
            self.updateCounterFlag()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

extension CFTConversationView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsgContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        if self.arrCftUserId[indexPath.row] != userID {
            
            if self.arrAttachImage[indexPath.row] == "" {
                let senderCell = tblConversation.dequeueReusableCell(withIdentifier: "SenderCell") as! SenderCell
                
                OBJCOM.setImages(imageURL: self.arrImage[indexPath.row], imgView: senderCell.imgUser)
                let attributedQuote = NSAttributedString(string: self.arrMsgContent[indexPath.row])
                senderCell.lblMessage.attributedText = attributedQuote
                senderCell.lblDate.text = self.arrDate[indexPath.row]
                cell = senderCell
            }else{
                let attach = self.arrAttachImage[indexPath.row]
                let attachUrl = URL(string: attach)
                let pathExtention = attachUrl!.pathExtension
                if pathExtention == "jpg" || pathExtention == "JPG" || pathExtention == "png" || pathExtention == "PNG" {
                    let senderImageCell = tblConversation.dequeueReusableCell(withIdentifier: "SenderImageCell") as! SenderImageCell
                    
                    OBJCOM.setImages(imageURL: self.arrImage[indexPath.row], imgView: senderImageCell.imgUser)
                    let attributedQuote = NSAttributedString(string: self.arrMsgContent[indexPath.row])
                    senderImageCell.lblMessage.attributedText = attributedQuote
                    senderImageCell.lblDate.text = self.arrDate[indexPath.row]
                    OBJCOM.setImages(imageURL: self.arrAttachImage[indexPath.row], imgView: senderImageCell.imgAttach)
                    cell = senderImageCell
                }else{
                    let senderCell = tblConversation.dequeueReusableCell(withIdentifier: "SenderCell") as! SenderCell
                    
                    OBJCOM.setImages(imageURL: self.arrImage[indexPath.row], imgView: senderCell.imgUser)
                    let attributedQuote = NSAttributedString(string: attach)
                    senderCell.lblMessage.attributedText = attributedQuote
                    senderCell.lblDate.text = self.arrDate[indexPath.row]
                    cell = senderCell
                }
                
            }
            
            
        }else{
            
            if self.arrAttachImage[indexPath.row] == "" {
                let receiverCell = tblConversation.dequeueReusableCell(withIdentifier: "ReceiverCell") as! ReceiverCell
                let attributedQuote = NSAttributedString(string: self.arrMsgContent[indexPath.row])
                OBJCOM.setImages(imageURL: self.arrImage[indexPath.row], imgView: receiverCell.imgUser)
                receiverCell.lblMessage.attributedText = attributedQuote
                receiverCell.lblDate.text = self.arrDate[indexPath.row]
                cell = receiverCell
            }else{
                let attach = self.arrAttachImage[indexPath.row]
                let attachUrl = URL(string: attach)
                
                if attachUrl?.pathExtension == "jpg" || attachUrl?.pathExtension == "JPG" || attachUrl?.pathExtension == "png" || attachUrl?.pathExtension == "PNG" {
                    let receiverImageCell = tblConversation.dequeueReusableCell(withIdentifier: "ReceiverImageCell") as! ReceiverImageCell
                    
                    OBJCOM.setImages(imageURL: self.arrImage[indexPath.row], imgView: receiverImageCell.imgUser)
                    let attributedQuote = NSAttributedString(string: self.arrMsgContent[indexPath.row])
                    receiverImageCell.lblMessage.attributedText = attributedQuote
                    receiverImageCell.lblDate.text = self.arrDate[indexPath.row]
                    OBJCOM.setImages(imageURL: self.arrAttachImage[indexPath.row], imgView: receiverImageCell.imgAttach)
                    cell = receiverImageCell
                }else{
                    let receiverCell = tblConversation.dequeueReusableCell(withIdentifier: "ReceiverCell") as! ReceiverCell
                    let attributedQuote = NSAttributedString(string: attach)
                    OBJCOM.setImages(imageURL: self.arrImage[indexPath.row], imgView: receiverCell.imgUser)
                    receiverCell.lblMessage.attributedText = attributedQuote
                    receiverCell.lblDate.text = self.arrDate[indexPath.row]
                    cell = receiverCell
                }
                
            }
            
        }
        return cell
    }
}

extension CFTConversationView : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
   
    
    
    // send text message
    @IBAction func actionSendMessage(_ sender:UIButton){
        if txtMessage.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter message to send.")
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.sendTextFeedback(txtMessage.text)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    // send image
    
    @IBAction func actionAddImagesFromGallary(_ sender:UIButton){
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
            let filename = userID + "/\(NSUUID().uuidString)" + ".png"
            let image = self.resizeImage(image: pickedImage, targetSize: CGSize(width: 200.0, height: 200.0))
            self.picker.dismiss(animated: true, completion: nil)
            let alertVC = PMAlertController(title: "", description: "Are you sure want to send selected image?", image: image, style: .alert)
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                self.sendImageFeedback(item: image, filename:filename)
                
            }))
            self.present(alertVC, animated: true, completion: nil)
        } else {
            self.picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //upload doc
    
    @IBAction func actionAddAttachment(_ sender:UIButton){
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.downloadfile(URL: myURL as NSURL)
        }
    }
    
    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
               // self.uploadDocument(data!, filename: URL.lastPathComponent!)
               self.sendAttachmentFeedback(item: data!, filename: URL.lastPathComponent!)
            }
            else {
                // Failure
                print("Failure: %@", error!.localizedDescription)
                OBJCOM.setAlert(_title: "", message: error!.localizedDescription)
                OBJCOM.hideLoader()
            }
        })
        task.resume()
    }
    
    func uploadDocument(_ file: Data,filename : String) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "feedbackCftId":cftUserId]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)uploadCftAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
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
                            self.txtMessage.text = ""
                            self.getConversationData()
                            OBJCOM.hideLoader()
                        }else{
                            
                            OBJCOM.setAlert(_title: "", message: "Unable to upload attachment. Please retry.")
                            OBJCOM.hideLoader()
                        }
                    }else {
                        OBJCOM.setAlert(_title: "", message: "Unable to upload attachment. Please retry.")
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(_):
                OBJCOM.setAlert(_title: "", message: "Unable to upload attachment. Please retry.")
                OBJCOM.hideLoader()
                break
            }
        })
    }
    
}

extension CFTConversationView {
    func getConversationData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftAccessUserId": cftUserId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorFeedBack", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                self.arrName = []
                self.arrImage = []
                self.arrDate = []
                self.arrCftUserId = []
                self.arrMsgContent = []
                self.arrAttachImage = []
//                self.arrId = []
                
                let arrData = JsonDict!["result"] as! [String : AnyObject]
                let arrFeedbackData = arrData["feedBack"] as! [AnyObject]
                
                for i in 0..<arrFeedbackData.count {
                    
                    let msg = self.decodeEmoji(arrFeedbackData[i]["feedbackCftContent"] as? String ?? "")
                    
                    self.arrName.append(arrFeedbackData[i]["toName"] as? String ?? "")
                    self.arrImage.append(arrFeedbackData[i]["imgPathTo"] as? String ?? "")
                    self.arrDate.append(arrFeedbackData[i]["feedbackCftAddDate"] as? String ?? "")
                    self.arrCftUserId.append(arrFeedbackData[i]["cftUser"] as? String ?? "")
                    self.arrMsgContent.append(msg ?? "")
                    self.arrAttachImage.append(arrFeedbackData[i]["attachImage"] as? String ?? "")
                }
                self.cftFeedbackParentId = "\(arrData["feedbackParentCft"] ?? "" as AnyObject)"
                self.view.layoutIfNeeded()
                self.tblConversation.reloadData()
                if arrFeedbackData.count > 0 {
                    self.tblConversation.scrollToBottom()
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func encodeEmoji(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    func decodeEmoji(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
    
    func updateCounterFlag(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftAccessUserId": cftUserId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateReadFlagTo", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
            }else{
                OBJCOM.popUp(context: self, msg: "Failed to update message counter.")
                OBJCOM.hideLoader()
            }
        }
    }
    
    func sendTextFeedback(_ message:String){
        
        let msg = encodeEmoji(message)
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "feedbackCftTo": cftUserId,
                         "feedbackParentCft": cftFeedbackParentId,
                         "feedbackCftContent": msg,
                         "attachImage": ""]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "sendMentorFeedBack", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.txtMessage.text = ""
                self.getConversationData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func sendImageFeedback(item:UIImage, filename:String){
        
        
        let imgData = item.jpegData(compressionQuality:0.2)
        if imgData!.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Selected image is not proper format.")
            return
        }
        let parameters = ["userId": userID,
                          "platform":"3",
                          "feedbackCftTo": cftUserId,
                          "feedbackParentCft": cftFeedbackParentId,
                          "feedbackCftContent": ""]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData!, withName: "attachImage",fileName: filename, mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"sendMentorFeedBack")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let  JSON : [String:Any]
                    if let json = response.result.value {
                        JSON = json as! [String : Any]
                        
                        let success:String = JSON["IsSuccess"] as! String
                        if success == "true"{
                            self.txtMessage.text = ""
                            self.getConversationData()
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.setAlert(_title: "", message: "Failed to send image")
                            OBJCOM.hideLoader()
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func sendAttachmentFeedback(item:Data, filename:String){
        
        if item.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Selected attachment is not proper format.")
            return
        }
        let parameters = ["userId": userID,
                          "platform":"3",
                          "feedbackCftTo": cftUserId,
                          "feedbackParentCft": cftFeedbackParentId,
                          "feedbackCftContent": ""]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(item, withName: "attachImage",fileName: filename, mimeType: "image/text")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"sendMentorFeedBack")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let  JSON : [String:Any]
                    if let json = response.result.value {
                        JSON = json as! [String : Any]
                        
                        let success:String = JSON["IsSuccess"] as! String
                        if success == "true"{
                            self.txtMessage.text = ""
                            self.getConversationData()
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.setAlert(_title: "", message: "Failed to send attachment")
                            OBJCOM.hideLoader()
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
}
extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
