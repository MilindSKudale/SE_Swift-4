//
//  WeeklyGraphDashboard.swift
//  SENew
//
//  Created by Milind Kudale on 16/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import Parchment

class WeeklyGraphDashboard: SliderVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDashBoard()
    }
    
    func loadDashBoard(){
        
        let storyboard = UIStoryboard(name: "WeeklyGraph", bundle: nil)
        let GoalsGraphView = storyboard.instantiateViewController(withIdentifier: "idWeeklyGoalsView")
        GoalsGraphView.title = "Weekly Goals"
        let ScoreGraphView = storyboard.instantiateViewController(withIdentifier: "idWeeklyScoreView")
        ScoreGraphView.title = "Weekly Score"
        
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
            GoalsGraphView,
            ScoreGraphView])
        
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
