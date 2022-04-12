//
//  ProfileImageViewController.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/3/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class ProfileImageViewController: UIViewController, AddAssetButtonViewDelegate {
    
    @IBOutlet weak var image_view: UIImageView!
    @IBOutlet weak var btnUpload: AddAssetButtonView!
    
    private var isUpload = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        btnUpload.delegate = self
    }
    
    func addAssetButtonTapped(_ view: AddAssetButtonView) {
        btnUpload.addAssetButtonTapped(btnUpload)
    }
    
    func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool) {
        btnUpload.imageView?.image = nil
        
        if !isUpload {
            uploadImage(image)
            isUpload = true
        }
    }
    
    private func uploadImage(_ image: UIImage) {
    
        RestDataSource.uploadImage(url: "\(RestDataSource.appBaseUrl)profile/update-profile-image", image: image, param: "profile").showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            UserDefaults.profile_picture = value.profile_path
            let url = URL(string: UserDefaults.profile_picture!)
            self?.image_view.sd_setImage(with: url)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let mainVC = storyboard.instantiateViewController(withIdentifier: "UploadSuccessViewController") as! UploadSuccessViewController
               self?.navigationController?.pushViewController(mainVC, animated: true)
            }
           
        }).disposed(by: rx.bag)
    }
}
