//
//  ChecklistCell.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ChecklistCell: UITableViewCell {

    @IBOutlet var btnHideGoals : UIButton!
    @IBOutlet var lblGoalName : UILabel!
    @IBOutlet var txtCompletedGoalCount : UITextField!
    @IBOutlet var lblTotalGoalCount : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     //   txtCompletedGoalCount.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//extension ChecklistCell : UITextFieldDelegate {

//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        txtCompletedGoalCount.shadow()
//        txtCompletedGoalCount.textColor = APPORANGECOLOR
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        txtCompletedGoalCount.textColor = .black
//        txtCompletedGoalCount.removeShadow()
//    }
//}

extension UIView {
    
    func shadow(_ height: Int = 3) {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.7
        self.layer.shadowColor = APPORANGECOLOR.cgColor
        self.layer.shadowOffset = CGSize(width: 0 , height: 0)
    }
    
    func removeShadow() {
        self.layer.shadowOffset = CGSize(width: 0 , height: 0)
        self.layer.shadowColor = UIColor.clear.cgColor
//        self.layer.cornerRadius = 0.0
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.0
    }
}
