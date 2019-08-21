//
//  OB_UploadContact.swift
//  SENew
//
//  Created by Milind Kudale on 05/06/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import ContactsUI

class OB_UploadContact: UIViewController {

    @IBOutlet var spImportDeviceContact : UIView!
    @IBOutlet var btnUploadContact : UIButton!
    var spotlightView = AwesomeSpotlightView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUploadContact.layer.cornerRadius = 5.0
        btnUploadContact.clipsToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSpotlight()
    }
    
    func setupSpotlight() {
       
        let lblDeviceContactSpotlight = AwesomeSpotlight(withRect: spImportDeviceContact.frame, shape: .roundRectangle, text: "Please import your device contacts and click next. Do not click again otherwise contacts will be repeated, allow 2-3 minutes")
        
        let btnUploadContactSpotlight = AwesomeSpotlight(withRect: btnUploadContact.frame, shape: .roundRectangle, text: "")
        
        spotlightView = AwesomeSpotlightView(frame: view.frame, spotlight: [lblDeviceContactSpotlight, btnUploadContactSpotlight])
        spotlightView.cutoutRadius = 5
        spotlightView.delegate = self
        
        view.addSubview(spotlightView)
        spotlightView.continueButtonModel.isEnable = true
        spotlightView.skipButtonModel.isEnable = false
        spotlightView.showAllSpotlightsAtOnce = false
        spotlightView.start()
    }
    
    @IBAction func actionUploadContact(_ sender:UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.importDeviceContacts()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension OB_UploadContact : AwesomeSpotlightViewDelegate {
    
    func spotlightView(_ spotlightView: AwesomeSpotlightView, willNavigateToIndex index: Int) {
        print("spotlightView willNavigateToIndex index = \(index)")
    }
    
    func spotlightView(_ spotlightView: AwesomeSpotlightView, didNavigateToIndex index: Int) {
        print("spotlightView didNavigateToIndex index = \(index)")
    }
    
    func spotlightViewWillCleanup(_ spotlightView: AwesomeSpotlightView, atIndex index: Int) {
        print("spotlightViewWillCleanup atIndex = \(index)")
    }
    
    func spotlightViewDidCleanup(_ spotlightView: AwesomeSpotlightView) {
        print("spotlightViewDidCleanup")
    }
    
    func importDeviceContacts(){
        let contactStore = CNContactStore()
        var contacts = [[String:Any]]()
        let keys = [CNContactNamePrefixKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactOrganizationNameKey as CNKeyDescriptor,
                    CNContactBirthdayKey as CNKeyDescriptor,
                    CNContactImageDataKey as CNKeyDescriptor,
                    CNContactThumbnailImageDataKey as CNKeyDescriptor,
                    CNContactImageDataAvailableKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactUrlAddressesKey as CNKeyDescriptor,
                    CNContactNoteKey as CNKeyDescriptor,
                    CNContactMiddleNameKey as CNKeyDescriptor,
                    CNContactPostalAddressesKey as CNKeyDescriptor,
                    CNContactInstantMessageAddressesKey as CNKeyDescriptor,
                    CNContactSocialProfilesKey as CNKeyDescriptor,
                    CNSocialProfileServiceTwitter as CNKeyDescriptor,
                    CNSocialProfileServiceFacebook as CNKeyDescriptor,
                    CNSocialProfileServiceLinkedIn as CNKeyDescriptor, CNContactViewController.descriptorForRequiredKeys()] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                
                var arrEmail = ["em1":"",
                                "em2":"",
                                "em3":""]
                if contact.emailAddresses.count == 1 {
                    arrEmail = ["em1":contact.emailAddresses[0].value as String,
                                "em2":"",
                                "em3":""]
                }else if contact.emailAddresses.count == 2 {
                    arrEmail = ["em1":contact.emailAddresses[0].value as String,
                                "em2":contact.emailAddresses[1].value as String,
                                "em3":""]
                }else if contact.emailAddresses.count > 2 {
                    arrEmail = ["em1":contact.emailAddresses[0].value as String,
                                "em2":contact.emailAddresses[1].value as String,
                                "em3":contact.emailAddresses[2].value as String,]
                }else{
                    arrEmail = ["em1":"",
                                "em2":"",
                                "em3":""]
                }
                
                var arrPh = ["ph1":"",
                             "ph2":"",
                             "ph3":""]
                if contact.phoneNumbers.count == 1 {
                    arrPh = ["ph1":contact.phoneNumbers[0].value.stringValue as String,
                             "ph2":"",
                             "ph3":""]
                }else if contact.phoneNumbers.count == 2 {
                    arrPh = ["ph1":contact.phoneNumbers[0].value.stringValue as String,
                             "ph2":contact.phoneNumbers[1].value.stringValue as String,
                             "ph3":""]
                }else if contact.phoneNumbers.count > 2 {
                    arrPh = ["ph1":contact.phoneNumbers[0].value.stringValue as String,
                             "ph2":contact.phoneNumbers[1].value.stringValue as String,
                             "ph3":contact.phoneNumbers[2].value.stringValue as String,]
                }else{
                    arrPh = ["ph1":"",
                             "ph2":"",
                             "ph3":""]
                }
                var arrAddrs = ["street":"",
                                "city":"",
                                "state":"",
                                "country":"",
                                "zipCode":""]
                for obj in contact.postalAddresses {
                    arrAddrs = ["street":obj.value.street,
                                "city":obj.value.city,
                                "state":obj.value.state,
                                "country":obj.value.country,
                                "zipCode":obj.value.postalCode]
                }
                
                var username    = "\(contact.givenName) \(contact.familyName)"
                var companyName = contact.organizationName
                
                if username.trimmingCharacters(in: .whitespacesAndNewlines) == "" && companyName != ""{
                    username        = companyName
                    companyName     = ""
                }
                
                var contactArray = [String : String]()
                let udata = UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]
                if udata == nil {return}
                let uid = udata!["zo_user_id"] as! String
                print(uid)
                contactArray["contact_users_id"] = uid
                contactArray["contact_flag"] = "1"
                contactArray["contact_platform"] = "3"
                contactArray["contact_fname"] = contact.givenName
                contactArray["contact_lname"] = contact.familyName
                contactArray["contact_company_name"] = contact.organizationName
                contactArray["contact_email"] = arrEmail["em1"]
                contactArray["contact_work_email"] = arrEmail["em2"]
                contactArray["contact_other_email"] = arrEmail["em3"]
                contactArray["contact_phone"] = arrPh["ph1"]?.digits
                contactArray["contact_work_phone"] = arrPh["ph2"]?.digits
                contactArray["contact_other_phone"] = arrPh["ph3"]?.digits
                contactArray["contact_description"] = contact.note
                contactArray["contact_address"] = arrAddrs["street"]
                contactArray["contact_city"] = arrAddrs["city"]
                contactArray["contact_state"] = arrAddrs["state"]
                contactArray["contact_country"] = arrAddrs["country"]
                contactArray["contact_zip"] = arrAddrs["zipCode"]
                
                print(contactArray)
                contacts.append(contactArray)
                //OBJCOM.hideLoader()
            }
            
            DispatchQueue.main.async {
                self.extractDeviceContacts(items:contacts)
            }
            print(contacts)
        } catch {
            print("unable to fetch contacts")
        }
    }
    
    func extractDeviceContacts(items:[[String:Any]]){
        var arrForImport = [AnyObject]()
        for item in items {
            arrForImport.append(item as AnyObject)
        }
        if arrForImport.count > 0 {
            print("----------------------------------")
            let dictParam = ["userId": userID,
                             "platform":"3",
                             "contact_details":arrForImport] as [String : Any]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "importCrmWithoutValidation", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.removeDuplicateContacts()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            };
        }
    }
    
    func removeDuplicateContacts(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteDuplicateCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let storyboard = UIStoryboard(name: "OB", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idOB_CFTLocator") as! OB_CFTLocator
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)

        };
        
    }
    
}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
