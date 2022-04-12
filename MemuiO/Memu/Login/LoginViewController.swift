//
//  LoginViewController.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/30/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtOTP: UITextField!
    @IBOutlet weak var btnOTP: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        
        txtMobile.delegate = self
        txtOTP.delegate = self
        txtMobile.setLeftPaddingPoints(20)
        txtOTP.setLeftPaddingPoints(20)

        // Observer for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){

        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 44
        scrollView.contentInset = contentInset
    }

    @IBAction func skip(_ sender: Any) {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let nav = AppNavigation(rootViewController: mainVC)
        
        // iOS13 or later
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            sceneDelegate.window!.rootViewController = nav

        // iOS12 or earlier
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = nav
        }
    }
    @objc func keyboardWillHide(notification:NSNotification){

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func didTouch(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtMobile {
            txtOTP.becomeFirstResponder()
        } else if textField == txtOTP {
            txtOTP.resignFirstResponder()
            loginClicked()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 10 characters
        return updatedText.count <= 10
        
    }
    
    @IBAction func resendButtonClicked(_ sender: UIButton) {
        verifyMobile()
    }
    
    @IBAction func getOTPButtonClicked(_ sender: UIButton) {
        guard let btnTitle = sender.titleLabel?.text else {
            return
        }
        if btnTitle == "Sign In" {
            loginClicked()
        } else {
            verifyMobile()
        }
    }
    
    private func verifyMobile() {
        RestDataSource.verifyMobile(txtMobile.textValue)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            if value.status == "success" {
                self?.updateUI()
            }
            self?.showAlert(value.status, value.message)

        }).disposed(by: rx.bag)
    }

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loginClicked() {
        RestDataSource.login(mobileNo: txtMobile.textValue, OTP: txtOTP.textValue)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            guard let value = value else {
                self?.showAlert("failed", "OTP does not match")
                return
            }
            if value.result.status == "success" {
                UserDefaults.name = value.name
                UserDefaults.referel_code = value.referel_code
                UserDefaults.user_id = value.id
                UserDefaults.profile_picture = value.photo.profile_path
                UserDefaults.accessToken = value.accessToken
                UserDefaults.isAuthenticated = true
                Switcher.updateRootVC()
            } else {
                self?.showAlert(value.result.status, value.result.message)
            }
        }).disposed(by: rx.bag)
    }
    
    private func updateUI() {
        txtOTP.isHidden = false
        btnResend.isHidden = false
        
        btnOTP.setTitle("Sign In", for: .normal)
    }
}
extension UITextField{
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

