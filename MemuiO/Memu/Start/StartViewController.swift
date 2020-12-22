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
        if let login = self.create(LoginViewController.self, storyboardName: "Main") {
            self.navigationController?.pushViewController(login, animated: true)
        }
        
//        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    @IBAction func pooling(_ sender: Any) {
    }
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if let register = self.create(RegistrationViewController.self, storyboardName: "Main") {
            self.navigationController?.pushViewController(register, animated: true)
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
