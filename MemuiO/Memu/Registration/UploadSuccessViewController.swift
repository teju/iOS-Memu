//
//  UploadSuccessViewController.swift
//  Memu
//
//  Created by Tejaswini N on 09/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class UploadSuccessViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       image.image = UIImage.gif(name: "onboarding_account")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            Switcher.updateRootVC()
        }
    }
}
