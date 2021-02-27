//
//  ShortNotifyViewController.swift
//  Memu
//
//  Created by Tejaswini N on 27/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class ShortNotifyViewController: UIViewController {
    var descriptionVal  = ""
    var alerttitle  = ""
    var userImage : URL?
    var userName = ""
    var isLiked = false
    
    @IBOutlet weak var bg_view: UIView!
    @IBOutlet weak var imgLikeDislike: UIImageView!
    @IBOutlet weak var coins: UILabel!
    @IBOutlet weak var lbdescription: UILabel!
    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var lbName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.7
        blurEffectView.backgroundColor = UIColor.white
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.bg_view.insertSubview(blurEffectView, at: 0)
        initData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.removeAnimate()
        }
    }
    
    func initData() {
        tittle.text = alerttitle
        lbdescription.text = descriptionVal
        lbName.text = userName
        self.profile_pic.sd_setImage(with: userImage)
        if(isLiked) {
            coins.text = "10"
            imgLikeDislike.image = UIImage(named: "like_btn")
        } else {
            lbdescription.textColor = UIColor.red
            coins.text = "30"
            imgLikeDislike.image = UIImage(named: "dislike_btn")
        }
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

}
