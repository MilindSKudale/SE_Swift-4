//
//  OB_SetGoalsImage.swift
//  SENew
//
//  Created by Milind Kudale on 05/06/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class OB_SetGoalsImage: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtReason : UITextField!
    @IBOutlet var txtMobile : UITextField!
    @IBOutlet var btnUploadImage : UIButton!
    @IBOutlet var btnNext : UIButton!
    @IBOutlet var viewImg : UIView!
    @IBOutlet var imgView : UIImageView!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnUploadImage.layer.cornerRadius = 5.0
        btnUploadImage.clipsToBounds = true
        btnNext.layer.cornerRadius = 5.0
        btnNext.clipsToBounds = true
        viewImg.layer.cornerRadius = 5.0
        viewImg.clipsToBounds = true
        viewImg.isHidden = true
        txtMobile.delegate = self
    }
    
    @IBAction func actionUploadImage(_ sender:UIButton) {
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
    
    @IBAction func actionNext(_ sender:UIButton) {
        var imgStr = ""
        if imgView.image ==  #imageLiteral(resourceName: "no_image") {
            imgStr = ""
        }else if imgView.image == nil{
            imgStr = ""
        }else{
            imgStr = (imgView.image?.base64(format: .png))!
        }
        
        if validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSubmit(imgStr: imgStr)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionRemoveImage(_ sender:UIButton) {
        self.imgView.image = nil
        self.viewImg.isHidden = true
    }
    
    func apiCallForSubmit(imgStr:String){
        var dictParam = [String:String]()
        dictParam["user_id"] = userID
        dictParam["Imagebuisness"] = imgStr
        dictParam["platform"] = "3"
        dictParam["reason"] = txtReason.text ?? ""
        dictParam["phone"] = txtMobile.text ?? ""
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "motivational", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["loginResult"] as AnyObject
                _ = JsonDict!["result"] as! String
                
                UserDefaults.standard.set(result[0], forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                userID = userData["zo_user_id"] as! String
                print(UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any])
                
                OBJCOM.hideLoader()
                let storyboard = UIStoryboard(name: "OB", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idOB_UploadContact") as! OB_UploadContact
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: false, completion: nil)
               
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func validate() -> Bool{
        if txtReason.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter your valuable business reason.")
            return false
        }else if (txtReason.text?.length)! > 139 {
            OBJCOM.setAlert(_title: "", message: "Your business reason be less than or equal to 138 characters.")
            return false
        }else if txtMobile.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter your mobile number.")
            return false
        }else if (txtMobile.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Mobile number should be greater than or equal to 5 digits.")
            return false
        }else if (txtMobile.text?.length)! > 19 {
            OBJCOM.setAlert(_title: "", message: "Mobile number should be less than or equal to 19 digits.")
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let set = NSCharacterSet(charactersIn: "0123456789+- ().,;'").inverted
        if textField == txtMobile  {
            return string.rangeOfCharacter(from: set) == nil
        }
        return true
    }

}

extension OB_SetGoalsImage : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                self.imgView.image = pickedImage
                self.viewImg.isHidden = false
            }
            self.picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        self.picker.dismiss(animated: true, completion: nil)
    }
}

public enum ImageFormat {
    case png
    case jpeg(CGFloat)
}

extension UIImage {
    
    public func base64(format: ImageFormat) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = UIImage.pngData(self)()
        case .jpeg(let compression): imageData = UIImage.jpegData(self)(compressionQuality: compression)
        }
        return imageData?.base64EncodedString()
    }
}
