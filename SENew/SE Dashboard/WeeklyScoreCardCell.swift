//
//  WeeklyScoreCardCell.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class WeeklyScoreCardCell: UITableViewCell {

    @IBOutlet var bgView : UIView!
    @IBOutlet var header : UIView!
    @IBOutlet var footer : UIView!
    
    @IBOutlet var imgOpenCard : UIImageView!
    @IBOutlet var lblGoalName : UILabel!
    @IBOutlet var lblWeeklyGoals : UILabel!
    @IBOutlet var lblCompletedGoals : UILabel!
    @IBOutlet var lblRemainingGoals : UILabel!
    @IBOutlet var lblScore : THLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.clipsToBounds = true
        self.lblScore.strokeSize = 3.0
        self.lblScore.shadowBlur = 0.7
        self.lblScore.innerShadowBlur = 0.7
        self.lblScore.innerShadowOffset = CGSize(width: 0, height: 1.0 )
        self.lblScore.strokeColor = .white
        self.lblScore.innerShadowColor = .lightGray
        self.lblScore.gradientStartColor = APPORANGECOLOR;
        self.lblScore.gradientEndColor = APPORANGECOLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
