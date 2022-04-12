//
//  AppDelegate.swift
//  Memu
//
//  Created by APPLE on 14/03/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase
import SwiftyJSON
import IQKeyboardManagerSwift
import AppTrackingTransparency

enum Environment {
    case development
    case production
    case appstore
}

#if DEBUG
let environment: Environment = .development
#else
let environment: Environment = .production
#endif

var configurationPlistName = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        IQKeyboardManager.shared.enable = true // just add this line

        // Override point for customization after application launch.
        UIFont.overrideInitialize()
        print("Path====\(String(describing: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)))")
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyCGr6pxw8X2PueadLwk3OHDghab56-oKNQ")
        if #available(iOS 10.0, *) {
          let center  = UNUserNotificationCenter.current()
          center.delegate = self
          center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
            if error == nil{
              UIApplication.shared.registerForRemoteNotifications()
            }
          })
        } else {
          registerForPushNotifications(application)
        }
        if !UserDefaults.firstLaunch {
            UserDefaults.firstLaunch = true
            TokenUtil.cleanup()
        }
        selectEnvironmentPlistName()
        if #available(iOS 13.0, *) {
        } else {
            Switcher.updateRootVC()
        }
        if CLLocationManager.locationServicesEnabled() {
             switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("CLLocationManager No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("CLLocationManager Access")
             @unknown default:
                print("CLLocationManager No Access")
            }
            } else {
                print("CLLocationManager Location services are not enabled")
        }
        
        return true
    }
    func registerForPushNotifications(_ application: UIApplication) {
      let notificationSettings = UIUserNotificationSettings(
        types: [.badge, .sound, .alert], categories: nil)
      application.registerUserNotificationSettings(notificationSettings)
        
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        let n = NotificationHandler()
            n.askNotificationPermission {
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                        switch status {
                        case .authorized:
                            // Tracking authorization dialog was shown
                            // and we are authorized
                            print("Authorized")
                        case .denied:
                            // Tracking authorization dialog was
                            // shown and permission is denied
                            showAlert("Tracking location", message: "Please enable your location permission")
                        case .notDetermined:
                            // Tracking authorization dialog has not been shown
                            showAlert("Tracking location", message: "Please enable your location permission")
                        case .restricted:
                            showAlert("Tracking location", message: "Please enable your location permission")
                        @unknown default:
                            print("Unknown")
                        }
                    })
                } else {
                    // Fallback on earlier versions
                }
        }
   }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      
      //Notification Format -- "$body = array("aps" => array("ID" => 1, "alert" => $msg, "badge" => $badge, "sound" => 'default', "tag" => $tag)); "
      //        print(userInfo["aps"])
      
      self.hundleNotification(userInfo as NSDictionary, application: application)
    }
    func hundleNotification(_ userInfo:NSDictionary,application:UIApplication) {
        let body = userInfo.object(forKey: "body") as! String
        let aps = (userInfo["aps"] as! NSDictionary).object(forKey: "alert") as! NSDictionary
        let notititle = aps.object(forKey: "title") as! String
        let message =  userInfo.object(forKey: "message") as! String

        let json = (try? JSON(data:  Data(body.utf8))) ?? JSON.null
        let userInf = Notifications(json: JSON(json))
        print("receive notification \(userInfo)")
        var rightImage = "myfriends"
        if(userInf.type == "FL") {
            rightImage = "followers_noti"
        } else if(userInf.type == "find_ride" || userInf.type == "offer_ride") {
            rightImage = "Tap Carpool"
        }
        if(userInf.type == "FL" || userInf.type == "FR" || userInf.type == "find_ride" || userInf.type == "offer_ride") {
            UIViewController.getCurrentViewController()?.showAlert(title: message, userName: userInf.name ?? "" , userImage: userInf.photo.original_path, rightImage:  UIImage(named: rightImage)!, isAccept: userInf.isAccept, friend_id: userInf.freind_id, Notifications: userInf)
        } else if(userInf.type == "map_alerts") {
            print("map_alerts \(UIViewController.getCurrentViewController())")
            if(UIViewController.getCurrentViewController() is CustomViewController) {
                UIViewController.getCurrentViewController()?.showAlert(title: message, userName: userInf.name ?? "", userImage:URL(string: userInf.photo.original_path)! , alertImage: URL(string: userInf.logo)!, user_map_feed_id: userInf.user_map_feeds_id,lattitude: userInf.lattitude,longitude: userInf.longitude)
            }
           
        }else if(userInf.type == "like_alerts") {
            if(userInf.flag == "like") {
                UIViewController.getCurrentViewController()?.showAlert(title: "Liked your alert", userName: userInf.name ?? "", userImage: URL(string: userInf.photo.original_path)!, liked: true, desc: "You have received")
            } else {
                UIViewController.getCurrentViewController()?.showAlert(title: "Disliked your alert", userName: userInf.name ?? "", userImage: URL(string: userInf.photo.original_path)!, liked: false, desc: "You have lost")
            }
            
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      print(response)
      self.hundleNotification(response.notification.request.content.userInfo as NSDictionary, application: UIApplication.shared)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      print(notification)
      print("present notification")
      self.hundleNotification(notification.request.content.userInfo as NSDictionary, application: UIApplication.shared)
    }
    func selectEnvironmentPlistName() {
        
        switch environment {
        case .development:
            configurationPlistName = "DEBUG_Configuration"
            
        case .production:
            configurationPlistName = "PROD_Configuration"
            
        case .appstore:
            configurationPlistName = "APPSTORE_Configuration"
            //  print("It's for production")
        }
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

   
    
}

