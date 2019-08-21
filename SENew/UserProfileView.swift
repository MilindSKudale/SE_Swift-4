//
//  UserProfileView.swift
//  SENew
//
//  Created by Milind Kudale on 20/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Sheeeeeeeeet
import Alamofire
import SwiftyJSON

class UserProfileView: SliderVC, UIScrollViewDelegate {

    @IBOutlet var profileImageHeight : NSLayoutConstraint!
    @IBOutlet var profileImageTop : NSLayoutConstraint!
    @IBOutlet var scrollView : UIScrollView!
   
    var originalHeight: CGFloat!
    @IBOutlet var imgBgView : UIImageView!
    @IBOutlet var profileImage : UIImageView!
    @IBOutlet var txtFirstName : UITextField!
    @IBOutlet var txtLastName : UITextField!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPhone : UITextField!
    @IBOutlet var txtAddress : UITextField!
    @IBOutlet var txtCity : UITextField!
    @IBOutlet var txtState : UITextField!
    @IBOutlet var txtCountry : UITextField!
    @IBOutlet var txtPinCode : UITextField!
    @IBOutlet var txtBusiReason : UITextField!
    @IBOutlet var btnUploadBusiImage : UIButton!
    @IBOutlet var switchCft : PVSwitch!
    @IBOutlet var viewCondition : UIView!
    @IBOutlet var viewBusinessImage : UIView!
    @IBOutlet var businessImage : UIImageView!
    @IBOutlet var btnChangePassword : UIButton!
    
    let profileImagePicker = UIImagePickerController()
    let busiImagePicker = UIImagePickerController()
    var img_profile_pic : UIImage!
    var img_busi_pic : UIImage!
    var isCftUser = "0"
    var dreamImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnUpdate = UIButton(type: .custom)
        btnUpdate.layer.cornerRadius = 5.0
        btnUpdate.backgroundColor = APPBLUECOLOR
        btnUpdate.setTitle("Update", for: .normal)
        btnUpdate.setTitleColor(.white, for: .normal)
        btnUpdate.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        btnUpdate.addTarget(self, action: #selector(actionUpdateProfile(_:)), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnUpdate)
        self.navigationItem.setRightBarButtonItems([item], animated: true)

        originalHeight = profileImageHeight.constant
        btnUploadBusiImage.layer.cornerRadius = 5.0
        businessImage.layer.cornerRadius = 5.0
        btnChangePassword.layer.cornerRadius = 5.0
        btnUploadBusiImage.clipsToBounds = true
        btnChangePassword.clipsToBounds = true
        businessImage.clipsToBounds = true
        profileImage.clipsToBounds = true
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getUserData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let defaultTop = CGFloat(0)
        
        var currentTop = defaultTop
        if offset < 0{
            currentTop = offset
            profileImageHeight.constant = originalHeight - offset
        }else{
            profileImageHeight.constant = originalHeight
        }
        profileImageTop.constant = currentTop
    }
    
}
extension UserProfileView {
    func getUserData() {
        
        let dictParam = ["user_id":userID,
                         "platform":"3"]
      
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "userProfile", param:dictParam as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let userData = JsonDict!["result"] as! [AnyObject]
                print(userData)
                UserDefaults.standard.set(userData[0], forKey: "USERINFO")
                self.assignUserData(userData[0])
                
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
    
    func assignUserData(_ userInfo  : AnyObject){
        
        txtFirstName.text = userInfo["first_name"] as? String ?? ""
        txtLastName.text = userInfo["last_name"] as? String ?? ""
        txtEmail.text = userInfo["email"] as? String ?? ""
        txtPhone.text = userInfo["phone"] as? String ?? ""
        txtAddress.text = userInfo["userAddress"] as? String ?? ""
        txtCity.text = userInfo["userCity"] as? String ?? ""
        txtState.text = userInfo["userState"] as? String ?? ""
        txtCountry.text = userInfo["userCountry"] as? String ?? ""
        txtPinCode.text = userInfo["userZipcode"] as? String ?? ""
        txtBusiReason.text = userInfo["reason"] as? String ?? ""
        isCftUser = userInfo["userCft"] as? String ?? "0"
        if isCftUser == "1"{
            switchCft.isOn = true
            viewCondition.isHidden = false
        }else{
            switchCft.isOn = false
            viewCondition.isHidden = true
        }
        
        let profile_pic = userInfo["profile_pic"] as? String ?? ""
        if profile_pic != "" {
            OBJCOM.setImages(imageURL: profile_pic, imgView: self.profileImage)
            OBJCOM.setImages(imageURL: profile_pic, imgView: self.imgBgView)
        }else{
            self.profileImage.image = #imageLiteral(resourceName: "profile")
            self.imgBgView.image = #imageLiteral(resourceName: "profile")
        }

        dreamImage = userInfo["dreamImage"] as? String ?? ""
        if dreamImage != "" {
            OBJCOM.setImages(imageURL: dreamImage, imgView: self.businessImage)
            self.viewBusinessImage.isHidden = false
        }else{
            self.businessImage.image = #imageLiteral(resourceName: "no_image")
            self.viewBusinessImage.isHidden = true
        }
    }
    
    func apiCallForUpdateProfile(){
        
        var dictParam = [String:String]()
        dictParam["zo_user_id"] = userID
        dictParam["platform"] = "3"
        dictParam["first_name"] = txtFirstName.text!
        dictParam["last_name"] = txtLastName.text!
        dictParam["email"] = txtEmail.text!
        dictParam["phone"] = txtPhone.text!
        dictParam["userCity"] = txtCity.text!
        dictParam["userState"] = txtState.text!
        dictParam["userAddress"] = txtAddress.text!
        dictParam["userZipcode"] = txtPinCode.text!
        dictParam["userCountry"] = txtCountry.text!
        dictParam["reason"] = txtBusiReason.text!
        dictParam["user_category"] = ""
        dictParam["userCft"] = isCftUser
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "changeProfileIos", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                UserDefaults.standard.set(result[0], forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                userID = userData["zo_user_id"] as! String
                
                OBJCOM.setAlert(_title: "", message: "Your profile updated successfully.")
                
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}

extension UserProfileView {
    @IBAction func actionUpdateProfile(_ sender:AnyObject){
        if self.validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForUpdateProfile()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionSwitchCft(_ sender:PVSwitch){
        print(sender.isOn)
        if switchCft.isOn == true {
            isCftUser = "1"
            sender.isOn = true
            self.viewCondition.isHidden = false
        }else{
            isCftUser = "0"
            sender.isOn = false
            self.viewCondition.isHidden = true
        }
    }
    
    @IBAction func actionEditProfileImage(_ sender:UIButton){
        let item1 = ActionSheetItem(title: "Camera", value: 1)
        let item2 = ActionSheetItem(title: "Gallary", value: 2)
        
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                
                if item == item1 {
                    if(UIImagePickerController .isSourceTypeAvailable (UIImagePickerController.SourceType.camera)){
                        self.profileImagePicker.sourceType = UIImagePickerController.SourceType.camera
                        self.profileImagePicker.delegate = self
                        self.present(self.profileImagePicker, animated: true, completion: nil)
                    }else{
                        OBJCOM.setAlert(_title: "Warning", message: "You don't have camera")
                    }
                }else if item == item2 {
                    self.profileImagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.profileImagePicker.delegate = self
                    self.present(self.profileImagePicker, animated: true, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionEditBusinessImage(_ sender:UIButton){
        let item1 = ActionSheetItem(title: "Camera", value: 1)
        let item2 = ActionSheetItem(title: "Gallary", value: 2)
        
        let button = ActionSheetOkButton(title: "Dismiss")
        let items = [item1, item2, button]
        let sheet = ActionSheet(items: items) { sheet, item in
            if item.title != "Dismiss"{
                
                if item == item1 {
                    if(UIImagePickerController .isSourceTypeAvailable (UIImagePickerController.SourceType.camera)){
                        self.busiImagePicker.sourceType = UIImagePickerController.SourceType.camera
                        self.busiImagePicker.delegate = self
                        self.present(self.busiImagePicker, animated: true, completion: nil)
                    }else{
                        OBJCOM.setAlert(_title: "Warning", message: "You don't have camera")
                    }
                }else if item == item2 {
                    self.busiImagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.busiImagePicker.delegate = self
                    self.present(self.busiImagePicker, animated: true, completion: nil)
                }
            }
        }
        sheet.present(in: self, from: self.view)
    }
    
    @IBAction func actionDeleteBusinessImage(_ sender:UIButton){
        if dreamImage != "" {
            self.viewBusinessImage.isHidden = true
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForRemoveBusinessImage()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionChangePassword(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idChangePasswordView") as! ChangePasswordView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        
        if txtFirstName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter first name.")
            return false
        }else if txtLastName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter last name.")
            return false
        }else if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter email address.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Enter valid email address.")
            return false
        }else if txtPhone.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter phone number.")
            return false
        }else if (txtPhone.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than or equal to 5 digits.")
            return false
        }else if (txtPhone.text?.length)! > 20 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be less than or equal to 19 digits.")
            return false
        }
        return true
    }
}

extension UserProfileView : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        NSLog("\(info)")
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            if picker == profileImagePicker {
                self.profileImage.image = pickedImage
                self.imgBgView.image = pickedImage
                if pickedImage.jpegData(compressionQuality: 0.6) != nil {
                    DispatchQueue.main.async {
                        OBJCOM.setLoader()
                        self.uploadProfileImage(image: pickedImage)
                    }
                }
                self.profileImagePicker.dismiss(animated: true, completion: nil)
            }else if picker == busiImagePicker {
                self.businessImage.image = pickedImage
                
                if pickedImage.jpegData(compressionQuality: 0.6) != nil {
                    DispatchQueue.main.async {
                        OBJCOM.setLoader()
                        self.uploadBusinessImage(image: pickedImage)
                    }
                }
                self.busiImagePicker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        if picker == profileImagePicker {
            self.profileImagePicker.dismiss(animated: true, completion: nil)
        }else if picker == busiImagePicker {
            self.busiImagePicker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func uploadProfileImage(image:UIImage){
        
        let imgData = image.jpegData(compressionQuality: 0.2)
        if imgData == nil {
            OBJCOM.setAlert(_title: "", message: "Profile image is currupted, please upload image again.")
            return
        }
        
        let parameters = ["zo_user_id": userID,
                          "folder_name": "profile",
                          "platform":"3"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData!, withName: "profile_pic",fileName: "profile_pic_\(userID).jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"uploadImage")
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
                            let result = JSON["result"] as AnyObject
                            UserDefaults.standard.set(result[0], forKey: "USERINFO")
                            UserDefaults.standard.synchronize()
                            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                            userID = userData["zo_user_id"] as! String
            
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func uploadBusinessImage(image:UIImage){
       
        let imgData = image.jpegData(compressionQuality: 0.2)
        if imgData == nil {
            OBJCOM.setAlert(_title: "", message: "Business image is currupted, please upload image again.")
            return
        }
        
        let parameters = ["zo_user_id": userID,
                          "folder_name": "business",
                          "platform":"3"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData!, withName: "image_why_busuiness",fileName: "business_\(userID).jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"uploadImage")
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
                        // print(JSON)
                        
                        let success:String = JSON["IsSuccess"] as! String
                        if success == "true"{
                            let result = JSON["result"] as AnyObject
                            UserDefaults.standard.set(result[0], forKey: "USERINFO")
                            UserDefaults.standard.synchronize()
                            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                            userID = userData["zo_user_id"] as! String
                            print(UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any])
                            self.viewBusinessImage.isHidden = false
                            self.dreamImage = userData["dreamImage"] as? String ?? ""
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func apiCallForRemoveBusinessImage(){
        
        var dictParam = [String:String]()
        dictParam["zo_user_id"] = userID
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeBussinessImage", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{

                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: "Your business image removed successfully.", image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getUserData()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }))
                self.present(alertVC, animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}
