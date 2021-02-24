//
//  InfoAlertViewController.swift
//  Memu
//
//  Created by Tejaswini N on 23/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class InfoAlertViewController: UIViewController {

    @IBOutlet weak var view_bg: UIView!
    var alerttitle = ""
    var alertdescription = ""
    var btnOKtitle = ""
    var btnCancelTitle = ""
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var lbtittle: UILabel!
    @IBOutlet weak var lbdescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.5
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, at: 0)

        lbtittle.text = alerttitle
        lbdescription.text = alertdescription
        if(btnCancelTitle.isEmpty) {
            btn_cancel.isHidden = true
            btnOK.frame = CGRect(x:view_bg.frame.width/2 - 50, y:btnOK.frame.origin.y, width:97, height: 41)
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

    @IBAction func cancel(_ sender: Any) {
        removeAnimate()
    }
    
    @IBAction func okay(_ sender: Any) {
        if(btnCancelTitle.isEmpty) {
            removeAnimate()
        }
    }
    
}
