//
//  ReachabilityManager.swift
//  NetworkStatusMonitor
//
//  Created by Sauvik Dolui on 18/10/16.
//  Copyright © 2016 Innofied Solution Pvt. Ltd. All rights reserved.
//

import Foundation
import Reachability // 1 Importing the Library

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()  // 2. Shared instance
    
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .unavailable
    }
    
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.Connection = .unavailable
    
    // 5. Reachibility instance for Network status monitoring
    let reachability = try! Reachability()

    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(note: Notification) {
      let reachability = note.object as! Reachability
      switch reachability.connection {
      case .wifi:
          print("Reachable via WiFi")
      case .cellular:
          print("Reachable via Cellular")
      case .none:
        print("Network not reachable")
        self.reachabilityManagerShowAlert("Message", "Network not reachable")
      case .unavailable:
         print("Network unavailable")
         self.reachabilityManagerShowAlert("Message", "Network unavailable")
        }
    }

    func reachabilityManagerShowAlert(_ title: String, _ message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertAction.Style.default,
                                      handler: { (_) -> Void in
                                        alert.dismiss(animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            completion?()
                                        }
        }))
        UIViewController().topMostViewController().present(alert, animated: true, completion: nil)
    }
    /// Starts monitoring the network availability status
    func startMonitoring() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
}
