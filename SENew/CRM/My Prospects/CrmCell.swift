//
//  CrmCell.swift
//  SENew
//
//  Created by Milind Kudale on 08/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class CrmCell: UITableViewCell {

    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblEmail : UILabel!
    @IBOutlet var lblPhone : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var btnSelect : UIButton!
    @IBOutlet var btnTag : UIButton!
    @IBOutlet var imgUser : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String) {
        lblUserName?.text = name
        imgUser?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgUser?.image = nil
        lblUserName?.text = nil
    }

}
