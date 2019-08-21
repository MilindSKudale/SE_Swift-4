//
//  CMSDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 21/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Parchment

class CMSDashboard: SliderVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDashBoard()
    }
    
    func loadDashBoard(){
        
        let storyboard = UIStoryboard(name: "CMS", bundle: nil)
        let StepByStepGuide = storyboard.instantiateViewController(withIdentifier: "idStepByStepGuide")
        StepByStepGuide.title = "Step By Step Guide"
        let faq = storyboard.instantiateViewController(withIdentifier: "idFAQ")
        faq.title = "FAQ"
        let contactSupport = storyboard.instantiateViewController(withIdentifier: "idContactSupport")
        contactSupport.title = "Contact Support"
        let Feedback = storyboard.instantiateViewController(withIdentifier: "idFeedback")
        Feedback.title = "Feedback"
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
            StepByStepGuide,
            faq,
            contactSupport,
            Feedback
            ])
        
        pagingViewController.menuBackgroundColor = UIColor(patternImage: UIImage(named: "btnBg1.png")!)
        pagingViewController.indicatorColor = .white
        pagingViewController.selectedTextColor = .white
        pagingViewController.textColor = UIColor.white.withAlphaComponent(0.7)
        
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParent: self)
    }

}
