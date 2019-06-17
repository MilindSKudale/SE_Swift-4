//
//  DocumentVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PDFReader
import JJFloatingActionButton
import Sheeeeeeeeet

class DocumentVC: SliderVC {

    @IBOutlet var tblDocument : UITableView!
    @IBOutlet var noRecView : UIView!
    
    var arrDocumentData = [AnyObject]()
    var arrDocumentName = [String]()
    var arrDocTypeImage = [String]()
    var arrDocumentUrl = [String]()
    var docController:UIDocumentInteractionController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Upload Documents"
        self.tblDocument.tableFooterView = UIView()
        noRecView.isHidden = true
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .clear
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "upload_doc")) { item in
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }
        
        actionButton.display(inViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDocDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
}

extension DocumentVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDocumentName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblDocument.dequeueReusableCell(withIdentifier: "DocCell") as! DocCell
        cell.lblDocTitle.text = self.arrDocumentName[indexPath.row]
        let docImg =  self.arrDocTypeImage[indexPath.row]
        if docImg != "" {
            OBJCOM.setImages(imageURL: docImg, imgView: cell.imgDoc)
            //cell.imgDoc.imageFromServerURL(urlString: docImg)
        }else{
            cell.imgDoc.image = #imageLiteral(resourceName: "noImg")
        }
        cell.btnDownload.tag = indexPath.row
        //cell.btnDelete.tag = indexPath.row
        cell.btnDownload.addTarget(self, action: #selector(downloadFileAlert(_:)), for: .touchUpInside)
        //cell.btnDelete.addTarget(self, action: #selector(deleteFileAlert(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let path = self.arrDocumentName[indexPath.row]
        var docType = ""
        if path != "" {
            let arrPath = path.components(separatedBy: ".")
            docType = arrPath.last!
        }
        if docType == "pdf"{
            let remotePDFDocumentURLPath = self.arrDocumentUrl[indexPath.row]
            if let remotePDFDocumentURL = URL(string: remotePDFDocumentURLPath), let doc = document(remotePDFDocumentURL) {
                showDocument(doc)
            } else {
                print("Document named \(remotePDFDocumentURLPath) not found")
            }
        }
    }
}

extension DocumentVC {
    func getDocDataFromServer(){
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getUploadDocuments", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            self.arrDocumentName = []
            self.arrDocTypeImage = []
            self.arrDocumentUrl = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                self.arrDocumentData = JsonDict!["result"] as! [AnyObject]
                if self.arrDocumentData.count > 0 {
                    self.arrDocumentName = self.arrDocumentData.compactMap { $0["fileName"] as? String }
                    self.arrDocTypeImage = self.arrDocumentData.compactMap { $0["fileTypeImage"] as? String }
                    self.arrDocumentUrl = self.arrDocumentData.compactMap { $0["fileUrl"] as? String }
                }
                if self.arrDocumentName.count > 0 {
                    self.noRecView.isHidden = true
                }
                OBJCOM.hideLoader()
            }else{
        
                self.noRecView.isHidden = false
                OBJCOM.hideLoader()
            }
            self.tblDocument.reloadData()
        }
    }
}

extension DocumentVC {
    
    /// Initializes a document with the name of the pdf in the file system
    private func document(_ name: String) -> PDFDocument? {
        guard let documentURL = Bundle.main.url(forResource: name, withExtension: "pdf") else { return nil }
        return PDFDocument(url: documentURL)
    }
    
    /// Initializes a document with the data of the pdf
    private func document(_ data: Data) -> PDFDocument? {
        return PDFDocument(fileData: data, fileName: "doc file")
    }
    
    /// Initializes a document with the remote url of the pdf
    private func document(_ remoteURL: URL) -> PDFDocument? {
        return PDFDocument(url: remoteURL)
    }
    
    
    /// Presents a document
    ///
    /// - parameter document: document to present
    ///
    /// Add `thumbnailsEnabled:false` to `createNew` to not load the thumbnails in the controller.
    private func showDocument(_ document: PDFDocument) {
        let image = UIImage(named: "")
        let vc = PDFViewController.createNew(with: document, title: "", actionButtonImage: image, actionStyle: .activitySheet)
       
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
//        self.present(vc, animated: false, completion: nil)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    //----------- DOWNLOAD FILE ------------
    @objc func downloadFileAlert(_ sender : UIButton){
        let item1 = ActionSheetItem(title: "Download", value: 1)
        let item2 = ActionSheetItem(title: "Share", value: 2)
        let item3 = ActionSheetItem(title: "Delete", value: 3)
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, item3, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                if item == item1 {
                   self.downloadAndSaveFile(self.arrDocumentUrl[sender.tag])
                }else if item == item2 {
                    let filename = self.self.arrDocumentUrl[sender.tag]
                    let url = NSURL.fileURL(withPath: filename)
                    let activityViewController = UIActivityViewController(activityItems: [url] , applicationActivities: nil)
                    
                    DispatchQueue.main.async {
                        
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }else if item == item3 {
                    self.deleteFileAlert(sender.tag)
                }
            }
        }
        sheet.present(in: self, from: self.view)
        
    }
    
    func downloadAndSaveFile(_ urlStr : String){

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var fileURL = self.createFolder(folderName: "SuccessEntellus")
            let fileName = URL(string : urlStr)
            fileURL = fileURL.appendingPathComponent((fileName?.lastPathComponent)!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(urlStr, to: destination).response(completionHandler: { (DefaultDownloadResponse) in
           // print("res >> ",DefaultDownloadResponse.destinationURL!);
            self.docController = UIDocumentInteractionController(url: DefaultDownloadResponse.destinationURL!)
            self.docController.presentOptionsMenu(from: self.view.frame, in: self.view, animated: true)
        })
    }
    
    func createFolder(folderName:String)->URL
    {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0] as? String ?? ""
        let dataPath: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(folderName).absoluteString
        if !FileManager.default.fileExists(atPath: dataPath) {
            try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        }
        let fileURL = URL(string: dataPath)
        return fileURL!
    }
    
    
    //----------- DELETE FILE ------------
    
    @objc func deleteFileAlert(_ index : Int){
        
        let filename = self.arrDocumentName[index]
        if filename != "" {
            
            let alertVC = PMAlertController(title: "", description: "Do you want to delete '\(self.arrDocumentName[index])' document?", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
            alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.deleteFile(filename)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
            
        }
    }
    
    func deleteFile(_ fileName : String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "fileName": fileName]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteFromDocAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
               
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getDocDataFromServer()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }

    
    //----------- UPLOAD FILE ------------
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
                let statusCode = response?.mimeType
                print("Success: \(String(describing: statusCode))")
                DispatchQueue.main.async(execute: {
                    self.uploadDocument(data!, filename: URL.lastPathComponent!)
                })
            }
            else {
                // Failure
                print("Failure: %@", error!.localizedDescription)
            }
        })
        task.resume()
    }
    
    func uploadDocument(_ file: Data,filename : String) {
        
        let parameters = ["userId" : userID,
                          "platform": "3"]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)uploadToDocAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
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
                            if OBJCOM.isConnectedToNetwork(){
                                OBJCOM.setLoader()
                                self.getDocDataFromServer()
                            }else{
                                OBJCOM.NoInternetConnectionCall()
                            }
                             OBJCOM.hideLoader()
                        }else{
                            let result = JsonDict["result"] as! String
                            OBJCOM.setAlert(_title: "", message: result)
                            
                            OBJCOM.hideLoader()
                        }
                    }else {
                        
                    }
                }
            case .failure(_): break
                 OBJCOM.hideLoader()
            }
        })
    }
}

extension DocumentVC : UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url = \(url)")
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.downloadfile(URL: url as NSURL)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
