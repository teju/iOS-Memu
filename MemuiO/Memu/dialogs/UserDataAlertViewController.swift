//
//  UserDataAlertViewController.swift
//  Memu
//
//  Created by Tejaswini N on 25/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class UserDataAlertViewController: UIViewController {
    @IBOutlet weak var view_bg: UIView!
    var alerttitle = ""
    @IBOutlet weak var btn_accept: UIButton!
    var userName = ""
        var userImage :String = ""
       var rightImage = UIImage()
        var isAccept = false
    var friend_id = ""
    var Notifications : Notifications? = nil
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: roundImageView!
    @IBOutlet weak var imgRightImg: UIImageView!
    @IBOutlet weak var btn_ignore: UIButton!
    
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
        if(userImage != "") {
            self.imgUser.sd_setImage(with: URL(string: userImage))

        }
        imgRightImg.image = rightImage
        if(!isAccept) {
            btn_ignore.isHidden = true
            btn_accept.frame = CGRect(x:view_bg.frame.width/2 - 50, y:btn_accept.frame.origin.y, width:97, height: 41)
        } else {
            btn_ignore.setTitle("Ignore", for: .normal)
            btn_accept.setTitle("Accept", for: .normal)
        }
    }
    
    @IBAction func ignore(_ sender: Any) {
        if(isAccept) {
            if(isAccept) {
                if(Notifications?.type == "offer_ride" || Notifications?.type == "find_ride"){
                    AcceptRejectAPI(status: "reject")
                } else {
                RemoveFollowerAPI(type: "Remove")
                }
            }
        }
        removeAnimate()
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
       
        if(isAccept) {
            if(Notifications?.type == "offer_ride" || Notifications?.type == "find_ride" ){
                AcceptRejectAPI(status: "accept")
            } else {
                RemoveFollowerAPI(type: "Accepted")
            }
        }
        removeAnimate()
    }
    func RemoveFollowerAPI(type:String) {
        RestDataSource.postAcceptRemove(type: "FR", freind_id: friend_id, status: type)
        .subscribe(onNext: { [weak self] value in
            
        }).disposed(by: rx.bag)
    }
    func AcceptRejectAPI(status:String) {
        RestDataSource.postRequestApproveReject(statusType: status, type: (Notifications?.type)!, trip_id: Notifications?.trip_id ?? "", trip_rider_id: Notifications?.trip_rider_id ?? "")
            .subscribe(onNext : { [weak self] value in
                
            }).disposed(by: rx.bag)
    }
}
