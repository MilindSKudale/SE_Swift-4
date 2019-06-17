//
//  ScratchPadView.swift
//  SENew
//
//  Created by Milind Kudale on 24/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit

class ScratchPadView: SliderVC {

    var searchBar : DAOSearchBar!
    var txtSearch = UITextField()
    @IBOutlet var searchView : UIView!
    
    @IBOutlet weak var noNotesView : UIView!
    @IBOutlet weak var btnTakeNote : UIButton!
    @IBOutlet weak var tblNotes : UITableView!
    
    var arrTitle = [String]()
    var arrNotesId = [String]()
    var arrCreatedDate = [String]()
    var arrReminderDate = [String]()
    var arrNoteText = [String]()
    var arrNoteColor = [String]()
    var arrNoteRepeat = [String]()
    var arrNoteRepeatDailyEndDt = [String]()
    var arrNoteRepeatWeeklyEnd = [String]()
    var arrNotesData = [AnyObject]()
    
    var arrCreatedDateSearch = [String]()
    var arrReminderDateSearch = [String]()
    var arrNoteTextSearch = [String]()
    var arrNotesIdSearch = [String]()
    var arrNotesColorSearch = [String]()
    var arrNoteRepeatSearch = [String]()
    var arrNoteRepeatDailyEndDtSearch = [String]()
    var arrNoteRepeatWeeklyEndSearch = [String]()
    var arrNotesDataSearch = [AnyObject]()
    
    var isFilter = false;
    var badgeCount = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFilter = false;
        
        self.tblNotes.tableFooterView = UIView()
        self.tblNotes.rowHeight = UITableView.automaticDimension
        self.tblNotes.estimatedRowHeight = 67.0
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        self.badgeCount = "0"
        setUpBadgeCountAndBarButton()
        setupSearchBars()
    }
    
    func setupSearchBars() {
        self.searchBar = DAOSearchBar.init(frame:CGRect(x: self.searchView.frame.width - 50.0, y: 2.5, width: 40.0, height: 30))
        self.searchBar.delegate = self
        self.txtSearch = searchBar.searchField
        self.txtSearch.delegate = self
        self.searchView.addSubview(searchBar)
    }
    
    @objc func UpdateScratchPadList(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionTakeANote(_ sender:UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "ScratchPad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idCreateNoteView") as! CreateNoteView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ScratchPadView : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.arrNoteTextSearch.count
        }else { return self.arrNotesData.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblNotes.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NoteCell
        
        if isFilter {
            cell.lblCreatedDate.text = "Created on : \(self.arrCreatedDateSearch[indexPath.row])"
            cell.lblReminderDate.text = self.arrReminderDate[indexPath.row]
           
            let str = self.arrNoteTextSearch[indexPath.row]
            cell.lblNotesText.text = str.htmlToString
           
            let bgColor = self.arrNotesColorSearch[indexPath.row]
            if bgColor == "" || bgColor == "white" {
                cell.viewNotes.layer.borderWidth = 0.3
                cell.viewNotes.layer.borderColor = UIColor.lightGray.cgColor
            }
            cell.viewNotes.backgroundColor = getColor(bgColor)
            let repeatCount = self.arrNoteRepeatSearch[indexPath.row]
            if repeatCount == "1" {
                let arrEnd = self.arrNoteRepeatDailyEndDtSearch[indexPath.row].components(separatedBy: " ")
                cell.lblRepeat.text = "Daily, Ends on: \(arrEnd[0])"
            }else if repeatCount == "2" {
                
                cell.lblRepeat.text = "Weekly, Ends after: \(self.arrNoteRepeatWeeklyEndSearch[indexPath.row]) occurance"
            }else{
                cell.lblRepeat.text = ""
            }
        }else{
            cell.lblCreatedDate.text = "Created on : \(self.arrCreatedDate[indexPath.row])"
            cell.lblReminderDate.text = self.arrReminderDate[indexPath.row]
            
            let str = self.arrNoteText[indexPath.row]
            cell.lblNotesText.text = str.htmlToString
           
            let bgColor = self.arrNoteColor[indexPath.row]
            if bgColor == "" || bgColor == "white" {
                cell.viewNotes.layer.borderWidth = 0.3
                cell.viewNotes.layer.borderColor = UIColor.lightGray.cgColor
            }
            cell.viewNotes.backgroundColor = getColor(bgColor)
            
            let repeatCount = self.arrNoteRepeat[indexPath.row]
            if repeatCount == "1" {
                let arrEnd = self.arrNoteRepeatDailyEndDt[indexPath.row].components(separatedBy: " ")
                cell.lblRepeat.text = "Daily, Ends on: \(arrEnd[0])"
            }else if repeatCount == "2" {
            
                cell.lblRepeat.text = "Weekly, Ends after: \(self.arrNoteRepeatWeeklyEnd[indexPath.row]) occurance"
            }else{
                cell.lblRepeat.text = ""
            }
        }
        
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        cell.btnViewNotes.tag = indexPath.row
        
        cell.btnViewNotes.addTarget(self, action: #selector(viewNote(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(deleteNote(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(editNote(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func getColor(_ color:String) -> UIColor {
        
        if color == "blue" {
            return UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0)
        }else if color == "pink" {
            return UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0)
        }else if color == "green" {
            return UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0)
        }else if color == "orange" {
            return UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0)
        }else if color == "violet" {
            return UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0)
        }else if color == "white"{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }else{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }
        
        
    }
    
    func substring(string: String, fromIndex: Int, toIndex: Int) -> String? {
        if fromIndex < toIndex && toIndex < string.count {
            let startIndex = string.index(string.startIndex, offsetBy: fromIndex)
            let endIndex = string.index(string.startIndex, offsetBy: toIndex)
            return String(string[startIndex..<endIndex])
        }else{
            return nil
        }
    }
}


extension ScratchPadView  {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllScratchDetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrTitle = []
            self.arrNotesId = []
            self.arrCreatedDate = []
            self.arrNoteText = []
            self.arrNoteColor = []
            self.arrReminderDate = []
            self.arrNotesData = []
            self.arrNoteRepeat = []
            self.arrNoteRepeatDailyEndDt = []
            self.arrNoteRepeatWeeklyEnd = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrNotesData = JsonDict!["result"] as! [AnyObject]
                self.badgeCount = JsonDict!["notificationCnt"] as? String ?? "0"
                self.setUpBadgeCountAndBarButton()
                if self.arrNotesData.count > 0 {
                    self.arrTitle = self.arrNotesData.compactMap { $0["scratchNoteTitle"] as? String }
                    self.arrNotesId = self.arrNotesData.compactMap { $0["scratchNoteId"] as? String }
                    self.arrCreatedDate = self.arrNotesData.compactMap { $0["scratchNoteCreatedDate"] as? String }
                    self.arrNoteText = self.arrNotesData.compactMap { $0["scratchNoteText"] as? String }
                    self.arrNoteColor = self.arrNotesData.compactMap { $0["scratchNoteColor"] as? String }
                    self.arrReminderDate = self.arrNotesData.compactMap { $0["scratchNoteReminderDate"] as? String }
                    self.arrNoteRepeat = self.arrNotesData.compactMap { $0["scratchNoteReminderRepeat"] as? String }
                    self.arrNoteRepeatDailyEndDt = self.arrNotesData.compactMap { $0["scratchNoteReminderDailyEndDate"] as? String }
                    self.arrNoteRepeatWeeklyEnd = self.arrNotesData.compactMap { $0["scratchNoteReminderWeeklyEnds"] as? String }
                    self.noNotesView.isHidden = true
                }
                
                
                
                self.tblNotes.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noNotesView.isHidden = false
                self.tblNotes.reloadData()
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    @objc func viewNote(_ sender: UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        var arrId : [String] = []
        if isFilter {
            arrId = arrNotesIdSearch
        }else{
            arrId = arrNotesId
        }

        let storyboard = UIStoryboard(name: "ScratchPad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idNoteDetailsView") as! NoteDetailsView
        vc.noteId = arrId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func editNote(_ sender: UIButton){
        
        var arrId : [String] = []
        if isFilter {
            arrId = arrNotesIdSearch
        }else{
            arrId = arrNotesId
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)

        let storyboard = UIStoryboard(name: "ScratchPad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idUpdateNoteView") as! UpdateNoteView
        vc.noteId = arrId[sender.tag]
        vc.isView = false
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteNote(_ sender: UIButton){
        var arrId : [String] = []
        if isFilter {
            arrId = arrNotesIdSearch
        }else{
            arrId = arrNotesId
        }
        
        let alertVC = PMAlertController(title: "", description: "Do you want to delete this note?", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
        }))
        alertVC.addAction(PMAlertAction(title: "Delete", style: .default, action: { () in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.deleteSelectedNotes(arrId[sender.tag])
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func deleteSelectedNotes(_ noteId : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteId":noteId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                
            }else{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
            }
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getDataFromServer()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        };
    }
    
    func setUpBadgeCountAndBarButton() {
        // badge label
        
        let label = UILabel(frame: CGRect(x: 16, y: -05, width: 22, height: 22))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.backgroundColor = .red
        label.text = self.badgeCount
        
        // button
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "CFT_feedback_3x"), for: .normal)
        rightButton.addTarget(self, action: #selector(notificationBarButtonClick), for: .touchUpInside)
        if self.badgeCount != "0" && self.badgeCount != "" {
            rightButton.addSubview(label)
        }
        // Bar button item
        let rightBarButtomItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButtomItem
    }
    
    @objc func notificationBarButtonClick(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "ScratchPad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idScratchPadNotificationView") as! ScratchPadNotificationView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
}


extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}

extension ScratchPadView : DAOSearchBarDelegate, UITextFieldDelegate {
    func destinationFrameForSearchBar(_ searchBar: DAOSearchBar) -> CGRect {
        return CGRect(x: 10.0, y: 2.5, width: self.searchView.frame.width - 20.0, height: 30)
    }
    
    func searchBar(_ searchBar: DAOSearchBar, willStartTransitioningToState destinationState: DAOSearchBarState) {
        
    }
    
    func searchBar(_ searchBar: DAOSearchBar, didEndTransitioningFromState previousState: DAOSearchBarState) {
        
    }
    
    func searchBarDidTapReturn(_ searchBar: DAOSearchBar) {
        
    }
    
    func searchBarTextDidChange(_ searchBar: DAOSearchBar) {
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        
        self.arrNotesIdSearch.removeAll()
        self.arrCreatedDateSearch.removeAll()
        self.arrNoteTextSearch.removeAll()
        self.arrNotesColorSearch.removeAll()
        self.arrReminderDateSearch.removeAll()
        self.arrNoteRepeatSearch.removeAll()
        self.arrNoteRepeatDailyEndDtSearch.removeAll()
        self.arrNoteRepeatWeeklyEndSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrNotesData.count {
                let fName = arrCreatedDate[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let lName = arrReminderDate[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let em = arrNoteText[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                
                if fName != nil || lName != nil || em != nil {
                    arrNoteTextSearch.append(arrNoteText[i])
                    arrCreatedDateSearch.append(arrCreatedDate[i])
                    arrReminderDateSearch.append(arrReminderDate[i])
                    arrNotesColorSearch.append(arrNoteColor[i])
                    arrNoteRepeatSearch.append(arrNoteRepeat[i])
                    arrNoteRepeatWeeklyEndSearch.append (arrNoteRepeatWeeklyEnd[i])
                    arrNoteRepeatDailyEndDtSearch.append (arrNoteRepeatDailyEndDt[i])
                    arrNotesIdSearch.append(arrNotesId[i])
                }
            }
        } else {
            isFilter = false
        }
        tblNotes.reloadData()
    }
}



class NoteCell: UITableViewCell {
    
    @IBOutlet var lblCreatedDate : UILabel!
    @IBOutlet var lblReminderDate : UILabel!
    @IBOutlet var lblNotesText : UILabel!
    @IBOutlet var lblRepeat : UILabel!
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var btnViewNotes : UIButton!
    @IBOutlet var viewNotes : UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewNotes.layer.cornerRadius = 5
        viewNotes.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
