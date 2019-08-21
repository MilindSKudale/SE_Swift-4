//
//  ECHelpView.swift
//  SENew
//
//  Created by Milind Kudale on 12/07/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EAIntroView

class ECHelpView: UIViewController, EAIntroDelegate {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnCreateEC : UIButton!
    @IBOutlet var btnAddET : UIButton!
    @IBOutlet var btnAddEmail : UIButton!
    @IBOutlet var btnImport : UIButton!
    @IBOutlet var btnSelfReminder : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btnCreateEC.layer.cornerRadius = btnCreateEC.frame.height/2
        btnCreateEC.clipsToBounds = true
        btnAddET.layer.cornerRadius = btnAddET.frame.height/2
        btnAddET.clipsToBounds = true
        btnAddEmail.layer.cornerRadius = btnAddEmail.frame.height/2
        btnAddEmail.clipsToBounds = true
        btnImport.layer.cornerRadius = btnImport.frame.height/2
        btnImport.clipsToBounds = true
        btnSelfReminder.layer.cornerRadius = btnSelfReminder.frame.height/2
        btnSelfReminder.clipsToBounds = true
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionCreateEC(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "camp1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "camp2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "camp3")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionAddET(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "Template1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "Template2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "Template3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "Template4")
        let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "Template5")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!,ingropage4!,ingropage5!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionAddEmail(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "addE1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "addE2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "addE3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "addE4")
        
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!,ingropage4!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionImport(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "imp1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "imp2")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!])
        introView?.delegate = self
        introView?.skipButton.backgroundColor = APPBLUECOLOR
        introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionSelfReminder(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "rem1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "rem2")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!])
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
