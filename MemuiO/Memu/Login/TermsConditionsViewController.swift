//
//  TermsConditionsViewController.swift
//  Memu
//
//  Created by Tejaswini N on 18/08/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit
import PDFKit

class TermsConditionsViewController: UIViewController,AddAssetButtonViewDelegate {
    func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool) {
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var btnAgree: AddAssetButtonView!
    @IBOutlet weak var pdf_view: UIView!
    var isFromLogin = false
    override func viewDidLoad() {
        super.viewDidLoad()

        let pdfView = PDFView(frame: self.pdf_view.bounds)
        self.pdf_view.addSubview(pdfView)
        pdfView.autoScales = true
            
            // Load Sample.pdf file from app bundle.
        let fileURL = Bundle.main.url(forResource: "terms_conditions", withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
        btnAgree.delegate = self

    }
    
    func addAssetButtonTapped(_ view: AddAssetButtonView) {
        btnAgree.imageView?.image = nil
        UserDefaults.isFirstTime = true
        if(isFromLogin) {
            if let login = self.create(LoginViewController.self, storyboardName: "Main") {
                self.navigationController?.pushViewController(login, animated: true)
            }
        } else {
            if let register = self.create(RegistrationViewController.self, storyboardName: "Main") {
                self.navigationController?.pushViewController(register, animated: true)
            }
        }
    }
    


}
