//
//  MyGroupCell.swift
//  SENew
//
//  Created by Milind Kudale on 07/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class MyGroupCell: UITableViewCell {

    @IBOutlet var lblGroupName : UILabel!
    @IBOutlet var lblGroupDesc : UILabel!
    @IBOutlet var btnSelect : UIButton!
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
        lblGroupName?.text = name
        imgUser?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgUser?.image = nil
        lblGroupName?.text = nil
    }

}
