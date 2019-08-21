//
//  HelpMyProspects.swift
//  SENew
//
//  Created by Milind Kudale on 23/07/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import EAIntroView

class HelpMyProspects: UIViewController, EAIntroDelegate {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var btn1 : UIButton!
    @IBOutlet var btn2 : UIButton!
    @IBOutlet var btn3 : UIButton!
    @IBOutlet var btn4 : UIButton!
    @IBOutlet var btn5 : UIButton!
    @IBOutlet var btn6 : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        btn1.layer.cornerRadius = btn1.frame.height/2
        btn1.clipsToBounds = true
        btn2.layer.cornerRadius = btn2.frame.height/2
        btn2.clipsToBounds = true
        btn3.layer.cornerRadius = btn3.frame.height/2
        btn3.clipsToBounds = true
        btn4.layer.cornerRadius = btn4.frame.height/2
        btn4.clipsToBounds = true
        btn5.layer.cornerRadius = btn5.frame.height/2
        btn5.clipsToBounds = true
        btn6.layer.cornerRadius = btn6.frame.height/2
        btn6.clipsToBounds = true
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtn1(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obProspect1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obProspect2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "obProspect3")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!])
        introView?.delegate = self
                introView?.skipButton.backgroundColor = APPBLUECOLOR
                introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionBtn2(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obProspect4")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obProspect5")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "obProspect6")
        
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!])
        introView?.delegate = self
          introView?.skipButton.backgroundColor = APPBLUECOLOR
          introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionBtn3(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obProspect7")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obProspect8")
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!])
        introView?.delegate = self
           introView?.skipButton.backgroundColor = APPBLUECOLOR
           introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionBtn4(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obProspect9")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!])
        introView?.delegate = self
            introView?.skipButton.backgroundColor = APPBLUECOLOR
            introView?.skipButton.layer.cornerRadius = 15.0
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionBtn5(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obProspect10")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obProspect11")
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!])
        introView?.delegate = self
            introView?.skipButton.backgroundColor = APPBLUECOLOR
            introView?.skipButton.layer.cornerRadius = 15
        introView?.skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        introView?.show(in: self.view)
    }
    
    @IBAction func actionBtn6(_ sender:UIButton){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "obProspect12")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "obProspect13")
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!])
        introView?.delegate = self
            introView?.skipButton.backgroundColor = APPBLUECOLOR
            introView?.skipButton.layer.cornerRadius = 15
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
