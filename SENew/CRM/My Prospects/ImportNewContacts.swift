//
//  ImportNewContacts.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Contacts

class ImportNewContacts: UIViewController {

    var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactGivenNameKey, CNContactFamilyNameKey
            ] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor] )
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    @IBOutlet var tblContactList : UITableView!
    @IBOutlet var btnImport : UIButton!
    @IBOutlet var tblHeight : NSLayoutConstraint!
    @IBOutlet var noRecView : UIView!
    
    var allContacts = [String]()
    var selectedPhone = [String]()
    var newContacts = [String]()
    var arrContact = [AnyObject]()
    
    var firstName = ""
    var lastName = ""
    var isAllSelected = false
    var contact_flag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblHeight.constant = 100
        noRecView.isHidden = true
        tblContactList.tableFooterView = UIView()
        btnImport.layer.cornerRadius = 5.0
        btnImport.clipsToBounds = true
        fetchAllContacts1()
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        if arrContact.count > 0 {
            let alertVC = PMAlertController(title: "Alert!", description: "Clicking on 'Cancel' will discard this contacts. You can import this contact(s) by selecting 'Import Device Contact(s)'.", image: nil, style: .alert)
            
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            }))
            
            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertVC, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func actionImport(_ sender:UIButton){
        if arrContact.count == 0 {
            OBJCOM.setAlert(_title: "", message: "No new contact added yet.")
            return
        }
        
        let dictParam = ["userId" : userID,
                         "platform" : "3",
                         "contact_details" : arrContact,
                         "contact_flag" : contact_flag,
                         "createdForNewGroup" : "1"] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "newContactImportToProspect", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.hideLoader()
                let alertVC = PMAlertController(title: "", description: result, image: nil, style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
                    if self.contact_flag == "3"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if self.contact_flag == "1"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
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
    
    
    
    func fetchAllContacts1(){
        //allContacts = contacts
        allContacts = []
        for item in contacts {
            if item.isKeyAvailable(CNContactPhoneNumbersKey){
                let phoneNOs=item.phoneNumbers
                let _:String
                for item in phoneNOs{
                    //  print("Phone Nos \(item.value.stringValue)")
                    allContacts.append(item.value.stringValue)
                }
            }
        }
        print("all Contacts  >> ", allContacts)
        if allContacts.count > 0 {
            getNewContact()
        }
    }
    
    
    func getNewContact(){
        if UserDefaults.standard.value(forKey: "ALL_CONTACTS") != nil {
            let oldContacts = UserDefaults.standard.value(forKey: "ALL_CONTACTS") as! [String]
            print(oldContacts)
            newContacts = []
            for item in allContacts {
                if oldContacts.contains(item) {
                    
                }else {newContacts.append(item)}
            }
        }
        //        print("New Contact >> ", newContacts)
        UserDefaults.standard.set(allContacts, forKey: "ALL_CONTACTS")
        UserDefaults.standard.synchronize()
        arrContact = []
        for num in newContacts {
            if num != "" {
                let contactDetails : [CNContact] = searchForContactUsingPhoneNumber(phoneNumber: num)
                print(contactDetails)
                for cont in contactDetails {
                    let fname = cont.givenName
                    let lname = cont.familyName
                    var arrEmail = [String]()
                    for obj in cont.emailAddresses {
                        arrEmail.append(obj.value as String )
                    }
                    var arrPh = [String]()
                    for obj in cont.phoneNumbers {
                        arrPh.append(obj.value.stringValue as String)
                    }
                    
                    let contactArray = ["contact_fname":fname,
                                        "contact_lname":lname,
                                        "contact_company_name":cont.organizationName,
                                        "contact_email":arrEmail,
                                        "contact_phone":arrPh,
                                        "contact_date_of_birth":"",
                                        //                                        "contact_address":"",
                        //                                        "contact_city":"",
                        //                                        "contact_state":"",
                        //                                        "contact_country":"",
                        //                                        "contact_zip":"",
                        "contact_description":""] as [String : Any]
                    
                    
                    arrContact.append(contactArray as AnyObject)
                }
            }
            
        }
        print(arrContact)
        if arrContact.count == 0 {
            noRecView.isHidden = false
        }else{
            noRecView.isHidden = true
        }
        if arrContact.count > 0 && arrContact.count < 7 {
            tblHeight.constant = CGFloat(arrContact.count*70)
        }else if arrContact.count > 6 {
            tblHeight.constant = 6*70
        }else{
            tblHeight.constant = 100.0
        }
        self.tblContactList.reloadData()
    }
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        var result: [CNContact] = []
        
        for contact in self.contacts {
            if (!contact.phoneNumbers.isEmpty) {
                let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                for phoneNumber in contact.phoneNumbers {
                    if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                        let phoneNumberString = phoneNumberStruct.stringValue
                        let phoneNumberToCompare = phoneNumberString.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                        if phoneNumberToCompare == phoneNumberToCompareAgainst {
                            result.append(contact)
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    
    func contactInitials() -> String {
        var initials = String()
        
        if let firstNameFirstChar = firstName.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = lastName.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
}

extension ImportNewContacts : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblContactList.dequeueReusableCell(withIdentifier: "Cell") as! SystemContactCell
        
        let fname = arrContact[indexPath.row]["contact_fname"] ?? ""
        let lname = arrContact[indexPath.row]["contact_lname"] ?? ""
        
        firstName = fname as! String
        lastName = lname as! String
        cell.lblUserName.text = "\(fname!) \(lname!)"
        cell.configure(name: cell.lblUserName.text!)
        cell.imgSelect.image = UIImage(named: "check.png")
        
        
        return cell
    }
    
}
