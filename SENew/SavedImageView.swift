//
//  SavedImageView.swift
//  SENew
//
//  Created by Milind Kudale on 20/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class SavedImageView: UIViewController {

    @IBOutlet var collectView : UICollectionView!
    
    var arrFileImage = [String]()
    var arrFileOri = [String]()
    var arrFilePath = [String]()
    
    var arrSelectedFile = String()
    var arrSelectedFilePath = String()
    
    var className = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectView.reloadData()
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getDocumentList()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getFromSaveDocument", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrFileImage = []
            self.arrFileOri = []
            self.arrFilePath = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let result = JsonDict!["result"] as! [AnyObject]
                // print(result)
                
                for obj in result {
                   // self.arrFileImage.append(obj["fileImage"] as? String ?? "")
                  //  self.arrFileNameToShow.append(obj["fileNameToShow"] as? String ?? "")
                    self.arrFileOri.append(obj["fileOri"] as? String ?? "")
                    self.arrFilePath.append(obj["filePath"] as? String ?? "")
                    
                    let file = obj["fileOri"] as? String ?? ""
                    let filePath = obj["filePath"] as? String ?? ""
                    
                    let pathExtention = file.fileExtension()
                    if pathExtention == "jpg" || pathExtention == "JPG" || pathExtention == "png" || pathExtention == "PNG" || pathExtention == "jpeg" || pathExtention == "JPEG" {
                        
                        self.arrFileImage.append(obj["fileImage"] as? String ?? "")
                        
                    }
                }
                
                self.collectView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.collectView.reloadData()
                OBJCOM.hideLoader()
            }
        };
    }

}

extension SavedImageView : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrFileImage.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! MyImageViewCell
        
        let docImg =  self.arrFileImage[indexPath.row]
        if docImg != "" {
            OBJCOM.setImages(imageURL: docImg, imgView: cell.imgView)
        }else{
            cell.imgView.image = #imageLiteral(resourceName: "cftBg")
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let file = self.arrFileOri[indexPath.row]
        let filePath = self.arrFilePath[indexPath.row]
        if self.className == "AddVB" {
            var dict = [AnyObject]()
            let param = ["fileOri":file,
                         "filePath":filePath]
            
            dict.append(param as AnyObject)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ADDVBFILES"), object: dict)
            self.dismiss(animated: true, completion: nil)
        }else if self.className == "EditVB" {
            var dict = [AnyObject]()
            let param = ["fileOri":file,
                         "filePath":filePath]
            
            dict.append(param as AnyObject)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EDITVBFILES"), object: dict)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

class MyImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
}

extension String {
    
    func fileName() -> String {
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    func fileExtension() -> String {
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }
}

