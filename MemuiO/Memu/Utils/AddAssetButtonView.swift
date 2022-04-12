//
//  AddAssetButtonView.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//
import UIKit
import MobileCoreServices
import Photos
import AVFoundation

/**
 * Delegate protocol for AddAssetButtonView
 *
 */
public protocol AddAssetButtonViewDelegate {

    /**
     User has tapped on the view

     - parameter view: the view with button
     */
    func addAssetButtonTapped(_ view: AddAssetButtonView)

    /// Notify about selected image.
    /// WARNING! The method is invoked twice with different modalDismissed values
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - filename: the filename
    ///   - modalDismissed: true - if modal was dismissed, false - if not yet.
    func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool)
}


/**
 * View that contains a button that allows to add a photo
 *
 * - author: TCCODER
 * - version: 1.0
 */
open class AddAssetButtonView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddAssetButtonViewDelegate {

    /// The image name prefix
    let imageNamePrefix = "IMG "

    /// the maximum image name length
    let imageNameLength = 13

    /// the maximum size of the image
    let maxImageSize: CGSize = CGSize(width: 400, height: 400)

    /// the delegate
    open var delegate: AddAssetButtonViewDelegate? = nil

    /// added subviews
    internal var button: UIButton!
    internal var imageView: UIImageView?
    internal var removeButton: UIButton!

    /// the attached image
    open var image: UIImage?

    /// the last image
    fileprivate var previousImage: UIImage?

    /// supported media types
    internal var mediaTypes: [String] {
        return [kUTTypeImage as String]
    }

    /**
     Layout subviews
     */
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutImage()
        layoutButton()
    }

    /**
     Update selected image

     - parameter image: the image
     */
    open func setSelectedImage(_ image: UIImage?, resetPreviousImage: Bool = false) {
        if resetPreviousImage {
            previousImage = nil
        } else {
            previousImage = self.image
        }
        imageView?.layer.masksToBounds = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.image = image
        self.image = image
    }

    /**
     Restore image
     */
    open func restoreImage() {
        imageView?.image = previousImage
        self.image = previousImage
        previousImage = nil
    }

    /**
     Reset previous image
     */
    open func resetPreviousImage() {
        previousImage = nil
    }

    /**
     Check if image was changed

     - returns: true - if has previous image (image was updated), false - else
     */
    open func isImageChanged() -> Bool {
        return previousImage != nil
    }

    /**
     Layout button and specify action handler method
     */
    internal func layoutButton() {
        if button == nil {
            button = UIButton(frame: self.bounds)
            button.addTarget(self, action: #selector(buttonActionHandler), for: .touchUpInside)
            self.addSubview(button)
            removeButton.superview?.bringSubviewToFront(removeButton)
            removeButton.isHidden = true
        }
        button.frame = self.bounds
    }

    /**
     Layout image view
     */
    internal func layoutImage() {
        let buttonSize: CGFloat = 30
        let buttonFrame = CGRect(x: self.bounds.width - buttonSize, y: self.bounds.height - buttonSize,
                                 width: buttonSize, height: buttonSize)

        if imageView == nil {
            imageView = UIImageView(frame: self.bounds)
            imageView?.image = self.image
            imageView?.contentMode = .scaleAspectFill
            self.addSubview(imageView!)
            self.sendSubviewToBack(imageView!)

            // Remove photo button

            removeButton = UIButton(frame: buttonFrame)
            removeButton.setImage(UIImage(named: "removePhoto"), for: UIControl.State())
            removeButton.addTarget(self, action: #selector(removePhoto), for: .touchUpInside)
            self.addSubview(removeButton)
        }
        removeButton.frame = buttonFrame
        imageView?.frame = self.bounds
    }

    // MARK: Image selection

    /**
     Button action handler
     */
    @objc func buttonActionHandler() {
        UIViewController.getCurrentViewController()?.view.endEditing(true)
        (delegate ?? self).addAssetButtonTapped(self)
    }

    /**
     Check if can change photo

     - returns: true - if tapping on the view will show the dialog, false - will do nothing
     */
    func canChangePhoto() -> Bool {
        return true
    }

    /**
     Remove button action handler
     */
    @objc func removePhoto() {
        UIViewController.getCurrentViewController()?.view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil,
                                      preferredStyle: UIAlertController.Style.actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Photo", comment: "Delete Photo"),
                                      style: UIAlertAction.Style.destructive,
                                      handler: { _ in
                                        self.setSelectedImage(nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

        UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
    }

    /**
     Show camera capture screen
     */
    func showCameraPicker() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            showPickerWithSourceType(UIImagePickerController.SourceType.camera)
        case .denied:
            alertToEncourageCameraAccessInitially()
        case .notDetermined:
            alertPromptToAllowCameraAccessViaSetting()
        default:
            alertToEncourageCameraAccessInitially()
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for take photo",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { _ -> Void in
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        UIViewController().topMostViewController().present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Please allow camera access for take photo",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            if !AVCaptureDevice.devices(for: AVMediaType.video).isEmpty {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { _ in
                    DispatchQueue.main.async() {
                        self.showCameraPicker()
                    }
                }
            }
        })
        UIViewController().topMostViewController().present(alert, animated: true, completion: nil)
    }
    

    /**
     Show photo picker
     */
    func showPhotoLibraryPicker() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.showPickerWithSourceType(UIImagePickerController.SourceType.photoLibrary)
                }
            }
        }
    }

    /**
     Show image picker

     - parameter sourceType: the type of the source
     */
    func showPickerWithSourceType(_ sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = self.mediaTypes
            imagePicker.sourceType = sourceType
            imagePicker.videoQuality = UIImagePickerController.QualityType.typeMedium
            DispatchQueue.main.async {
                UIViewController.getCurrentViewController()?.present(imagePicker, animated: true,
                                                                     completion: nil)
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: "This feature is supported on real devices only",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /**
     Image selected/captured

     - parameter picker: the picker
     - parameter info:   the info
     */
    
    @objc open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var resizedImage: UIImage?
        var filename = "\(imageNamePrefix)\(UUID().uuidString)"
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] {
            if (mediaType as AnyObject).description == kUTTypeImage as String {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    
                    if let url = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                        let result = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
                        let asset = result.firstObject
                        filename = asset?.value(forKey: "filename") as? String ?? filename
                    }
                    if filename.length > imageNameLength {
                        filename = imageNamePrefix + filename[..<filename.index(filename.startIndex, offsetBy: imageNameLength)]
                    }
                    
                    let newWidth = maxImageSize.width
                    let newHeight = newWidth * image.size.height / image.size.width
                    resizedImage = image.imageResize(CGSize(width: newWidth, height: newHeight))
                    self.setSelectedImage(resizedImage!)
                    self.delegate?.addAssetImageChanged(resizedImage!, filename: filename, modalDismissed: false)
                }
            }
        }
        if let resizedImage = resizedImage {
            picker.dismiss(animated: true, completion: {
                self.delegate?.addAssetImageChanged(resizedImage, filename: filename, modalDismissed: true)
            })
        }
    }

    /**
     Image selection canceled

     - parameter picker: the picker
     */
    @objc open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: AddAssetButtonViewDelegate

    /**
     User has tapped on the view

     - parameter view: the view with button
     */
    open func addAssetButtonTapped(_ view: AddAssetButtonView) {
        // Open action sheet only if photo is not selected
        if canChangePhoto() {
            let alert = UIAlertController(title: nil, message: nil,
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Take Photo"), style: UIAlertAction.Style.default,
                                          handler: { _ in
                                            self.showCameraPicker()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("Choose Photo", comment: "Choose Photo"), style: .default,
                                          handler: { _ in
                                            self.showPhotoLibraryPicker()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

            UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
        }
    }

    /// Nothing to do. Only external delegate can implement this method to process the image
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - filename: the filename
    ///   - modalDismissed: true - if modal was dismissed, false - if not yet.
    open func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool) {
    }
}

extension PHAsset {

    func image(completionHandler: @escaping (UIImage) -> ()){
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { img, _ in
            thumbnail = img!
        })
        completionHandler(thumbnail)
    }
}
