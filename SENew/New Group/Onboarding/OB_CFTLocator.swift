//
//  OB_CFTLocator.swift
//  SENew
//
//  Created by Milind Kudale on 06/06/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class OB_CFTLocator: UIViewController {

    @IBOutlet var btnNext : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNext.layer.cornerRadius = 10.0
        self.btnNext.clipsToBounds = true
    }
    
    @IBAction func actionNext(_ sender:UIButton) {
        let storyboard = UIStoryboard(name: "OB", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idOB_EC") as! OB_EC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
}

class OB_EC: UIViewController {
    
    @IBOutlet var btnNext : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNext.layer.cornerRadius = 10.0
        self.btnNext.clipsToBounds = true
    }
    
    @IBAction func actionNext(_ sender:UIButton) {
        let storyboard = UIStoryboard(name: "OB", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idOB_TC") as! OB_TC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
}

class OB_TC: UIViewController {
    
    @IBOutlet var btnNext : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNext.layer.cornerRadius = 10.0
        self.btnNext.clipsToBounds = true
    }
    
    @IBAction func actionNext(_ sender:UIButton) {
        isOnboarding = false
        isOnboard = "true"
        AppDelegate.shared.setRootVC()
    }
    
}
