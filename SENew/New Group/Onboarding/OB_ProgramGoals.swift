//
//  OB_ProgramGoals.swift
//  SENew
//
//  Created by Milind Kudale on 05/06/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class OB_ProgramGoals: UIViewController {

    @IBOutlet var btnLetsGo : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnLetsGo.layer.cornerRadius = 5.0
        btnLetsGo.clipsToBounds = true
    }
    
    @IBAction func actionLetsGo(_ sender:UIButton) {
        let storyboard = UIStoryboard(name: "OB", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idOB_SetGoalsImage") as! OB_SetGoalsImage
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
}
