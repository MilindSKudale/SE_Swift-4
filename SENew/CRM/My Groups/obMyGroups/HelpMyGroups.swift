//
//  HelpMyGroups.swift
//  SENew
//
//  Created by Milind Kudale on 25/07/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EAIntroView

class HelpMyGroups: UIViewController, EAIntroDelegate {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var btn1 : UIButton!
    @IBOutlet var btn2 : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btn1.layer.cornerRadius = btn1.frame.height/2
        btn1.clipsToBounds = true
        btn2.layer.cornerRadius = btn2.frame.height/2
        btn2.clipsToBounds = true
        
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtn1(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obGrp1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obGrp2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "obGrp3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "obGrp4")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!, ingropage4!])
        introView?.delegate = self
                introView?.skipButton.backgroundColor = APPBLUECOLOR
                introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionBtn2(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obGrp5")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obGrp6")
       
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
