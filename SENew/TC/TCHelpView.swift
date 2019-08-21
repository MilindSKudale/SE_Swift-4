//
//  TCHelpView.swift
//  SENew
//
//  Created by Milind Kudale on 15/07/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EAIntroView

class TCHelpView: UIViewController, EAIntroDelegate {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnCreateTC : UIButton!
    @IBOutlet var btnAddMessage : UIButton!
    @IBOutlet var btnAddMember : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnCreateTC.layer.cornerRadius = btnCreateTC.frame.height/2
        btnCreateTC.clipsToBounds = true
        btnAddMessage.layer.cornerRadius = btnAddMessage.frame.height/2
        btnAddMessage.clipsToBounds = true
        btnAddMember.layer.cornerRadius = btnAddMember.frame.height/2
        btnAddMember.clipsToBounds = true
        
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionCreateTC(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "createTCamp1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "createTCamp2")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionAddMessage(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "createMessage1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "createMessage2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "createMessage3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "createMessage4")
        let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "createMessage5")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!,ingropage4!,ingropage5!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionAddMember(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "addMember1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "addMember2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "addMember3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "addMember4")
        
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!,ingropage4!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        if(wasSkipped) {
            
            print("Intro skipped")
            
        } else {
            
            print("Intro skipped")
        }
    }
    
    
}
