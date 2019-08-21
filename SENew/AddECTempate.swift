//
//  AddECTempate.swift
//  SENew
//
//  Created by Milind Kudale on 11/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import RichEditorView
import Sheeeeeeeeet
import Alamofire
import SwiftyJSON

class AddECTempate: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtEmailSubject : UITextField!
    @IBOutlet var txtEmailHeading : UITextField!
    @IBOutlet var editorView : RichEditorView!
    @IBOutlet var footerSwitch : PVSwitch!
    @IBOutlet var docTagList : TagListView!
    
    @IBOutlet weak var btnImmediate: UIButton!
    @IBOutlet weak var btnSchedule: UIButton!
    @IBOutlet weak var btnReapeat: UIButton!
    @IBOutlet weak var btnIntervalType: UIButton!
    @IBOutlet weak var txtInterval: UITextField!
    @IBOutlet weak var txtRepeatEveryWeeks: UITextField!
    @IBOutlet weak var txtRepeatEndsOn: UITextField!
    
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var viewReapeat: UIView!
    @IBOutlet weak var viewEditorBg: UIView!
    
    var arrSelectedDays = [String]()
    @IBOutlet var btnDaysCollection: [UIButton]!
    var endsOnWeeksCount = 1
    var timeIntervalValue = ""
    var timeIntervalType = "Select"
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    var campaignId = ""
    var templateType = "" //campaignTemplateId
    var isFooterShow = "1"
    let picker = UIImagePickerController()
    var pickedImagePath = ""
    var arrImages = [UIImage]()
    
    var arrAttachFilename = [String]()
    var arrAttachFileId = [String]()
    var arrSavedDocFilename = [String]()
    var arrSavedDocFileId = [String]()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        toolbar.tintColor = APPORANGECOLOR
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewEditorBg.clipsToBounds = true
        var userName = ""
        var phoneNum = ""
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            let userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
            if userInfo.count > 0 {
                let first_name = userInfo["first_name"] ?? ""
                let last_name = userInfo["last_name"] ?? ""
                userName = "\(first_name) \(last_name)"
                phoneNum = "\(userInfo["phone"] ?? "")"
            }
        }
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        editorView.html = "Hi {firstName}, <br><br> \(userName) <br> \(phoneNum)"
        toolbar.delegate = self
        toolbar.editor = editorView
        
        self.updateRadioButton(self.btnImmediate)
        viewSchedule.isHidden = true
        viewReapeat.isHidden = true
        btnIntervalType.setTitle("Select", for: .normal)
        txtRepeatEndsOn.text = "\(endsOnWeeksCount)"
        txtInterval.text = timeIntervalValue
        txtRepeatEveryWeeks.text = "1"
        txtRepeatEveryWeeks.delegate = self
        txtInterval.delegate = self
    
        docTagList.alignment = .left
        self.isFooterShow = "1"
        self.footerSwitch.isOn = true
        
        self.arrAttachFilename = []
        self.arrAttachFileId = []
        
        self.isImmediate = "1"
        self.txtInterval.text = ""
        self.timeIntervalType = ""

    }
    @IBAction func actionClose(_ sender:UIButton) {
        NotificationCenter.default.post(name: Notification.Name("UpdateECTemplateDetails"), object: nil)
        self.presentingViewController?.presentingViewController?.dismiss (animated: true, completion: nil)
    }
    
    @IBAction func actionAddECTemplate(_ sender:UIButton) {
        if txtEmailSubject.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email subject.")
            return
        }else if editorView.html == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email template content.")
            return
        }else{
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.actionAddTemplateAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        
    }
    
    @IBAction func actionFooterSwitch(_ sender:PVSwitch) {
        print(sender.isOn)
        if sender.isOn {
            self.isFooterShow = "1"
        }else{
            self.isFooterShow = "0"
            
        }
        print(self.isFooterShow)
    }

    @IBAction func actionAttachFiles(_ sender:UIButton) {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func actionSavedFromDocument(_ sender:UIButton) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addFilesFromDocuments),
            name: NSNotification.Name(rawValue: "ADDFILES"),
            object: nil)
        let storyboard = UIStoryboard(name: "TC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idDocumentListVC") as! DocumentListVC
        vc.className = "AddEmailTemplate"
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionSetImmediate(_ sender:UIButton) {
        self.isImmediate = "1"
        self.updateRadioButton(sender)
        self.viewSchedule.isHidden = true
        self.viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.5) {
        }
    }
    @IBAction func actionSetSchedule(_ sender:UIButton) {
        self.isImmediate = "2"
        self.updateRadioButton(sender)
        self.viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.viewSchedule.isHidden = false
        }
    }
    @IBAction func actionSetRepeat(_ sender:UIButton) {
        self.isImmediate = "3"
        self.updateRadioButton(sender)
        self.viewSchedule.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.viewReapeat.isHidden = false
        }
    }
    
    func updateRadioButton(_ sender:UIButton) {
        self.btnImmediate.isSelected = false
        self.btnSchedule.isSelected = false
        self.btnReapeat.isSelected = false
        sender.isSelected = true
    }
    
    @IBAction func actionSelectIntervalType(_ sender:UIButton) {
        let item1 = ActionSheetItem(title: "Days", value: 1)
        let item2 = ActionSheetItem(title: "Weeks", value: 2)
        let item3 = ActionSheetItem(title: "Months", value: 2)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, item3, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                sender.setTitle(item.title, for: .normal)
                
                if item == item1 {
                    self.timeIntervalType = "days"
                }else if item == item2 {
                    self.timeIntervalType = "week"
                }else if item == item3 {
                    self.timeIntervalType = "month"
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionSetWeekDaysForRepeat(_ sender : UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case 1:
            if self.arrSelectedDays.contains("Sun") == false {
                self.arrSelectedDays.append("Sun")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sun")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 2:
            if self.arrSelectedDays.contains("Mon") == false {
                self.arrSelectedDays.append("Mon")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Mon")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 3:
            if self.arrSelectedDays.contains("Tue") == false {
                self.arrSelectedDays.append("Tue")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Tue")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 4:
            if self.arrSelectedDays.contains("Wed") == false {
                self.arrSelectedDays.append("Wed")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Wed")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
                
            }
            break
        case 5:
            if self.arrSelectedDays.contains("Thu") == false {
                self.arrSelectedDays.append("Thu")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Thu")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 6:
            if self.arrSelectedDays.contains("Fri") == false {
                self.arrSelectedDays.append("Fri")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Fri")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 7:
            if self.arrSelectedDays.contains("Sat") == false {
                self.arrSelectedDays.append("Sat")
                sender.backgroundColor = APPBLUECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sat")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        default:
            break
        }
        
        print(self.arrSelectedDays)
    }
    
    @IBAction func actionIncreaseDecreaseCount(_ sender : UIButton){
        if sender.tag == 111 {
            if endsOnWeeksCount > 1 {
                endsOnWeeksCount = endsOnWeeksCount - 1
            }
        }else if sender.tag == 222 {
            if endsOnWeeksCount < 31 {
                endsOnWeeksCount = endsOnWeeksCount + 1
            }
        }
        txtRepeatEndsOn.text = "\(endsOnWeeksCount)"
    }
}


extension AddECTempate: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
//        if content.isEmpty {
//            htmlTextToSend = ""
//        } else {
//            htmlTextToSend = content
//        }
    }
}

extension AddECTempate: RichEditorToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        self.editorView.endEditing(true)
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
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        if toolbar.editor?.hasRangeSelection == true {
            
            let alertVC = PMAlertController(title: "Insert Link", description: "Ex.'http://www.successentellus.com'", image: nil, style: .alert)
            
            alertVC.addTextField({ (textField) in
                textField!.placeholder = "Enter link"
            })
            

            alertVC.addAction(PMAlertAction(title: "Insert", style: .default, action: { () in
                let strlnk = alertVC.textFields[0].text ?? ""
                
                if strlnk != "" {
                    if OBJCOM.verifyUrl(urlString:strlnk) {
                        toolbar.editor?.insertLink(strlnk, title: strlnk)
                    } else {
                        DispatchQueue.main.async {
                            let alertVC = PMAlertController(title: "", description: "Please insert valid link.", image: nil, style: .alert)
                            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                            }))
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        let alertVC = PMAlertController(title: "", description: "Please insert valid link.", image: nil, style: .alert)
                        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                        }))
                        self.present(alertVC, animated: true, completion: nil)
                    }
                }
            }))
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            }))
            self.present(alertVC, animated: true, completion: nil)
            
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select text from editor to create link.")
        }
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
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
            self.uploadImage(filename: filename, image: image)
            self.picker.dismiss(animated: true, completion: nil)

        } else {
            self.picker.dismiss(animated: true, completion: nil)
        }
    }

//    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
//    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        self.picker.dismiss(animated: true, completion: nil)
    }

    func uploadImage(filename:String, image:UIImage) {

        let param = ["userId" : userID]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(image.pngData()!, withName: "editorImage", fileName: filename, mimeType: "image/png")
            for (key, value) in param {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: SITEURL+"uploadCkEditorImage")
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                    print(progress)
                })

                upload.responseJSON { response in
                    //print response.result

                    print(response.value as AnyObject)
                    //                    let success:String = response["IsSuccess"] as! String
                    let data = response.value as AnyObject
                    let success = data["IsSuccess"] as! String
                    if success == "true" {
                        OBJCOM.hideLoader()
                        let result = data["result"] as! String
                        self.toolbar.editor?.insertImage(result,alt: "image")
                    }else{
                        print("result:",response)
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
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
}


extension AddECTempate : TagListViewDelegate, UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        print("import result : \(myURL)")
        if !self.arrAttachFilename.contains(myURL.lastPathComponent) {
            self.docTagList.addTag(myURL.lastPathComponent)
            self.arrAttachFilename.append(myURL.lastPathComponent)
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.downloadfile(URL: myURL as NSURL)
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Same file name already exists.")
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
                self.uploadDocument(data!, filename: URL.lastPathComponent!)
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
                          "campaignId":self.campaignId]
        
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)uploadAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
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
                            OBJCOM.hideLoader()
                            let result = JsonDict["result"] as! [String:Any]
                            let attachId = result["attachmentId"] as? String ?? ""
                            let filename = result["url"] as? String ?? ""
                            let arr = filename.components(separatedBy: "/")
                            self.arrAttachFilename.append(arr.last ?? "")
                            self.arrAttachFileId.append(attachId)
                        }else{
                            let result = JsonDict["result"] as! String
                            OBJCOM.setAlert(_title: "", message: result)
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(_):
                OBJCOM.setAlert(_title: "", message: "Failed to upload attachment.")
                break
            }
        })
    }
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        let fname = tagView.titleLabel?.text!
        
        if  self.arrAttachFilename.contains(fname!) {
            
            let index = self.arrAttachFilename.index(of: fname!)
            let delId = self.arrAttachFileId[index!]
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.actionDeleteDocs(delId)
                    sender.removeTagView(tagView)
                    self.arrAttachFileId.remove(at: index!)
                    self.arrAttachFilename.remove(at: index!)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else if self.arrSavedDocFilename.contains(fname!) {
            let index = self.arrSavedDocFilename.index(of: fname!)
            let delId = self.arrSavedDocFileId[index!]
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.actionDeleteDocs(delId)
                    sender.removeTagView(tagView)
                    self.arrSavedDocFileId.remove(at: index!)
                    self.arrSavedDocFilename.remove(at: index!)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
}

extension AddECTempate {
    func actionAddTemplateAPI() {
        
        if self.isImmediate == "3" {
            
            self.repeatWeeks = self.txtRepeatEveryWeeks.text!
            self.repeatOn = self.arrSelectedDays.joined(separator: ",")
            self.repeatEnd = self.txtRepeatEndsOn.text!
            
            if self.repeatWeeks == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter week(s) count.")
                OBJCOM.hideLoader()
                return
            }else if self.arrSelectedDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select weekdays.")
                OBJCOM.hideLoader()
                return
            }
        }else if self.isImmediate == "2" {
            if self.btnIntervalType.titleLabel?.text == "Select" {
                OBJCOM.setAlert(_title: "", message: "Please select interval type.")
                OBJCOM.hideLoader()
                return
            }else if self.txtInterval.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please select interval count.")
                OBJCOM.hideLoader()
                return
            }
        }
        if self.isImmediate == "1" || self.isImmediate == "2" {
            self.repeatWeeks = ""
            self.repeatOn = ""
            self.repeatEnd = ""
            if self.isImmediate == "1" {
                self.timeIntervalValue = ""
                self.timeIntervalType = ""
            }else{
                self.timeIntervalValue = self.txtInterval.text!
            }
        }else{
            if self.arrSelectedDays.count > 0 {
                self.repeatOn = self.arrSelectedDays.joined(separator: ",")
            }
            self.repeatWeeks = txtRepeatEveryWeeks.text ?? "1"
            self.repeatEnd = self.txtRepeatEndsOn.text ?? "\(endsOnWeeksCount)"
        }
        
      //  let htmlStr = editorView.html.replacingOccurrences(of: "<br>", with: "")
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignTemplateId":templateType,
                         "campaignStepCamId":campaignId,
                         "campaignStepSubject":txtEmailSubject.text!,
                         "campaignStepTitle":txtEmailHeading.text!,
                         "campaignStepContent":editorView.html,
                         "campaignStepSendInterval":self.timeIntervalValue,
                         "campaignStepSendIntervalType":self.timeIntervalType,
                         "selectType": self.isImmediate,
                         "repeat_every_weeks":self.txtRepeatEveryWeeks.text!,
                         "repeat_on":self.repeatOn,
                         "repeat_ends_after":self.repeatEnd,
                         "campaignStepFooterFlag":self.isFooterShow] as [String : Any]
        
        print(dictParam)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    NotificationCenter.default.post(name: Notification.Name("UpdateECTemplateDetails"), object: nil)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func actionDeleteDocs(_ attachId:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "attachmentId":attachId]
        
        print(dictParam)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                OBJCOM.setAlert(_title: "", message: result)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @objc func addFilesFromDocuments(notification: NSNotification){
        print(notification.object!)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            let fileData = notification.object as! [AnyObject]
            for obj in fileData {
                let fileOri = obj["fileOri"] as? String ?? ""
                if !self.arrSavedDocFilename.contains(fileOri) {
                    self.docTagList.addTag(fileOri)
                    self.arrSavedDocFilename.append(fileOri)
                    self.actionUploadSavedDocs(fileOri)
                }else{
                    OBJCOM.hideLoader()
                }
            }
        }
    }
    
    func actionUploadSavedDocs(_ filename:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "campaignId":campaignId,
                         "fileOri": filename]
        
        print(dictParam)
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "uploadFromSaveDocument", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! [String:Any]
                let attachId = result["attachmentId"] as? String ?? ""
                self.arrSavedDocFileId.append(attachId)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
