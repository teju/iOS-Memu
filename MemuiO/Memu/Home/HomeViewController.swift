//
//  HomeViewController.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/28/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var profile_pic: UIImageView!
    @IBOutlet weak var btnName: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        BackgroundLocationManager.instance.start()

        self.navigationController?.navigationBar.isHidden = true
        let url = URL(string: UserDefaults.profile_picture!)
        btnName.setTitle(UserDefaults.name, for: .normal)

        self.profile_pic.sd_setImage(with: url)

    }
    @IBAction func profile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "ProfileWallViewController") as! ProfileWallViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func pooling_car(_ sender: Any) {

       let storyboard = UIStoryboard(name: "BookingStoryboard", bundle: nil)
       let mainVC = storyboard.instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    @IBAction func pooling_txt(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BookingStoryboard", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
         self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    @IBAction func logoutClicked() {
        UserDefaults.name = ""
        UserDefaults.isAuthenticated = false
        Switcher.updateRootVC()
    }
    
    @IBAction func bestRoute(_ sender: Any) {
        if(UserDefaults.longitude != 0 && UserDefaults.longitude != 0) {
            let mainVC = BestRouteViewController(nibName: "BestRouteViewController", bundle: nil)
               self.navigationController?.push(viewController: mainVC)
        } else {
             self.showAlert("","Please enable your location service and retry")
        }
    }
    @IBAction func bestRouteClicked() {
        if(UserDefaults.longitude != 0 && UserDefaults.longitude != 0) {
        let mainVC = BestRouteViewController(nibName: "BestRouteViewController", bundle: nil)
            self.navigationController?.push(viewController: mainVC)
        } else {
             self.showAlert("","Please enable your location service and retry")
        }
    }
}
extension UIView {

    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
}
extension UIImageView {
    public func imageFromURL(urlString: String) {

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }

        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })

        }).resume()
    }
}
