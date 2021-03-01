//
//  NaviAlertsViewController.swift
//  Memu
//
//  Created by Tejaswini N on 01/03/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class NaviAlertsViewController: UIViewController {
    @IBOutlet weak var alert_img: UIImageView!
    @IBOutlet weak var bg_view: UIView!
    @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    var alerttitle  = ""
       var userImage : URL?
       var userName = ""
        var alertImage : URL?
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
          let blurEffectView = UIVisualEffectView(effect: blurEffect)
           blurEffectView.alpha = 0.5
           blurEffectView.backgroundColor = UIColor.white
          blurEffectView.frame = view.bounds
          blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          self.bg_view.insertSubview(blurEffectView, at: 0)
        initData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.removeAnimate()
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
      
    func initData() {
        lbName.text = userName
        lbTitle.text = "   \(alerttitle)"
        self.profile_pic.sd_setImage(with: userImage)

    }
    @IBAction func point(_ sender: Any) {
        showAlert("", "point")

    }
    
    @IBAction func like(_ sender: Any) {
        showAlert("", "Like")
    }
    @IBAction func dislike(_ sender: Any) {
        showAlert("", "DiskLike")

    }
}
