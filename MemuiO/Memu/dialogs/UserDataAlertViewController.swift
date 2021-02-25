//
//  UserDataAlertViewController.swift
//  Memu
//
//  Created by Tejaswini N on 25/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class UserDataAlertViewController: UIViewController {
       var alerttitle = ""
       var userName = ""
    var userImage :URL?
       var rightImage = UIImage()
    
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: roundImageView!
    @IBOutlet weak var imgRightImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
               let blurEffectView = UIVisualEffectView(effect: blurEffect)
               blurEffectView.alpha = 0.5
               blurEffectView.frame = view.bounds
               blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               self.view.insertSubview(blurEffectView, at: 0)
        
        lbltitle.text = alerttitle
        lblName.text = userName
         self.imgUser.sd_setImage(with: userImage)
        imgRightImg.image = rightImage
    }
    

   func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
               
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }

    @IBAction func cancel(_ sender: Any) {
        removeAnimate()
    }

}
