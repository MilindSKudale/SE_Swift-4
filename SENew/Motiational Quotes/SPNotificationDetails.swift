//
//  SPNotificationDetails.swift
//  SENew
//
//  Created by Milind Kudale on 27/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class SPNotificationDetails: UIViewController {

    @IBOutlet weak var viewNote : UIView!
    @IBOutlet weak var lblCreatedDate : UILabel!
    @IBOutlet weak var lblReminderDate : UILabel!
    @IBOutlet weak var txtNoteText : UITextView!
    
    var noteData = [String : AnyObject]()
    var noteId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        print(noteData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.assignDataToFields(noteData as AnyObject)
    }
    
    func designUI(){
        viewNote.layer.cornerRadius = 10.0
        viewNote.layer.borderWidth = 0.3
        viewNote.layer.borderColor = UIColor.darkGray.cgColor
        viewNote.clipsToBounds = true
        txtNoteText.isUserInteractionEnabled = true
        
    }
    
    
    @IBAction func actionDismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func assignDataToFields(_ data: AnyObject){
        lblCreatedDate.text = "Created on : \(data["scratchNoteCreatedDate"] as? String ?? "")"
        lblReminderDate.text = data["scratchNoteReminderDate"] as? String ?? ""
        let str = data["scratchNoteText"] as? String ?? ""
        txtNoteText.text = str.htmlToString
        
        let bgColor = data["scratchNoteColor"] as? String ?? ""
        if bgColor == "" || bgColor == "white" {
            viewNote.layer.borderWidth = 0.3
            viewNote.layer.borderColor = UIColor.lightGray.cgColor
        }
        viewNote.backgroundColor = getColor(bgColor)
    }

    func getColor(_ color:String) -> UIColor {
        if color == "blue" {
            return UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0)
        }else if color == "pink" {
            return UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0)
        }else if color == "green" {
            return UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0)
        }else if color == "orange" {
            return UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0)
        }else if color == "violet" {
            return UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0)
        }else if color == "white"{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }else{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }
    }
    
}
