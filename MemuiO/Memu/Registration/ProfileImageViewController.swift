//
//  ProfileImageViewController.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/3/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class ProfileImageViewController: UIViewController, AddAssetButtonViewDelegate {
    
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
        Switcher.updateRootVC()
        RestDataSource.uploadImage(url: "https://memu.world/api/web/profile/update-profile-image", image: image).showLoading(on: self.view)
        .subscribe(onNext: { [weak self] value in
            
        }).disposed(by: rx.bag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
