import Foundation
import UIKit

class Switcher {
    
    static func updateRootVC() {
        if UserDefaults.isAuthenticated {
            
            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let nav = AppNavigation(rootViewController: mainVC)
            
            // iOS13 or later
            if #available(iOS 13.0, *) {
                let sceneDelegate = UIApplication.shared.connectedScenes
                    .first!.delegate as! SceneDelegate
                sceneDelegate.window!.rootViewController = nav

            // iOS12 or earlier
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = nav
            }
        } else {
            let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
            let nav = AppNavigation(rootViewController: rootVC)
            
            
            // iOS13 or later
            if #available(iOS 13.0, *) {
                let sceneDelegate = UIApplication.shared.connectedScenes
                    .first!.delegate as! SceneDelegate
                sceneDelegate.window!.rootViewController = nav
                // iOS12 or earlier
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = nav
            }
        }
    }
    
}
