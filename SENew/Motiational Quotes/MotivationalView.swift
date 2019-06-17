//
//  MotivationalView.swift
//  SENew
//
//  Created by Milind Kudale on 24/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class MotivationalView: UIViewController {

    @IBOutlet var lblTotalScore : UILabel!
    @IBOutlet var lblQuote : UILabel!
    @IBOutlet var lblQuoteAuthor : UILabel!
    @IBOutlet var lblReason : UILabel!
    @IBOutlet var lblWelcomeLblFirst : UILabel!
    @IBOutlet var lblForMotivationalQuoteofDay : UILabel!
    @IBOutlet var imgBusiness : UIImageView!
    @IBOutlet var imgEmotion : UIImageView!
    @IBOutlet var btnGotoDashboard : UIButton!
    
    var dict : AnyObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set("true", forKey: "MOTIVATIONAL")
        UserDefaults.standard.synchronize()
        
        btnGotoDashboard.layer.cornerRadius = 5.0
        btnGotoDashboard.clipsToBounds = true
        
        lblQuote.text = dict["quote"] as? String ?? ""
        lblQuoteAuthor.text = dict["quoteAuthor"] as? String ?? ""
        lblReason.text = dict["reason"] as? String ?? ""
        let totalScore = dict["totalScore"]! ?? ""
        let categoryLevel = dict["categoryLevel"]! ?? ""
        lblTotalScore.text = "Your total score is \(totalScore). \(categoryLevel)"
        lblWelcomeLblFirst.text = dict["progressText"] as? String ?? ""
        let busiImg = dict["dreamImage"] as? String ?? ""
        if busiImg != "" {
            OBJCOM.setImages(imageURL: busiImg, imgView: self.imgBusiness)
        }else{
            imgBusiness.image = #imageLiteral(resourceName: "no_image")
        }
        
        let emoji = dict["emoticonImage"] as? String ?? ""
        if emoji != "" {
            OBJCOM.setImages(imageURL: emoji, imgView: self.imgEmotion)
        }else{
            imgEmotion.image = #imageLiteral(resourceName: "EmojiSPECT")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7){
            // your code with delay
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func actionGoToDashboard(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
