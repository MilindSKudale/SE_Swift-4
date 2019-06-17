//
//  FAQ.swift
//  SENew
//
//  Created by Milind Kudale on 21/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class FAQ: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblFaq : UITableView!
    var arrQue = [String]()
    var arrAns = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblFaq.tableFooterView = UIView()
        tblFaq.rowHeight = UITableView.automaticDimension
        tblFaq.estimatedRowHeight = 67.0
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getFaqData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrQue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblFaq.dequeueReusableCell(withIdentifier: "Cell") as! FaqCell
        cell.lblQue.text = "Q. \(arrQue[indexPath.row])"
        cell.lblAns.text = "\(arrAns[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getFaqData(){
        
        OBJCOM.modalAPICall(Action: "getFaq", param:nil,  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let faqData = JsonDict!["result"] as! [AnyObject]
                self.arrQue = []
                self.arrAns = []
                
                for obj in faqData {
                    self.arrQue.append(obj.value(forKey: "question") as! String)
                    self.arrAns.append(obj.value(forKey: "q_answer") as! String)
                }
                self.tblFaq.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
}

class FaqCell: UITableViewCell {
    
    @IBOutlet var lblQue : UILabel!
    @IBOutlet var lblAns : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
