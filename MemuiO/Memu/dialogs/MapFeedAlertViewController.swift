//
//  MapFeedAlertViewController.swift
//  Memu
//
//  Created by Tejaswini N on 27/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class MapFeedAlertViewController: UIViewController {
    @IBOutlet weak var bg_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

         let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
               let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.alpha = 0.5
                blurEffectView.backgroundColor = UIColor.white
               blurEffectView.frame = view.bounds
               blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               self.bg_view.insertSubview(blurEffectView, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
   

}
