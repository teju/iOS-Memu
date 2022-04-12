//
//  UIExtensions.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/28/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator

extension UIViewController {
    
    /// Display message in prompt view
    ///
    /// — Parameters:
    /// — title: Title to display Alert
    /// — message: Pass string of content message
    /// — options: Pass multiple UIAlertAction title like “OK”,”Cancel” etc
    /// — completion: The block to execute after the presentation finishes.
    func showAlert(title: String, message: String, btnOkay : String,btnCancel : String, completion: (()->())? = nil) {
        let popvc = UIStoryboard(name: "dialogs", bundle: nil).instantiateViewController(withIdentifier: "InfoAlertViewController") as! InfoAlertViewController
            popvc.alerttitle = title
            popvc.alertdescription = message
            popvc.btnOKtitle = btnOkay
            popvc.btnCancelTitle = btnCancel
            self.addChild(popvc)
   
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
    }
    
    func showAlert(title: String, userName: String, userImage : String, rightImage:UIImage, isAccept : Bool,friend_id :String,Notifications : Notifications) {
         let popvc = UIStoryboard(name: "dialogs", bundle: nil).instantiateViewController(withIdentifier: "UserDataAlertViewController") as! UserDataAlertViewController
             popvc.alerttitle = title
             popvc.userImage = userImage
             popvc.userName = userName
             popvc.rightImage = rightImage
            popvc.isAccept = isAccept
            popvc.friend_id = friend_id
            popvc.Notifications = Notifications
             self.addChild(popvc)
             popvc.view.frame = self.view.frame
             self.view.addSubview(popvc.view)
             popvc.didMove(toParent: self)
     }
    func showAlert(title: String, userName: String, userImage : URL, liked:Bool,desc:String,completion: (()->())? = nil) {
        let popvc = UIStoryboard(name: "dialogs", bundle: nil).instantiateViewController(withIdentifier: "ShortNotifyViewController") as! ShortNotifyViewController
            popvc.alerttitle = title
            popvc.userImage = userImage
            popvc.userName = userName
            popvc.isLiked = liked
            popvc.descriptionVal = desc
            self.addChild(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
    }
    func showAlert(title: String, userName: String, userImage : URL, alertImage : URL,user_map_feed_id:String,lattitude:Double,longitude:Double) {
        let popvc = UIStoryboard(name: "dialogs", bundle: nil).instantiateViewController(withIdentifier: "NaviAlertsViewController") as! NaviAlertsViewController
            popvc.alerttitle = title
            popvc.userImage = userImage
            popvc.userName = userName
            popvc.alertImage = alertImage
            popvc.latitude = lattitude
            popvc.longitude = longitude
            popvc.user_map_feed_id = user_map_feed_id
            self.addChild(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
    }
    func showAlert(completion: (()->())? = nil) {
           let popvc = UIStoryboard(name: "dialogs", bundle: nil).instantiateViewController(withIdentifier: "MapFeedAlertViewController") as! MapFeedAlertViewController
           self.addChild(popvc)
           popvc.view.frame = self.view.frame
           self.view.addSubview(popvc.view)
           popvc.didMove(toParent: self)
    }
    func topMostViewController() -> UIViewController {
        var topViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController!
    }
    
    /**
     Displays alert with specified title & message
     
     - parameter title:      the title
     - parameter message:    the message
     - parameter completion: the completion callback
     */
    func showAlert(_ title: String, _ message: String, completion: (()->())? = nil) {
        let popvc = UIStoryboard(name: "dialogs", bundle: nil).instantiateViewController(withIdentifier: "InfoAlertViewController") as! InfoAlertViewController
        popvc.alerttitle = title
        popvc.alertdescription = message
        self.addChild(popvc)
        popvc.view.frame = self.view.frame
       
        self.view.addSubview(popvc.view)
        popvc.didMove(toParent: self)
    }
    
    func create<T: UIViewController>(_ viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        let className = NSStringFromClass(viewControllerClass).components(separatedBy: ".").last!
        var storyboard = self.storyboard
        if let storyboardName = storyboardName {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        return storyboard?.instantiateViewController(withIdentifier: className) as? T
    }
    
    /**
     Returns the navigation controller if it exists
     
     - returns: the navigation controller or nil
     */
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    /**
     Get currently opened view controller
     
     - returns: the top visible view controller
     */
    class func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    /// Show loading view
    ///
    /// - Parameter view: the parent view
    /// - Returns: the loading view
    func showLoadingView(_ view: UIView? = nil) -> LoadingView? {
        return LoadingView(parentView: view ?? UIViewController.getCurrentViewController()?.view ?? self.view, dimming: false).show()
    }
}

extension UINavigationController {

    /**
     Pop current view controller to previous view controller.

     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func pop(transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.popViewController(animated: false)
    }

    /**
     Push a new view controller on the view controllers's stack.

     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }

    private func addTransition(transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }

}

extension UIView {

    /// Make round corners for the view
    ///
    /// - Parameter radius: the radius of the corners
    public func roundCorners(_ radius: CGFloat = 4) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    /// Make the view round
    public func makeRound() {
        self.layoutIfNeeded()
        self.roundCorners(self.bounds.height / 2)
    }

    /// Add shadow to the view
    ///
    /// - Parameters:
    ///   - size: the size of the shadow
    ///   - shift: the shift
    ///   - opacity: the opacity
    ///   - color: the color
    public func addShadow(size: CGFloat = 4, shift: CGFloat? = 1, xShift: CGFloat = 0, opacity: Float = 0.33, color: UIColor = UIColor.black) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: xShift, height: shift ?? size)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = size
    }

    /// Add border for the view
    ///
    /// - Parameters:
    ///   - color: the border color
    ///   - borderWidth: the size of the border
    public func addBorder(color: UIColor = UIColor.black, borderWidth: CGFloat = 0.5) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }

    /// Animate with default settings
    ///
    /// - Parameter animations: the animation callback
    public class func animateWithDefaultSettings(animations: @escaping () -> Swift.Void) {
        UIView.animate(withDuration: 0.3,
                       delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: .beginFromCurrentState, animations: animations, completion: nil)
    }
}

class LoadingView: UIView {
    
    /// loading indicator
    var activityIndicator = MDCActivityIndicator()
    
    /// flag: true - the view is terminated, false - else
    var terminated = false
    
    /// flag: true - the view is shown, false - else
    var didShow = false
    
    /// the reference to the parent view
    var parentView: UIView?
    
    /**
     Initializer
     
     - parameter parentView: the parent view
     - parameter dimming:    true - need to add semitransparent overlay, false - just loading indicator
     */
    init(parentView: UIView?, dimming: Bool = true) {
        super.init(frame: parentView?.bounds ?? UIScreen.main.bounds)
        
        self.parentView = parentView
        
        setupUI(dimming: dimming)
    }
    
    /**
     Required initializer
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Adds loading indicator and changes colors
     
     - parameter dimming: true - need to add semitransparent overlay, false - just loading indicator
     */
    private func setupUI(dimming: Bool) {
        
        activityIndicator.center = self.center
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0);
        self.addSubview(activityIndicator)
        
        if dimming {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        } else {
            self.backgroundColor = UIColor.clear
        }
        self.alpha = 0.0
    }
    
    /**
     Removes the view from the screen
     */
    func terminate() {
        terminated = true
        if !didShow { return }
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        })
    }
    
    /**
     Show the view
     
     - returns: self
     */
    func show() -> LoadingView {
        didShow = true
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return self
            }
            UIApplication.shared.delegate!.window!?.addSubview(self)
        }
        return self
    }
    
    /**
     Change alpha after the view is shown
     */
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.75
        }
    }
}

// MARK: - useful extension for textfields
extension UITextField {
    
    /// unwrapped text value
    var textValue: String {
        return text?.trim() ?? ""
    }
}

extension UIImage {
    
    /// Get image from given view
    ///
    /// - Parameter view: the view
    /// - Returns: UIImage
    class func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
     Resize image
     
     - parameter sizeChange: the new size
     
     - returns: resized image
     */
    func imageResize(_ sizeChange: CGSize) -> UIImage {
        let imageObj = self
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func resizeImage(_ targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     Compresses image size to fit into set max file size limit
     
     - returns: compressed image
     */
    func compressImage(ratio: CGFloat) -> UIImage {
        let image = self
        
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func compress(toSize limit: Int) -> UIImage {
        if let currentSize = self.toJPG()?.count {
            if currentSize > limit {
                let ratio = CGFloat(limit) / CGFloat(currentSize)
                return compressImage(ratio: ratio)
            }
        }
        return self
    }
    
    /// Convert image to data
    ///
    /// - Returns: the data
    func toData() -> Data? {
        if let data = self.pngData() {
            return data
        }
        return nil
    }

    func toJPG() -> Data? {
        if let data = self.jpegData(compressionQuality: 0.5) {
            return data
        }
        return nil
    }

    /// Convert data to image
    ///
    /// - Parameter data: the data
    /// - Returns: the image
    class func fromData(_ data: Data?) -> UIImage? {
        if let data = data {
            return UIImage(data: data)
        }
        return nil
    }
}
