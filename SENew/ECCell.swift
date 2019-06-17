//
//  ECCell.swift
//  SENew
//
//  Created by Milind Kudale on 10/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ECCell: UITableViewCell {

    @IBOutlet var imgbgView : UIView!
    @IBOutlet var img : UIImageView!
    @IBOutlet var title : UILabel!
    @IBOutlet var btnMore : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        img.layer.cornerRadius = img.frame.height/2
        img.clipsToBounds = true
        imgbgView.layer.cornerRadius = imgbgView.frame.height/2
        imgbgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
