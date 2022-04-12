//
//  NotificationHandler.swift
//  Memu
//
//  Created by Tejaswini N on 15/11/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UserNotifications

class NotificationHandler {
//Permission function
    func askNotificationPermission(completion: @escaping ()->Void) {
        
        //Permission to send notifications
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .badge, .sound])
        { (granted, error) in
            // Enable or disable features based on authorization.
            completion()
        }
    }
}
