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
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIFont.overrideInitialize()
        print("Path====\(String(describing: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)))")
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyCGr6pxw8X2PueadLwk3OHDghab56-oKNQ")
        
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

