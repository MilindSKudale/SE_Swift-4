//
//  AddEditGoalCell.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class AddEditGoalCell: UITableViewCell {

    @IBOutlet var lblGoalName : UILabel!
    @IBOutlet var lblGoalCount : UILabel!
    @IBOutlet var txtGoalCount : UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
