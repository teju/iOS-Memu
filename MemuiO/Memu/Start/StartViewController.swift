//
//  StartViewController.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        if(!UserDefaults.isFirstTime) {
            if let login = self.create(TermsConditionsViewController.self, storyboardName: "Main") {
                login.isFromLogin = true
                self.navigationController?.pushViewController(login, animated: true)
            }
        } else {
            if let login = self.create(LoginViewController.self, storyboardName: "Main") {
                self.navigationController?.pushViewController(login, animated: true)
            }
        }
       
        
    }
    @IBAction func skip(_ sender: Any) {
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
    }
    
    @IBAction func pooling(_ sender: Any) {
    }
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if(!UserDefaults.isFirstTime) {
            if let login = self.create(TermsConditionsViewController.self, storyboardName: "Main") {
                login.isFromLogin = false
                self.navigationController?.pushViewController(login, animated: true)
            }
        } else {
            if let register = self.create(RegistrationViewController.self, storyboardName: "Main") {
                self.navigationController?.pushViewController(register, animated: true)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
