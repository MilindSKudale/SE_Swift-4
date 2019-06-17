//
//  TemplateSelectionView.swift
//  SENew
//
//  Created by Milind Kudale on 11/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class TemplateSelectionView: UIViewController {

    @IBOutlet var bgView : UIView!
    @IBOutlet var tblList : UITableView!
    
    var arrTemplateType = [String]()
    var arrTemplateImage = [String]()
    var arrTemplateId = [String]()
    
    var campaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        tblList.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTemplateSelection()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension TemplateSelectionView : UITableViewDataSource, UITableViewDelegate {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTemplateType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TemplateSelectionCell
        cell.lbl.text = self.arrTemplateType[indexPath.row]
        let url = self.arrTemplateImage[indexPath.row]
        OBJCOM.setImages(imageURL: url, imgView: cell.img)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "EC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAddECTempate") as! AddECTempate
        vc.campaignId = self.campaignId
        vc.templateType = self.arrTemplateId[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        //vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(vc, animated: false, completion: nil)
    }
    
}

extension TemplateSelectionView {
    func getTemplateSelection(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTemplateSelection", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                self.arrTemplateType = []
                self.arrTemplateId = []
                self.arrTemplateImage = []
                if dictJsonData.count > 0 {
                    for obj in dictJsonData {
                        self.arrTemplateType.append(obj.value(forKey: "labelTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "campaignTemplateId") as! String)
                        self.arrTemplateImage.append(obj.value(forKey: "imageUrl") as! String)
                    }
                }
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}


class TemplateSelectionCell : UITableViewCell {
    @IBOutlet var img :UIImageView!
    @IBOutlet var lbl :UILabel!
}
