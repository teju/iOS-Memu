//
//  RegistrationViewController.swift
//  Memu
//
//  Created by APPLE on 14/03/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreLocation

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView1: S1View!
    @IBOutlet weak var contentView2: S2View!
    @IBOutlet weak var contentView3: S3View!
    @IBOutlet weak var contentView4: S4View!
    @IBOutlet weak var contentView5: S5View!
    
    @IBOutlet weak var carDoorOpen: UIImageView!
    @IBOutlet weak var carDoorClose: UIImageView!
    @IBOutlet weak var carTaxi: UIImageView!
    
    @IBOutlet weak var carDoorOpenTop: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat = 0.0
    var isCarSelected = false
    var isCarDoorOpen = false
    var isCarDoorClose = false
    var isCarTaxi = false

    private var user: UserInfo!
    
    private var timer = Timer()
    private var counter = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Implement ScrollView
        self.scrollView.delegate = self
        setTestFieldDelegate()
        
        setButtonGenderTarget(contentView1.btnMale)
        setButtonGenderTarget(contentView1.btnFemale)
        
        setButtonTarget(contentView2.btnCarDoorClose)
        setButtonTarget(contentView2.btnCarTaxi)
        setButtonTarget(contentView2.btnCarDoorOpen)
        
        setVehicleTypeButtonTarget(contentView3.btnHatchback)
        setVehicleTypeButtonTarget(contentView3.btnSedan)
        setVehicleTypeButtonTarget(contentView3.btnSuv)
        setVehicleTypeButtonTarget(contentView3.btnMotorBike)
        
        setButtonOTPTarget(contentView4.btnOTP)
        setButtonVerifyTarget(contentView4.btnVerify)
        self.view.backgroundColor = hexStringToUIColor(hex: "#eeeeee")
        
        // Observer for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        user = UserInfo()
        
        createFloatingButton()
        
        updateUI()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
           var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

           if (cString.hasPrefix("#")) {
               cString.remove(at: cString.startIndex)
           }

           if ((cString.count) != 6) {
               return UIColor.gray
           }

           var rgbValue:UInt64 = 0
           Scanner(string: cString).scanHexInt64(&rgbValue)

           return UIColor(
               red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
               green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
               blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
               alpha: CGFloat(1.0)
           )
       }
    private func setTestFieldDelegate() {
        contentView1.txtFirstName.delegate = self
        contentView1.txtLastName.delegate = self
        contentView1.txtReferCode.delegate = self
        contentView1.txtFirstName.setUnderLine()

        contentView3.txtVehicleBrand.delegate = self
        contentView3.txtVehicleName.delegate = self
        contentView3.txtRegistrationNo.delegate = self
        contentView3.txtLicenseNo.delegate = self
        
        contentView4.txtMobileNumber.delegate = self
        contentView4.txtOTPNumber.delegate = self
        contentView4.txtHomeEmail.delegate = self
        
        contentView5.txtOfficeAddress.delegate = self
        contentView5.txtWorkEmail.delegate = self
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification){

        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        keyboardHeight = keyboardFrame.size.height
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardHeight + 44
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification){

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func didTouch(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func scrollToSelectVehicleMultiplier(by multiplier: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 1, animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.contentView1.frame.height * multiplier)
            })
        }
    }
    
    private func updateUI() {
        let coordinates = CLLocationCoordinate2D(latitude: UserDefaults.latitude!, longitude: UserDefaults.longitude!)
        LocationManager.shared.locateFromCoordinates(coordinates, result: { result in
            switch result {
            case .failure(let error):
                debugPrint("An error has occurred: \(error)")
            case .success(let places):
                print("Found \(places.count) places!")
                for place in places {
                    self.contentView4.lblHomeAddress.text = place.formattedAddress
                    let address = Address()
                    address.type = "Home"
                    address.lattitude = "\(coordinates.latitude)"
                    address.longitude = "\(coordinates.longitude)"
                    address.formattedAddress = place.formattedAddress ?? ""
                    self.user.address.append(address)
                }
            }
        })
    }
    
    private func setButtonTarget(_ button: UIButton) {
        button.addTarget(self, action: #selector(selectVehicle), for: .touchUpInside)
    }
    
    private func setVehicleTypeButtonTarget(_ button: UIButton) {
        button.addTarget(self, action: #selector(selectVehicleType), for: .touchUpInside)
    }
    
    private func setButtonOTPTarget(_ button: UIButton) {
        button.addTarget(self, action: #selector(getOTPClicked), for: .touchUpInside)
    }
    
    private func setButtonVerifyTarget(_ button: UIButton) {
        button.addTarget(self, action: #selector(verifyOTPClicked), for: .touchUpInside)
    }
    
    private func setButtonGenderTarget(_ button: UIButton) {
        button.addTarget(self, action: #selector(selectGender), for: .touchUpInside)
    }
    
    @objc func selectVehicle(_ sender: UIButton) {
        contentView3.isHidden = false
        deSelectVehicle()
        isCarSelected = true
        switch sender.tag {
        case 0:
            sender.setImage(UIImage(named: "Group 11"), for: .normal)
            carDoorOpen.isHidden = false
            carDoorClose.isHidden = true
            carTaxi.isHidden = true
            isCarDoorOpen = true
            contentView3.isHidden = true
            user.role = "user"
            self.scrollToSelectVehicleMultiplier(by: 1.93)
        case 1:
            sender.setImage(UIImage(named: "Group 71"), for: .normal)
            carDoorOpen.isHidden = true
            carDoorClose.isHidden = false
            carTaxi.isHidden = true
            isCarDoorClose = true
            user.role = "rider"
            user.vehicle.vehicleType = 1
            self.scrollToSelectVehicleMultiplier(by: 1.93)
        case 2:
            sender.setImage(UIImage(named: "Group 71"), for: .normal)
            carDoorOpen.isHidden = true
            carDoorClose.isHidden = true
            carTaxi.isHidden = false
            isCarTaxi = true
            user.role = "driver"
            user.vehicle.vehicleType = 2
            self.scrollToSelectVehicleMultiplier(by: 1.91)
        default:
            return
        }
        
        
    }
    
    @objc func selectVehicleType(_ sender: UIButton) {
        deSelectVehicleType()
        let image = UIImage(named: "TICKBOX")
        switch sender.tag {
        case 0:
            sender.setImage(image, for: .normal)
            user.vehicle.vehicleModelType = "Hatchback"
        case 1:
            sender.setImage(image, for: .normal)
            user.vehicle.vehicleModelType = "Sedan"
        case 2:
            sender.setImage(image, for: .normal)
            user.vehicle.vehicleModelType = "SUV"
        case 3:
            sender.setImage(image, for: .normal)
            user.vehicle.vehicleModelType = "Motor Bike"
        default:
            return
        }
    }
    
    @objc func selectGender(_ sender: UIButton) {
        self.deSelectGender()
        switch sender.tag {
        case 0:
            user.gender = "Male"
            contentView1.btnMale.setTitleColor(UIColor.systemPink, for: .normal)
        case 1:
            user.gender = "Female"
            contentView1.btnFemale.setTitleColor(UIColor.systemPink, for: .normal)
        default:
            return
        }
    }
    
    private func deSelectVehicleType() {
        let image = UIImage(named: "Tickbox-1")
        contentView3.btnHatchback.setImage(image, for: .normal)
        contentView3.btnSedan.setImage(image, for: .normal)
        contentView3.btnSuv.setImage(image, for: .normal)
        contentView3.btnMotorBike.setImage(image, for: .normal)
    }
    
    private func deSelectVehicle() {
        contentView2.btnCarDoorOpen.setImage(UIImage(named: "Group 7"), for: .normal)
        contentView2.btnCarDoorClose.setImage(UIImage(named: "Group 5"), for: .normal)
        contentView2.btnCarTaxi.setImage(UIImage(named: "Group 7"), for: .normal)
        
        isCarDoorOpen = false
        isCarDoorClose = false
        isCarTaxi = false
    }
    
    private func deSelectGender() {
        contentView1.btnMale.setTitleColor(UIColor.blue, for: .normal)
        contentView1.btnFemale.setTitleColor(UIColor.blue, for: .normal)
    }
    
    private func validateUserInfo() -> Bool {
        if contentView1.txtFirstName.textValue.isEmpty {
            contentView1.txtFirstName.becomeFirstResponder()
            return false
        } else if contentView1.txtLastName.textValue.isEmpty {
            contentView1.txtLastName.becomeFirstResponder()
            return false
        } else {
            user.firstName = contentView1.txtFirstName.textValue
            user.lastName = contentView1.txtLastName.textValue
        }
        return true
    }
    
    private func validateVehicleInfo() -> Bool {
        if !isCarSelected {
            scrollToSelectVehicleMultiplier(by: 1)
            return false
        }
        
        if isCarDoorClose || isCarTaxi {
            if contentView3.txtVehicleBrand.textValue.isEmpty {
                contentView3.txtVehicleBrand.becomeFirstResponder()
                return false
            } else if contentView3.txtVehicleName.textValue.isEmpty {
                contentView3.txtVehicleName.becomeFirstResponder()
                return false
            }
            
            else {
                user.vehicle.vehicleBrand = contentView3.txtVehicleBrand.textValue
                user.vehicle.vehicleName = contentView3.txtVehicleName.textValue
                user.vehicle.registrationNo = contentView3.txtRegistrationNo.textValue
                user.vehicle.licenseNo = contentView3.txtLicenseNo.textValue
            }
        }
        
        return true
    }
    
    private func verifyMobile() -> Bool {
        if contentView4.txtMobileNumber.textValue.isEmpty {
            contentView4.txtMobileNumber.becomeFirstResponder()
            return false
        }
        return true
    }
    
    private func verifyOTP() -> Bool {
        if contentView4.txtOTPNumber.textValue.isEmpty {
            contentView4.txtOTPNumber.becomeFirstResponder()
            return false
        }
        return true
    }
    
    @objc func getOTPClicked() {
        if contentView4.txtMobileNumber.textValue.count == 10 {
            counter = 30
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (t) in
                self.updateCounter()
            }
            if verifyMobile() {
                RestDataSource.requestMobile(contentView4.txtMobileNumber.textValue)
                .showLoading(on: self.view)
                .subscribe(onNext: { [weak self] value in
                    self?.showAlert(value.status, value.message)
                }).disposed(by: rx.bag)
            }
        } else {
            contentView4.txtMobileNumber.becomeFirstResponder()
        }
    }
    

    func updateCounter() {
        //example functionality
        
        if counter > 0 {
            contentView4.btnOTP.isUserInteractionEnabled = false
            if counter > 9 {
                contentView4.btnOTP.setTitle("00:\(counter)", for: .normal)
            } else {
                contentView4.btnOTP.setTitle("00:0\(counter)", for: .normal)
            }
            contentView4.btnOTP.setTitleColor(UIColor.red, for: .normal)
            counter -= 1
        } else {
            timer.invalidate()
            contentView4.btnOTP.setTitleColor(UIColor.gray, for: .normal)
            contentView4.btnOTP.setTitle("Resend OTP", for: .normal)
            contentView4.btnOTP.isUserInteractionEnabled = true
        }
    }
    
    @objc func verifyOTPClicked() {
        if verifyOTP() {
            RestDataSource.verifyOTP(contentView4.txtMobileNumber.textValue, OTP: contentView4.txtOTPNumber.textValue)
            .showLoading(on: self.view)
            .subscribe(onNext: { [weak self] value in
                if value.status == "success" {
                    self?.user.mobile = self?.contentView4.txtMobileNumber.textValue ?? ""
                }
                self?.showAlert(value.status, value.message)
            }).disposed(by: rx.bag)
        }
    }
    
    private func verifyEmail() -> Bool {
        if contentView4.txtHomeEmail.textValue.isEmpty {
            contentView4.txtHomeEmail.becomeFirstResponder()
            return false
        }
        user.email = contentView4.txtHomeEmail.textValue
        return true
    }
    
    private func signUp() {
        RestDataSource.signUp(user)
        .showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            guard let value = value else {
                self?.showAlert("failed", "")
                return
            }
            if value.result.status == "success" {
                UserDefaults.name = value.name
                UserDefaults.user_id = value.id
                UserDefaults.accessToken = value.accessToken
                UserDefaults.isAuthenticated = true
                if let profile = self?.create(ProfileImageViewController.self, storyboardName: "Main") {
                    self?.navigationController?.pushViewController(profile, animated: true)
                }
            } else {
                self?.showAlert(value.result.status, value.result.message)
            }
        }).disposed(by: rx.bag)
    }
    
    /// To-do: Not used Now. Floating button . Later might use.
    private var floatingButton: UIButton?
    private let floatingButtonImageName = "NAME OF YOUR IMAGE"
    private static let buttonHeight: CGFloat = 45.0
    private static let buttonWidth: CGFloat = 80.0
    private let roundValue = RegistrationViewController.buttonHeight/2
    private let trailingValue: CGFloat = 15.0
    private let leadingValue: CGFloat = 16.0
    private let shadowRadius: CGFloat = 2.0
    private let shadowOpacity: Float = 0.5
    private let shadowOffset = CGSize(width: 0.0, height: 5.0)
    private let scaleKeyPath = "scale"
    private let animationKeyPath = "transform.scale"
    private let animationDuration: CFTimeInterval = 0.4
    private let animateFromValue: CGFloat = 1.00
    private let animateToValue: CGFloat = 1.05
    
    public override func viewWillDisappear(_ animated: Bool) {
        guard floatingButton?.superview != nil else {  return }
        DispatchQueue.main.async {
            self.floatingButton?.removeFromSuperview()
            self.floatingButton = nil
        }
        super.viewWillDisappear(animated)
    }
    
    private func createFloatingButton() {
        let image = UIImage.gif(name: "next_button") as UIImage?

        floatingButton = UIButton(type: .custom)
        floatingButton?.translatesAutoresizingMaskIntoConstraints = false
        floatingButton?.addTarget(self, action: #selector(doThisWhenButtonIsTapped(_:)), for: .touchUpInside)
        floatingButton?.setImage(image, for: .normal)
        constrainFloatingButtonToWindow()
        //makeFloatingButtonRound()
        //addShadowToFloatingButton()
        //addScaleAnimationToFloatingButton()
    }
    
    /// To-do: Add some logic for when the button is tapped.
    @IBAction private func doThisWhenButtonIsTapped(_ sender: Any) {
        if validateUserInfo() {
            if validateVehicleInfo() {
                if user.mobile.isEmpty {
                    if isCarTaxi || isCarDoorClose {
                        scrollToSelectVehicleMultiplier(by: 2.9)
                    } else {
                        scrollToSelectVehicleMultiplier(by: 1.85)
                    }
                } else if !verifyEmail() {
                    contentView4.txtHomeEmail.becomeFirstResponder()
                } else {
                    signUp()
                }
            }
        }
    }
    
    private func constrainFloatingButtonToWindow() {
        DispatchQueue.main.async {
            guard let floatingButton = self.floatingButton else { return }
            self.view.addSubview(floatingButton)
            self.view.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
                                                constant: self.trailingValue).isActive = true
            self.view.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
                                              constant: self.leadingValue).isActive = true
            floatingButton.widthAnchor.constraint(equalToConstant:
                RegistrationViewController.buttonWidth).isActive = true
            floatingButton.heightAnchor.constraint(equalToConstant:
                RegistrationViewController.buttonHeight).isActive = true
        }
    }
    
    private func makeFloatingButtonRound() {
        floatingButton?.layer.cornerRadius = roundValue
    }
    
    private func addShadowToFloatingButton() {
        floatingButton?.layer.shadowColor = UIColor.black.cgColor
        floatingButton?.layer.shadowOffset = shadowOffset
        floatingButton?.layer.masksToBounds = false
        floatingButton?.layer.shadowRadius = shadowRadius
        floatingButton?.layer.shadowOpacity = shadowOpacity
    }
    
    private func addScaleAnimationToFloatingButton() {
        DispatchQueue.main.async {
            let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: self.animationKeyPath)
            scaleAnimation.duration = self.animationDuration
            scaleAnimation.repeatCount = .greatestFiniteMagnitude
            scaleAnimation.autoreverses = true
            scaleAnimation.fromValue = self.animateFromValue
            scaleAnimation.toValue = self.animateToValue
            self.floatingButton?.layer.add(scaleAnimation, forKey: self.scaleKeyPath)
        }
    }
}

extension RegistrationViewController: UIScrollViewDelegate, UITextFieldDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var screenHeight: CGFloat = 0.0
        var maxLimit: CGFloat = 0.0
        
        if isCarTaxi {
            screenHeight = contentView1.frame.height + 230
            maxLimit = screenHeight * 2.1
        } else if isCarDoorOpen {
            screenHeight = contentView1.frame.height
            maxLimit = screenHeight * 2.0
        } else {
            screenHeight = contentView1.frame.height + 130
            maxLimit = screenHeight * 2.4
        }
        
        if (screenHeight < scrollView.contentOffset.y) && isCarSelected {
            let topConstraint = (scrollView.contentOffset.y - screenHeight) + 1
            if topConstraint > 54 && topConstraint < maxLimit {
                carDoorOpenTop.constant = topConstraint
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == contentView1.txtFirstName {
            contentView1.txtLastName.becomeFirstResponder()
        } else if textField == contentView1.txtLastName {
            contentView1.txtReferCode.becomeFirstResponder()
        } else if textField == contentView1.txtReferCode {
            contentView1.txtReferCode.resignFirstResponder()
            scrollToSelectVehicleMultiplier(by: 1)
        }
        else if textField == contentView3.txtVehicleBrand {
            contentView3.txtVehicleName.becomeFirstResponder()
        } else if textField == contentView3.txtVehicleName {
            contentView3.txtRegistrationNo.becomeFirstResponder()
        } else if textField == contentView3.txtRegistrationNo {
            contentView3.txtLicenseNo.becomeFirstResponder()
        } else if textField == contentView3.txtLicenseNo {
            contentView3.txtLicenseNo.resignFirstResponder()
            
            scrollToSelectVehicleMultiplier(by: 2.9)
        }
        else if textField == contentView4.txtMobileNumber {
            contentView4.txtOTPNumber.becomeFirstResponder()
        } else if textField == contentView4.txtOTPNumber {
            contentView4.txtHomeEmail.becomeFirstResponder()
        } else if textField == contentView4.txtHomeEmail {
            contentView4.txtHomeEmail.resignFirstResponder()
            if contentView3.isHidden {
                scrollToSelectVehicleMultiplier(by: 2.9)
            } else {
                scrollToSelectVehicleMultiplier(by: 3.9)
            }
        }
        else if textField == contentView5.txtOfficeAddress {
            contentView5.txtWorkEmail.becomeFirstResponder()
        } else if textField == contentView5.txtWorkEmail {
            contentView5.txtWorkEmail.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        
        if textField == contentView4.txtMobileNumber {
            let currentText = textField.text ?? ""
            
            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // make sure the result is under 10 characters
            return updatedText.count <= 10
        }
        return true
    }
}

extension UIView {

    func setUnderLine() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width - 10, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    func setUnderLine(colour : UIColor) {
           let border = CALayer()
           let width = CGFloat(0.5)
           border.borderColor = colour.cgColor
           border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width - 10, height: self.frame.size.height)
           border.borderWidth = width
           self.layer.addSublayer(border)
           self.layer.masksToBounds = true
       }
    func removeUnderline() {
        for layer in layer.sublayers! {
           if layer.isKind(of: CAShapeLayer.self) {
              layer.removeFromSuperlayer()
           }
        }
    }
}
