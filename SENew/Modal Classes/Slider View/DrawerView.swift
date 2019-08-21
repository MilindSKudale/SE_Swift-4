//
//  DrawerView.swift
//  NavigationDrawer
//
//  Created by Sowrirajan Sugumaran on 05/10/17.
//  Copyright © 2017 Sowrirajan Sugumaran. All rights reserved.
//

import UIKit

var selectedCellIndex = 1
protocol DrawerControllerDelegate: class {
    func pushTo(viewController : UIViewController)
    func popupTo(popupVC : PopupViewController)
}

var motivationalFlag = ""

var arrIndexOfMyCampCell = [Int]()
var arrIndexOfMyCrmCell = [Int]()

class DrawerView: UIView, drawerProtocolNew, UITableViewDelegate, UITableViewDataSource {
    
    public let screenSize = UIScreen.main.bounds
    var backgroundView = UIView()
    var drawerView = UIView()
    
    var tblVw = UITableView()
    var aryViewControllers = NSArray()
    weak var delegate:DrawerControllerDelegate?
    var currentViewController = UIViewController()
    var cellTextColor:UIColor?
    var userNameTextColor:UIColor?
    var btnLogOut = UIButton()
    var btnRefer = UIButton()
    var vwForHeader = UIView()
    var lblunderLine = UILabel()
    var lblunderLine1 = UILabel()
    var imgBg : UIImage?
    var fontNew : UIFont?
    var moduleIds = [String]()
    var moduleNames = [String]()
    var data = [[String:Any]]()
    
    var userInfo = [String : Any]()
    var drawerIcon = [#imageLiteral(resourceName: "ic_myTools"), #imageLiteral(resourceName: "daily-checklist"), #imageLiteral(resourceName: "weekly-tracking"), #imageLiteral(resourceName: "weekly-graph"), #imageLiteral(resourceName: "add-edit-goals"), #imageLiteral(resourceName: "CFT-dashboard"), #imageLiteral(resourceName: "CFT_Community"), #imageLiteral(resourceName: "icd_myCampaigns"), #imageLiteral(resourceName: "icd_crm"), #imageLiteral(resourceName: "change-profile"), #imageLiteral(resourceName: "ic_myTools"), #imageLiteral(resourceName: "help-center"), #imageLiteral(resourceName: "money_bag_ic"), #imageLiteral(resourceName: "logout")]
   
    fileprivate var imgProPic = UIImageView()
    fileprivate let imgBG = UIImageView()
    fileprivate var lblUserName = UILabel()
    fileprivate var lblUserStatus = UILabel()
    fileprivate var imgUserStatus = UIImageView()
    fileprivate var switchAvailable = UISwitch()
    fileprivate var gradientLayer: CAGradientLayer!
    var isCollapseCrm = true
    var isCollapseCampaign = true
    var isCollapseTools = true
    
    var PopupDelegate: PopupProtocol?

    convenience init(aryControllers: NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
        }
        
        let arrTools : [String] = arrMyToolsModuleList
        var arrToolsIcons = [UIImage]()
        if arrTools.count > 0 {
            for i in 0 ..< arrTools.count {
                if arrMyToolsModuleId[i] == "5" {
                    arrToolsIcons.append(#imageLiteral(resourceName: "cal"))
                }else if arrMyToolsModuleId[i] == "6" {
                    arrToolsIcons.append(#imageLiteral(resourceName: "time-analysis"))
                }else if arrMyToolsModuleId[i] == "25" {
                    arrToolsIcons.append(#imageLiteral(resourceName: "graph"))
                }else if arrMyToolsModuleId[i] == "26" {
                    arrToolsIcons.append(#imageLiteral(resourceName: "ic_visionBoard"))
                }else if arrMyToolsModuleId[i] == "27" {
                    arrToolsIcons.append(#imageLiteral(resourceName: "ic_scratchpad"))
                }
            }
        }
        data = [["sectionHeader": "My Tools","isCollapsed":isCollapseTools,"items": arrTools, "icons":arrToolsIcons],
                
        ["sectionHeader": "Dashboard","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "Weekly Tracking","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "Weekly Graph","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "Add/Edit Goals","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "CFT Dashboard","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "CFT Locator","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "My Campaigns","isCollapsed":isCollapseCampaign,"items":["Email Campaigns", "Text Campaigns", "Upload Documents"], "icons":[ #imageLiteral(resourceName: "Email-campaign"), #imageLiteral(resourceName: "ic_textCamp"), #imageLiteral(resourceName: "upload-Doc")]],
        
        ["sectionHeader": "My CRM", "isCollapsed":isCollapseCrm,"items":["My Groups", "My Contacts", "My Customers", "My Prospects", "My Recruits"], "icons":[ #imageLiteral(resourceName: "my-group"), #imageLiteral(resourceName: "My-Contacts"), #imageLiteral(resourceName: "my-customers"), #imageLiteral(resourceName: "my-prospects"), #imageLiteral(resourceName: "My-Recruits")]],
        
        ["sectionHeader": "My Profile","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "My Subscription","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "Help","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "Earn Referral Money","isCollapsed":true,"items":[], "icons":[]],
        ["sectionHeader": "Log Out","isCollapsed":true,"items":[], "icons":[]]]
        
        self.drawerView.backgroundColor = APPBLUECOLOR
        self.tblVw.register(UINib.init(nibName: "DrawerCell", bundle: nil), forCellReuseIdentifier: "DrawerCell")
        self.tblVw.register(UINib.init(nibName: "DrawerSubmenuCell", bundle: nil), forCellReuseIdentifier: "DrawerSubmenuCell")
        self.initialise(controllers: aryViewControllers, isBlurEffect: isBlurEffect, isHeaderInTop: isHeaderInTop, controller:controller)
        moduleIds = UserDefaults.standard.value(forKey: "PACKAGES") as? [String] ?? []
        moduleNames = UserDefaults.standard.value(forKey: "PACKAGESNAME") as? [String] ?? []
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // To change the profile picture of account
    func changeProfilePic(img:UIImage) {
        imgProPic.image = img
        imgBG.image = img
        imgBg = img
    }
    
    // To change the user name of account
    func changeUserName(name:String) {
        lblUserName.text = name
    }
    
    // To change the background color of background view
    func changeGradientColor(colorTop:UIColor, colorBottom:UIColor) {
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        self.drawerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // To change the tableview cell text color
    func changeCellTextColor(txtColor:UIColor) {
        self.cellTextColor = txtColor
        btnLogOut.setTitleColor(txtColor, for: .normal)
        lblunderLine.backgroundColor = txtColor.withAlphaComponent(0.6)
        lblunderLine1.backgroundColor = txtColor.withAlphaComponent(0.6)
        self.tblVw.reloadData()
    }
    
    // To change the user name label text color
    func changeUserNameTextColor(txtColor:UIColor) {
        lblUserName.textColor = txtColor
    }
    
    // To change the font for table view cell label text
    func changeFont(font:UIFont) {
        fontNew = font
        self.tblVw.reloadData()
    }

    func initialise(controllers:NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        currentViewController = controller
        currentViewController.tabBarController?.tabBar.isHidden = true
        
        backgroundView.frame = frame
        drawerView.backgroundColor = APPBLUECOLOR
        backgroundView.backgroundColor = APPGRAYCOLOR
        backgroundView.alpha = 0.3

        // Initialize the tap gesture to hide the drawer.
        let tap = UITapGestureRecognizer(target: self, action: #selector(DrawerView.actDissmiss))
        backgroundView.addGestureRecognizer(tap)
        addSubview(backgroundView)
        
        drawerView.frame = CGRect(x:0, y:0, width:screenSize.width/2+75, height:screenSize.height)
        drawerView.clipsToBounds = true

        // Initialize the gradient color for background view
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = drawerView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.darkGray.cgColor]

        imgBG.frame = drawerView.frame
        drawerView.backgroundColor = APPBLUECOLOR
        imgBG.image = nil
        
        // Initialize the blur effect upon the image view for background view
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = drawerView.bounds
        imgBG.addSubview(blurView)
        
        // Check wether need the blur effect or not
        if isBlurEffect == true {
            self.drawerView.addSubview(imgBG)
        }else{
            self.drawerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // This is for adjusting the header frame to set header either top (isHeaderInTop:true) or bottom (isHeaderInTop:false)
        self.allocateLayout(controllers:controllers, isHeaderInTop: true)
    }
    
    func allocateLayout(controllers:NSArray, isHeaderInTop:Bool) {
        
        if isHeaderInTop {
            vwForHeader = UIView(frame:CGRect(x:0, y:0, width:drawerView.frame.size.width, height:150))
            self.lblunderLine = UILabel(frame:CGRect(x:vwForHeader.frame.origin.x+10, y:vwForHeader.frame.size.height - 1 , width:vwForHeader.frame.size.width-20, height:1.0))
            tblVw.frame = CGRect(x:0, y:vwForHeader.frame.origin.y+vwForHeader.frame.size.height, width:screenSize.width/2+75, height:screenSize.height-150)
            vwForHeader.backgroundColor = .clear
        }else{
            tblVw.frame = CGRect(x:0, y:20, width:screenSize.width/2+75, height:screenSize.height-160)
            vwForHeader = UIView(frame:CGRect(x:0, y:tblVw.frame.origin.y+tblVw.frame.size.height, width:drawerView.frame.size.width, height:screenSize.height - tblVw.frame.size.height))
            lblunderLine.frame = CGRect(x:10, y:0, width:vwForHeader.frame.size.width-20, height:1)
            
        }
        
        tblVw.separatorStyle = UITableViewCell.SeparatorStyle.none
        aryViewControllers = controllers
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.backgroundColor = .clear
        tblVw.allowsSelection = true
        tblVw.allowsMultipleSelection = false
        drawerView.addSubview(tblVw)
        tblVw.reloadData()

        
        
//        btnRefer = UIButton(frame:CGRect(x:10, y:5, width:vwForHeader.frame.size.width-20, height:50))
//        btnRefer.setTitle("  Earn Referral Money", for: .normal)
     //   btnRefer.setImage(#imageLiteral(resourceName: "money_bag_ic"), for: .normal)
//        btnRefer.contentHorizontalAlignment = .left
//        btnRefer.contentVerticalAlignment = .top
       // btnRefer.addTarget(self, action: #selector(actReferAndEarn), for: .touchUpInside)
 /*       btnRefer.titleLabel?.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 18)
        btnRefer.setTitleColor(UIColor.white, for: .normal)
        btnRefer.backgroundColor = .clear
        vwForHeader.addSubview(btnRefer)
        
        lblunderLine1.frame = CGRect(x:10, y:55, width:vwForHeader.frame.size.width-20, height:1)
        lblunderLine1.backgroundColor = UIColor.groupTableViewBackground
        vwForHeader.addSubview(lblunderLine1)
        
        btnLogOut = UIButton(frame:CGRect(x:10, y:60, width:vwForHeader.frame.size.width-20, height:50))
        btnLogOut.setTitle("Logout", for: .normal)
        btnLogOut.contentHorizontalAlignment = .left
        btnLogOut.contentVerticalAlignment = .top
        btnLogOut.addTarget(self, action: #selector(actLogOut), for: .touchUpInside)
        btnLogOut.titleLabel?.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 18)
        btnLogOut.setTitleColor(UIColor.white, for: .normal)
        btnLogOut.backgroundColor = .clear
        vwForHeader.addSubview(btnLogOut)*/
        
        var profile_pic = ""
        imgProPic = UIImageView(frame:CGRect(x:vwForHeader.frame.size.width/2-40, y:20, width:80, height:80))
        imgProPic.layer.cornerRadius = imgProPic.frame.size.height/2
        imgProPic.layer.masksToBounds = true
        imgProPic.contentMode = .scaleAspectFill
        
        if self.userInfo.count > 0 {
            profile_pic = userInfo["profile_pic"] as? String ?? ""
            if profile_pic != "" {
                OBJCOM.setProfileImages(imageURL: profile_pic, imgView: imgProPic)
            }else{
                imgProPic.image = #imageLiteral(resourceName: "profile")
            }
        }else{
            imgProPic.image = #imageLiteral(resourceName: "profile")
        }
        vwForHeader.addSubview(imgProPic)
        
        var userName = "User name"
        if self.userInfo.count > 0 {
            let first_name = userInfo["first_name"] ?? ""
            let last_name = userInfo["last_name"] ?? ""
            userName = "\(first_name) \(last_name)"
        }
        lblUserName = UILabel(frame:CGRect(x:10, y:imgProPic.frame.origin.y+85, width:vwForHeader.frame.size.width-20, height:25))
        lblUserName.text = userName
        lblUserName.font = UIFont(name: "Euphemia UCAS", size: 16)
        lblUserName.textAlignment = .center
        lblUserName.textColor = UIColor.white
        vwForHeader.addSubview(lblUserName)
        
        lblUserStatus = UILabel(frame:CGRect(x:lblUserName.frame.origin.x, y:lblUserName.frame.origin.y+25, width:lblUserName.frame.size.width, height:15))
        lblUserStatus.text = "Success Entellus LLC v\(versionNumber)"
        lblUserStatus.font = UIFont(name: "Euphemia UCAS", size: 12)
        lblUserStatus.textAlignment = .center
        lblUserStatus.textColor = UIColor.white
        vwForHeader.addSubview(lblUserStatus)
        
        lblunderLine.backgroundColor = UIColor.white
        vwForHeader.addSubview(lblunderLine)
    
        drawerView.addSubview(vwForHeader)
        addSubview(drawerView)
    }
    

    // To dissmiss the current view controller tab bar along with navigation drawer
    @objc func actDissmiss() {
        currentViewController.tabBarController?.tabBar.isHidden = false
        self.dissmiss()
    }
    
    @objc func goTOSubscription() {
        let storyBoard = UIStoryboard(name:"Packages", bundle:nil)
        let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idPackagesFilterVC"))
        controllerName.hidesBottomBarWhenPushed = true
      //  controllerName.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.delegate?.pushTo(viewController: controllerName)
    }
    
//    @objc func actReferAndEarn() {
//        let storyBoard = UIStoryboard(name:"Refferal", bundle:nil)
//        let vc = (storyBoard.instantiateViewController(withIdentifier: "idRefferalVc"))
//        let popupVC = PopupViewController(contentController: vc, popupWidth: vc.view.frame.width - 20, popupHeight: vc.view.frame.height - 60)
//        self.delegate?.popupTo(popupVC: popupVC)
//    }
    
    // Action for logout to quit the application.
    @objc func actLogOut() {
        
        
       // exit(0)
        repeatCall = false
//        isFirstTimeChecklist = true
//        isFirstTimeEmailCampaign = true
//        isFirstTimeCftLocator = true
//        isFirstTimeTextCampaign = true
//
        OBJLOC.StopUpdateLocation()
        UserDefaults.standard.removeObject(forKey: "USERINFO")
        UserDefaults.standard.removeObject(forKey: "ALL_CONTACTS")
        UserDefaults.standard.removeObject(forKey: "BUSY_START_DATE")
        UserDefaults.standard.removeObject(forKey: "PACKAGES")
        UserDefaults.standard.removeObject(forKey: "PACKAGESNAME")
        UserDefaults.standard.synchronize()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "idCFTMapLaunchVC")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
}

extension DrawerView {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "DrawerCell") as! DrawerCell
        
        if selectedCellIndex == section {
            cell.bgImageView.image = UIImage(named: "btnBg.png")
        }else{
            cell.bgImageView.image = nil
           // cell.btnSelectCell.backgroundView = UIImageView(image: nil)
        }
        cell.backgroundView?.layer.cornerRadius = 5.0
        cell.backgroundView?.clipsToBounds = true
        cell.lblController.text = data[section]["sectionHeader"] as? String
        cell.imgController.image = drawerIcon[section]
        cell.btnSelectCell.tag = section
//        cell.backgroundColor = APPBLUECOLOR
        cell.btnSelectCell.addTarget(self, action: #selector(self.sectionButtonTapped(_:)), for: .touchUpInside)
        
        if section == 0 || section == 9 || section == 10 || section == 11 || section == 12 || section == 13 {
            cell.pkgAvailable.image = nil
        }else{
            if moduleNames.contains(data[section]["sectionHeader"] as! String){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if section == 7 {

                arrIndexOfMyCampCell = []
                if moduleIds.contains("9") {
                    arrIndexOfMyCampCell.append(0)
                }
                if moduleIds.contains("10") {
                    arrIndexOfMyCampCell.append(1)
                }
                if moduleIds.contains("15") {
                    arrIndexOfMyCampCell.append(2)
                }
                print(arrIndexOfMyCampCell)


                if moduleIds.contains("9") || moduleIds.contains("10") || moduleIds.contains("15") {
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else{
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
                }
            }else if section == 8 {


                arrIndexOfMyCrmCell = []
                if moduleIds.contains("7"){
                    arrIndexOfMyCrmCell.append(0)
                }
                if moduleIds.contains("11"){
                    arrIndexOfMyCrmCell.append(1)
                }
                if moduleIds.contains("12"){
                    arrIndexOfMyCrmCell.append(2)
                }
                if moduleIds.contains("13"){
                    arrIndexOfMyCrmCell.append(3)
                }
                if moduleIds.contains("16"){
                    arrIndexOfMyCrmCell.append(4)
                }
                print(arrIndexOfMyCrmCell)
                if moduleIds.contains("7") || moduleIds.contains("11") || moduleIds.contains("12") || moduleIds.contains("13") || moduleIds.contains("16") {
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else{
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
                }
            }
            else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
        }

        
        if section == 7 {
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "ic_rightDrawer"), for: .normal)
            } else {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "ic_upDrawer"), for: .normal)
            }
        }else if section == 8 {
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "ic_rightDrawer"), for: .normal)
            } else {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "ic_upDrawer"), for: .normal)
            }
        }
        else if section == 0 {
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "ic_rightDrawer"), for: .normal)
            } else {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "ic_upDrawer"), for: .normal)
            }
        }
        else{
            cell.btnSelectCell.setImage(nil, for: .normal)
        }

        cell.lblController.textColor = self.cellTextColor ?? UIColor.white
        cell.lblController.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 16)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCollapsed = data[section]["isCollapsed"] as! Bool
        let item = data[section]["items"] as! [String]
        return isCollapsed ? 0 : item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "DrawerSubmenuCell", for: indexPath) as! DrawerSubmenuCell
        let item = data[indexPath.section]["items"] as! [String]
        let icon = data[indexPath.section]["icons"] as! [UIImage]
        
        cell.backgroundColor = APPBLUECOLOR.withAlphaComponent(0.5)
        
        cell.lblController.text = item[indexPath.row]
        cell.imgController.image = icon[indexPath.row]
        cell.btnSelectSubCell.tag = indexPath.row
        cell.btnSelectSubCell.addTarget(self, action: #selector(cellButtonTapped(_:)), for: .touchUpInside)
        
        cell.lblController.textColor = self.cellTextColor ?? UIColor.white
        cell.lblController.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 15)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.pkgAvailable.image = nil
        if indexPath.section == 0 {
            cell.pkgAvailable.image = nil
        }else if indexPath.section == 7 {
            cell.pkgAvailable.image = nil
            if arrIndexOfMyCampCell.contains(indexPath.row) {
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
        }else if indexPath.section == 8 {
            cell.pkgAvailable.image = nil
            if arrIndexOfMyCrmCell.contains(indexPath.row) {
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
        }
        return cell
    }
    
    @objc func sectionButtonTapped(_ button: UIButton) {
        let section = button.tag
    
        
       // button.isSelected = true
        
        switch section {
        case 0:
            selectedCellIndex = section
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                data[section]["isCollapsed"] = false
                data[7]["isCollapsed"] = true
                data[8]["isCollapsed"] = true
            } else {
                data[section]["isCollapsed"] = true
                
            }
            self.tblVw.reloadData()
            
            break
        case 1:
            
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("17") {
                goTOSubscription()
            }else{
            let storyBoard = UIStoryboard(name:"Dashboard", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDashboardView"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            }
            break
            
        case 2:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("4") {
                goTOSubscription()
            }else{
            let storyBoard = UIStoryboard(name:"WT", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idWeeklyTrackingView"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 3:
            
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("3") {
                goTOSubscription()
            }else{
            let storyBoard = UIStoryboard(name:"WeeklyGraph", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idWeeklyGraphDashboard"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 4:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("2") {
                goTOSubscription()
            }else{
            let storyBoard = UIStoryboard(name:"AEG", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idAddEditGoalsDashboard"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 5:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("8") {
                goTOSubscription()
            }else{
            let storyBoard = UIStoryboard(name:"CFT", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCFTDashboard"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 6:
            repeatCall = true
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("21") {
                goTOSubscription()
            }else{
            let storyBoard = UIStoryboard(name:"CFTLocator", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCFTLocatorDashboard"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 7:
            
            repeatCall = false
            selectedCellIndex = section
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                data[section]["isCollapsed"] = false
                data[0]["isCollapsed"] = true
                data[8]["isCollapsed"] = true
            }
            else {
                data[section]["isCollapsed"] = true
                
            }
            self.tblVw.reloadData()
            break
         
        case 8:
            repeatCall = false
            selectedCellIndex = section
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                data[section]["isCollapsed"] = false
                data[7]["isCollapsed"] = true
                data[0]["isCollapsed"] = true
            }
            else {
                data[section]["isCollapsed"] = true
                
            }
            self.tblVw.reloadData()
            break
        case 9:
            actDissmiss()
            selectedCellIndex = section
            let storyBoard = UIStoryboard(name:"Profile", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idUserProfileView"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        case 10:
            actDissmiss()
            let storyBoard = UIStoryboard(name:"Subscription", bundle:nil)
            let vc = (storyBoard.instantiateViewController(withIdentifier: "idMySubscriptionVC"))
            let popupVC = PopupViewController(contentController: vc, popupWidth: vc.view.frame.width - 20, popupHeight: vc.view.frame.width - 40)
            self.delegate?.popupTo(popupVC: popupVC)
            break
        case 11:
            actDissmiss()
            selectedCellIndex = section
            let storyBoard = UIStoryboard(name:"CMS", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCMSDashboard"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        case 12:
            actDissmiss()
            let storyBoard = UIStoryboard(name:"Refferal", bundle:nil)
            let vc = (storyBoard.instantiateViewController(withIdentifier: "idRefferalVc"))
            let popupVC = PopupViewController(contentController: vc, popupWidth: vc.view.frame.width - 20, popupHeight: vc.view.frame.height - 60)
            self.delegate?.popupTo(popupVC: popupVC)
            break
        case 13:
            actDissmiss()
            selectedCellIndex = 1
            actLogOut()
            break
        
        default:
            break
        }
    }
   
    
    @objc func cellButtonTapped(_ button: UIButton) {
        let index = button.tag
        if selectedCellIndex == 7 {
            switch index {
            case 0:
                repeatCall = false
                actDissmiss()
                
                if !moduleIds.contains("9") {
                    goTOSubscription()
                }else{
                
                
                let storyBoard = UIStoryboard(name:"EC", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idECListing"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
               
                }
                
                break
            case 1:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("10") {
                    goTOSubscription()
                } else {
                let storyBoard = UIStoryboard(name:"TC", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTCListingView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)

                }
                break
            case 2:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("15") {
                    goTOSubscription()
                } else {
                    let storyBoard = UIStoryboard(name:"UploadDoc", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDocumentVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
                
            default:
                repeatCall = false
                break
            }
        }else if selectedCellIndex == 8 {
            switch index {
            case 0:
                repeatCall = false
                actDissmiss()
//
                if !moduleIds.contains("7") {
                    goTOSubscription()
                }else{
                let storyBoard = UIStoryboard(name:"MyGroups", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyGroupsDashboard"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)

                }
                break
                
            case 1:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("11") {
                    goTOSubscription()
                }else{
                let storyBoard = UIStoryboard(name:"MyContacts", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyContactsView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)

                }
                break
            case 2:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("12") {
                    goTOSubscription()
                }else{
                let storyBoard = UIStoryboard(name:"MyCustomers", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyCustomersView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)

                }
                break
            case 3:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("13") {
                    goTOSubscription()
                }else{
                let storyBoard = UIStoryboard(name:"MyProspects", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyProspectsView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)

                }
                break
            case 4:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("16") {
                    goTOSubscription()
                }else{
                let storyBoard = UIStoryboard(name:"MyRecruits", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyRecruitsView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)

                }
                break
            default:
                repeatCall = false
                break
            }
        }else if selectedCellIndex == 0 {
            
            let arrTools : [String] = arrMyToolsModuleList
            if arrTools.count > 0 {
                
                if arrMyToolsModuleId[index] == "5" {
                    repeatCall = false
                    actDissmiss()
                    let storyBoard = UIStoryboard(name:"Calender", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCalenderView"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }else if arrMyToolsModuleId[index] == "6" {
                    actDissmiss()
                    let storyBoard = UIStoryboard(name:"TA", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTimeAnalysisView"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }else if arrMyToolsModuleId[index] == "25" {
                    repeatCall = false
                    actDissmiss()
                    let storyBoard = UIStoryboard(name:"TopTenScore", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDailyTopTenScore"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                    
                }else if arrMyToolsModuleId[index] == "26" {
                    actDissmiss()
                    let storyBoard = UIStoryboard(name:"VB", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idVBDashboard"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                    
                }else if arrMyToolsModuleId[index] == "27" {
                    repeatCall = false
                    actDissmiss()
                    let storyBoard = UIStoryboard(name:"ScratchPad", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idScratchPadView"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
            }
        }
    }
}
