//
//  AppDelegate.swift
//  SENew
//
//  Created by Milind Kudale on 06/05/19.
//  Copyright © 2019 Milind Kudale. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleSignIn
import UserNotifications


var isOnboarding = true
var isOnboard = "true"
var deviceTokenId = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  if OBJCOM.isConnectedToNetwork(){
            IQKeyboardManager.shared.enable = true
            GIDSignIn.sharedInstance().clientID = demoClientID
            GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/contacts.readonly")
            
            registerForPushNotifications()
            if deviceTokenId != "" {
                if UserDefaults.standard.value(forKey: "USERINFO") != nil {
                    let userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
                    userID = userInfo["zo_user_id"] as? String ?? ""
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.sendUDIDToServer(deviceTokenId)
                    }else{
                         OBJCOM.NoInternetConnectionCall()
                    }

                }
            }
            DispatchQueue.main.async {
                self.setupSiren()
                OBJCOM.getPackagesInfo()
                self.setRootVC()
            }
        
        
        if (UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]) != nil {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            
            if userData.count > 0 {
                let cft = userData["userCft"] as? String ?? "0"
                if cft == "1" {
                    
                    if OBJCOM.isConnectedToNetwork(){
                        OBJLOC.StartupdateLocation()
                    }else{
                      //  OBJCOM.NoInternetConnectionCall()
                    }
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        OBJCOM.getPackagesInfo()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        OBJCOM.getPackagesInfo()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .immediately)
        OBJCOM.getPackagesInfo()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .daily)
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
      
    }


    func setRootVC (){
        if UserDefaults.standard.value(forKey: "USERINFO") != nil && isOnboarding == true {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            userID = userData["zo_user_id"] as! String
            if isOnboard == "false"{
                let storyboard = UIStoryboard(name: "OB", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "idOB_ProgramGoals")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }else{
                let moduleIds = UserDefaults.standard.value(forKey: "PACKAGES") as? [String] ?? []
                if moduleIds.count > 0 && !moduleIds.contains("17") {
                    let storyBoard = UIStoryboard(name:"Packages", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idNavPack"))
                    self.window?.rootViewController = controllerName
                    self.window?.makeKeyAndVisible()
                }else{
                    let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "idnav")
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
            }
        }else if UserDefaults.standard.value(forKey: "USERINFO") != nil && isOnboarding == false {
            
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            userID = userData["zo_user_id"] as? String ?? "6"
            
            let storyboard = UIStoryboard(name: "AEG", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "idAddEditGoalsDashboard")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "idCFTMapLaunchVC") 
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
    }
}

extension AppDelegate: SirenDelegate
{
    func setupSiren() {
        let siren = Siren.shared
        // Optional
        siren.delegate = self
        // Optional
        siren.debugEnabled = true
        siren.alertType = .force  //, .skip, .none
        siren.majorUpdateAlertType = .option
        siren.minorUpdateAlertType = .option
        siren.patchUpdateAlertType = .option
        siren.revisionUpdateAlertType = .option
    }
    
    func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        print(#function, alertType)
    }
    
    func sirenUserDidCancel() {
        print(#function)
    }
    
    func sirenUserDidSkipVersion() {
        print(#function)
    }
    
    func sirenUserDidLaunchAppStore() {
        print(#function)
    }
    
    func sirenDidFailVersionCheck(error: Error) {
        print(#function, error)
        
    }
    
    func sirenLatestVersionInstalled() {
        print(#function, "Latest version of app is installed")
    }
    
    // This delegate method is only hit when alertType is initialized to .none
    func sirenDidDetectNewVersionWithoutAlert(message: String, updateType: UpdateType) {
        print(#function, "\(message).\nRelease type: \(updateType.rawValue.capitalized)")
    }
}

//Push notifications setting
extension AppDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.sync {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        deviceTokenId = token
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            let userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
            userID = userInfo["zo_user_id"] as? String ?? ""
            OBJCOM.sendUDIDToServer(deviceTokenId)
        }
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

