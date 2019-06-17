//
//  SenderCell.swift
//  SENew
//
//  Created by Milind Kudale on 17/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class SenderCell: UITableViewCell {
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblMessage : UILabel!
    @IBOutlet var lblDate : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height/2
        self.imgUser.layer.borderColor = APPGRAYCOLOR.cgColor
        self.imgUser.layer.borderWidth = 0.5
        self.imgUser.clipsToBounds = true
        
        self.bgView.layer.cornerRadius = 5.0
        self.bgView.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ReceiverCell: UITableViewCell {
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblMessage : UILabel!
    @IBOutlet var lblDate : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height/2
        self.imgUser.layer.borderColor = APPGRAYCOLOR.cgColor
        self.imgUser.layer.borderWidth = 0.5
        self.imgUser.clipsToBounds = true
        
        self.bgView.layer.cornerRadius = 5.0
        self.bgView.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class SenderImageCell: UITableViewCell {
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var imgAttach : UIImageView!
    @IBOutlet var lblMessage : UILabel!
    @IBOutlet var lblDate : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height/2
        self.imgUser.layer.borderColor = APPGRAYCOLOR.cgColor
        self.imgUser.layer.borderWidth = 0.5
        self.imgUser.clipsToBounds = true
        
        self.bgView.layer.cornerRadius = 5.0
        self.bgView.clipsToBounds = true
        
        self.imgAttach.layer.cornerRadius = 5.0
        self.imgAttach.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class ReceiverImageCell: UITableViewCell {
    @IBOutlet var bgView : UIView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var imgAttach : UIImageView!
    @IBOutlet var lblMessage : UILabel!
    @IBOutlet var lblDate : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height/2
        self.imgUser.layer.borderColor = APPGRAYCOLOR.cgColor
        self.imgUser.layer.borderWidth = 0.5
        self.imgUser.clipsToBounds = true
        
        self.bgView.layer.cornerRadius = 5.0
        self.bgView.clipsToBounds = true
        
        self.imgAttach.layer.cornerRadius = 5.0
        self.imgAttach.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
