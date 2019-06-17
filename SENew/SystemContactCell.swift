//
//  SystemContactCell.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class SystemContactCell: UITableViewCell {

    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var imgSelect : UIImageView!
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
